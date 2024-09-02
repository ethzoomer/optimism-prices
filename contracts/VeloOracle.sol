// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
pragma abicoder v2;

import "../interfaces/IVeloPair.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../libraries/Sqrt.sol";
import "../libraries/Address.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IPoolFactory} from "../interfaces/IPoolFactory.sol";
import {IVeloOracle} from "../interfaces/IVeloOracle.sol";
import {ICLFactory} from "../interfaces/ICLFactory.sol";
import {ICLPool} from "../interfaces/ICLPool.sol";

/// @title VeloOracle
/// @author @AkemiHomura-maow, @ethzoomer
/// @notice An oracle contract to fetch and calculate rates for a given set of connectors
/// @dev The routing is done by greedily choose the pool with the most amount of input tokens.
/// The DFS search is performed iteratively, and stops until we have reached the target token,
/// or when the max budget for search has been consumed.
contract VeloOracle is IVeloOracle {
    using Sqrt for uint256;

    /// @notice The address of the poolFactory contract
    address public immutable factoryV2;
    ICLFactory public immutable CLFactory;

    address owner;
    mapping(address => mapping(address => ICLPool)) public enabledCLPools;

    /// @notice Maximum number of hops allowed for rate calculations
    uint8 maxHop = 10;

    /// @param _factoryV2 Address of the factory contract for Velo pairs
    constructor(address _factoryV2, address _CLFactory) {
        factoryV2 = _factoryV2;
        CLFactory = ICLFactory(_CLFactory);
        owner = msg.sender;
    }

    /// @notice Struct to hold balance information for a pair
    struct BalanceInfo {
        uint256 bal0;
        uint256 bal1;
        bool isStable;
    }

    /// @notice Struct to hold path information including intermediate token index and rate
    struct Path {
        uint8 to_i;
        uint256 rate;
    }

    /// @notice Struct to hold return value for balance fetching function
    struct ReturnVal {
        bool mod;
        bool isStable;
        uint256 bal0;
        uint256 bal1;
    }

    /// @notice Struct to hold array variables used in rate calculation, to avoid stack too deep error
    struct Arrays {
        uint256[] rates;
        Path[] paths;
        int256[] decimals;
        uint8[] visited;
    }

    /// @notice Struct to hold iteration variables used in rate calculation, to avoid stack too deep error
    struct IterVars {
        uint256 cur_rate;
        uint256 rate;
        uint8 from_i;
        uint8 to_i;
        bool seen;
    }

    /// @notice Struct to hold variables needed to identify CL pools
    struct CLPairParams {
        address tokenA;
        address tokenB;
        int24 tickSpacing;
    }

    function change_owner(address _owner) public {
        require(msg.sender == owner);
        owner = _owner;
    }

    /// @notice Permissioned function to enable routing through certain CL pools
    function enableCLPairs(CLPairParams[] calldata params) public {
        require(msg.sender == owner);
        for (uint256 i; i < params.length; i++) {
            CLPairParams memory param = params[i];
            address pair = CLFactory.getPool(param.tokenA, param.tokenB, param.tickSpacing);
            require(pair != address(0x0));
            enabledCLPools[param.tokenA][param.tokenB] = ICLPool(pair);
            enabledCLPools[param.tokenB][param.tokenA] = ICLPool(pair);
        }
    }

    /// @notice Permissioned function to disable routing through certain CL pools
    function disableCLPairs(CLPairParams[] calldata params) public {
        require(msg.sender == owner);
        for (uint256 i; i < params.length; i++) {       
            CLPairParams memory param = params[i];     
            delete enabledCLPools[param.tokenA][param.tokenA];
            delete enabledCLPools[param.tokenA][param.tokenB];

        }
    }


    /// @notice Internal function to get balance of two tokens
    /// @param from First token of the pair
    /// @param to Second token of the pair
    /// @param in_bal0 Initial balance of the first token
    /// @return out ReturnVal structure with balance information
    function _getBal(IERC20Metadata from, IERC20Metadata to, uint256 in_bal0)
        internal
        view
        returns (ReturnVal memory out)
    {
        (uint256 b0, uint256 b1) = _getBalances(from, to, false);
        (uint256 b2, uint256 b3) = _getBalances(from, to, true);
        (uint256 b4, uint256 b5) = _getVirtualBalances(from, to);

        uint256 maxBalance = in_bal0;
        uint256 maxPair1;
        uint256 maxPair2;
        bool isMaxStable;

        if (b0 > maxBalance) {
            maxBalance = b0;
            maxPair1 = b0;
            maxPair2 = b1;
            isMaxStable = false;
        }
        if (b2 > maxBalance) {
            maxBalance = b2;
            maxPair1 = b2;
            maxPair2 = b3;
            isMaxStable = true;
        }
        if (b4 > maxBalance) {
            maxBalance = b4;
            maxPair1 = b4;
            maxPair2 = b5;
            isMaxStable = false;
        }

        if (maxBalance > in_bal0) {
            out.mod = true;
            (out.bal0, out.bal1, out.isStable) = (maxPair1, maxPair2, isMaxStable);
        }
    }

    /**
     * @inheritdoc IVeloOracle
     */
    function getManyRatesWithConnectors(uint8 src_len, IERC20Metadata[] memory connectors)
        external
        view
        returns (uint256[] memory rates)
    {
        uint8 j_max = min(maxHop, uint8(connectors.length - src_len));
        Arrays memory arr;
        arr.rates = new uint256[]( src_len );
        arr.paths = new Path[]( (connectors.length - src_len ));
        arr.decimals = new int[](connectors.length);

        // Caching decimals of all connector tokens
        {
            for (uint8 i = 0; i < connectors.length; i++) {
                arr.decimals[i] = int256(uint256(connectors[i].decimals()));
            }
        }

        // Iterating through srcTokens
        for (uint8 src = 0; src < src_len; src++) {
            IterVars memory vars;
            vars.cur_rate = 1;
            vars.from_i = src;
            arr.visited = new uint8[](connectors.length - src_len);
            // Counting hops
            for (uint8 j = 0; j < j_max; j++) {
                BalanceInfo memory balInfo = BalanceInfo(0, 0, false);
                vars.to_i = 0;
                // Going through all connectors
                for (uint8 i = src_len; i < connectors.length; i++) {
                    // Check if the current connector has been used to prevent cycles
                    vars.seen = false;
                    {
                        for (uint8 c = 0; c < j; c++) {
                            if (arr.visited[c] == i) {
                                vars.seen = true;
                                break;
                            }
                        }
                    }
                    if (vars.seen) continue;
                    ReturnVal memory out = _getBal(connectors[vars.from_i], connectors[i], balInfo.bal0);
                    if (out.mod) {
                        balInfo.isStable = out.isStable;
                        balInfo.bal0 = out.bal0;
                        balInfo.bal1 = out.bal1;
                        vars.to_i = i;
                    }
                }

                if (vars.to_i == 0) {
                    arr.rates[src] = 0;
                    break;
                }

                if (balInfo.isStable) {
                    vars.rate = _stableRate(
                        connectors[vars.from_i],
                        connectors[vars.to_i],
                        arr.decimals[vars.from_i] - arr.decimals[vars.to_i]
                    );
                } else {
                    vars.rate =
                        _volatileRate(balInfo.bal0, balInfo.bal1, arr.decimals[vars.from_i] - arr.decimals[vars.to_i]);
                }

                vars.cur_rate *= vars.rate;
                if (j > 0) vars.cur_rate /= 1e18;

                // If from_i points to a connector, cache swap rate for connectors[from_i] : connectors[to_i]
                if (vars.from_i >= src_len) {
                    arr.paths[vars.from_i - src_len] = Path(vars.to_i, vars.rate);
                }
                // If from_i points to a srcToken, check if to_i is a connector which has already been expanded.
                // If so, directly follow the cached path to dstToken to get the final rate.
                else {
                    if (arr.paths[vars.to_i - src_len].rate > 0) {
                        while (true) {
                            vars.cur_rate = vars.cur_rate * arr.paths[vars.to_i - src_len].rate / 1e18;
                            vars.to_i = arr.paths[vars.to_i - src_len].to_i;
                            if (vars.to_i == connectors.length - 1) {
                                arr.rates[src] = vars.cur_rate;
                                break;
                            }
                        }
                    }
                }
                arr.visited[j] = vars.to_i;

                // Next token is dstToken, stop
                if (vars.to_i == connectors.length - 1) {
                    arr.rates[src] = vars.cur_rate;
                    break;
                }
                vars.from_i = vars.to_i;
            }
        }
        return arr.rates;
    }

    /// @notice Internal function to calculate the volatile rate for a pair
    /// @dev For volatile pools, the price (negative derivative) is trivial and can be calculated by b1/b0
    /// @param b0 Balance of the first token
    /// @param b1 Balance of the second token
    /// @param dec_diff Decimal difference between the two tokens
    /// @return rate Calculated exchange rate, scaled by 1e18
    function _volatileRate(uint256 b0, uint256 b1, int256 dec_diff) internal pure returns (uint256 rate) {
        // b0 has less 0s
        if (dec_diff < 0) {
            rate = (1e18 * b1) / (b0 * 10 ** (uint256(-dec_diff)));
        }
        // b0 has more 0s
        else {
            rate = (1e18 * 10 ** (uint256(dec_diff)) * b1) / b0;
        }
    }

    /// @notice Internal function to calculate the stable rate for a pair
    /// @dev For stable pools, the price (negative derivative) is non-trivial to solve. The rate is thus obtained
    /// by simulating a trade of an amount equal to 1 unit of the first token (t0)
    /// in the pair and seeing how much of the second token (t1) that would buy, taking into consideration
    /// the difference in decimal places between the two tokens.
    /// @param t0 First token of the pair
    /// @param t1 Second token of the pair
    /// @param dec_diff Decimal difference between the two tokens
    /// @return rate Calculated exchange rate, scaled by 1e18
    function _stableRate(IERC20Metadata t0, IERC20Metadata t1, int256 dec_diff) internal view returns (uint256 rate) {
        uint256 t0_dec = t0.decimals();
        address currentPair = _orderedPairFor(t0, t1, true);
        uint256 newOut = 0;

        // newOut in t1
        try IVeloPair(currentPair).getAmountOut((10 ** t0_dec), address(t0)) returns (uint256 result) {
            newOut = result;
        } catch {
            return 0;
        }

        // t0 has less 0s
        if (dec_diff < 0) {
            rate = (1e18 * newOut) / (10 ** t0_dec * 10 ** (uint256(-dec_diff)));
        }
        // t0 has more 0s
        else {
            rate = (1e18 * (newOut * 10 ** (uint256(dec_diff)))) / (10 ** t0_dec);
        }
    }

    /// @notice Internal function to calculate the CREATE2 address for a pair without making any external calls
    /// @dev Codes from https://github.com/velodrome-finance/contracts/blob/main/contracts/Router.sol#L102C7-L102C110
    /// @param tokenA First token of the pair
    /// @param tokenB Second token of the pair
    /// @param stable Whether the pair is stable or not
    /// @return pair Address of the pair
    function _pairFor(IERC20Metadata tokenA, IERC20Metadata tokenB, bool stable) private view returns (address pair) {
        bytes32 salt = keccak256(abi.encodePacked(tokenA, tokenB, stable));
        pair = Clones.predictDeterministicAddress(IPoolFactory(factoryV2).implementation(), salt, factoryV2);
    }

    /// @notice Internal function to get the reserves of a pair, preserving the order of srcToken and dstToken
    /// @param srcToken Source token of the pair
    /// @param dstToken Destination token of the pair
    /// @param stable Whether the pair is stable or not
    /// @return srcBalance Reserve of the source token
    /// @return dstBalance Reserve of the destination token
    function _getBalances(IERC20Metadata srcToken, IERC20Metadata dstToken, bool stable)
        internal
        view
        returns (uint256 srcBalance, uint256 dstBalance)
    {
        (IERC20Metadata token0, IERC20Metadata token1) =
            srcToken < dstToken ? (srcToken, dstToken) : (dstToken, srcToken);
        address pairAddress = _pairFor(token0, token1, stable);

        // if the pair doesn't exist, return 0
        if (!Address.isContract(pairAddress)) {
            srcBalance = 0;
            dstBalance = 0;
        } else {
            (uint256 reserve0, uint256 reserve1,) = IVeloPair(pairAddress).getReserves();
            (srcBalance, dstBalance) = srcToken == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        }
    }

    /// @notice Internal function to get the CL pool for srcToken and dstToken with the largest virtual reserve, and returns the virtual reserves
    /// @param srcToken Source token of the pair
    /// @param dstToken Destination token of the pair
    /// @return srcVirtualBalance Virtual reserve of the source token
    /// @return dstVirtualBalance Virtual reserve of the destination token
    function _getVirtualBalances(IERC20Metadata srcToken, IERC20Metadata dstToken)
        internal
        view
        returns (uint256 srcVirtualBalance, uint256 dstVirtualBalance)
    {
        uint256 maxLiquidity;
        bool isSrcToken0 = srcToken < dstToken;

        ICLPool pool = enabledCLPools[address(srcToken)][address(dstToken)];
        if (address(pool) != address(0x0)){
            uint256 liquidity = uint256(pool.liquidity());

            if (liquidity > maxLiquidity) {
                (uint160 sqrtPriceX96,,,,,) = pool.slot0();

                (srcVirtualBalance, dstVirtualBalance) = isSrcToken0
                    ? ((liquidity << 96) / sqrtPriceX96, (liquidity * (sqrtPriceX96 >> 32)) >> 64)
                    : ((liquidity * (sqrtPriceX96 >> 32)) >> 64, (liquidity << 96) / sqrtPriceX96);

                maxLiquidity = liquidity;
            }
        }
    }

    /// @notice Internal function to fetch the pair from tokens using correct order
    /// @param tokenA First input token
    /// @param tokenB Second input token
    /// @param stable Whether the pair is stable or not
    /// @return pairAddress Address of the ordered pair
    function _orderedPairFor(IERC20Metadata tokenA, IERC20Metadata tokenB, bool stable)
        internal
        view
        returns (address pairAddress)
    {
        (IERC20Metadata token0, IERC20Metadata token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pairAddress = _pairFor(token0, token1, stable);
    }

    /// @notice Internal function to get the minimum of two uint8 values
    /// @param a First value
    /// @param b Second value
    /// @return Minimum of the two values
    function min(uint8 a, uint8 b) internal pure returns (uint8) {
        return a < b ? a : b;
    }
}
