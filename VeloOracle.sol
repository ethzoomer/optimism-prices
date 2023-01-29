// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;
pragma abicoder v1;

import "./OracleBase.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IVeloPair.sol";
import "../interfaces/IERC20Decimals.sol";
import "../libraries/Sqrt.sol";
import "../libraries/Address.sol";

contract VeloOracle is IOracle {
    using Sqrt for uint256;

    address public immutable factory;
    bytes32 public immutable initcodeHash;

    IERC20 private constant _NONE = IERC20(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);

    constructor(address _factory, bytes32 _initcodeHash) {
        factory = _factory;
        initcodeHash = _initcodeHash;
    }

    struct BalanceInfo {
        uint256 bal0;
        uint256 bal1;
        uint256 bal2;
        uint256 bal3;
        bool isStable;
        bool isDirect;
        uint256 connectorInd;
    }

    struct SecondHopBalanceInfo {
        uint256 bal0;
        uint256 bal1;
        uint256 bal2;
        uint256 bal3;
        bool isStable;
    }

    // no longer using this function...
    function getRate(IERC20 srcToken, IERC20 dstToken, IERC20 connector) external view override returns (uint256 rate, uint256 weight) {
        //require(connector == _NONE, "SO: connector should be None");
        if (connector == _NONE) {
        for (uint256 i = 1; i < 2; i++) {
            (uint256 b0, uint256 b1) = _getBalances(srcToken, dstToken, i == 0 ? true : false);
            uint256 w = b0 * b1;
            rate = rate + b1 * 1e18 / b0 * w;
            weight = weight + w;
        }

        if (weight > 0) {
            unchecked { rate /= weight; }
            weight = weight.sqrt();
        }
        }
        else {
            address token0 = IUniswapV2Pair(_pairFor(srcToken, dstToken, false)).token0();
            address token1 = IUniswapV2Pair(_pairFor(srcToken, dstToken, false)).token1();
            (uint256 b0, uint256 b1) = _getBalances(srcToken, dstToken, false);
            //(address token0, address token1) = IUniswapV2Pair(_pairFor(srcToken, dstToken, false)).getTokens();
            rate = 0;
            weight = 0;
        }
    }

    // getting prices, while passing in connectors as an array
    function getRateWithConnectors(IERC20 srcToken, IERC20 dstToken, IERC20[] calldata connectors) external view returns (uint256 rate, uint256 weight) {

        BalanceInfo memory balInfo;
        balInfo = BalanceInfo(0, 0, 0, 0, false, true, 0);
        (balInfo.bal0, balInfo.bal1) = _getBalances(srcToken, dstToken, false);
        (balInfo.bal2, balInfo.bal3) = _getBalances(srcToken, dstToken, true);

        if (balInfo.bal2 > balInfo.bal0) {
            balInfo.bal0 = balInfo.bal2;
            balInfo.bal1 = balInfo.bal3;
            balInfo.isStable = true;
        }
        

        for (uint256 i = 0; i < connectors.length; i++) {
            (uint256 b0, uint256 b1) = _getBalances(srcToken, connectors[i], false);
            (uint256 b2, uint256 b3) = _getBalances(srcToken, connectors[i], true);
            if (b0 > balInfo.bal0) {
                balInfo.connectorInd = i;
                balInfo.isStable = false;
                balInfo.bal0 = b0;
                balInfo.bal1 = b1;
                balInfo.isDirect = false;
            }
            if (b2 > balInfo.bal0) {
                balInfo.connectorInd = i;
                balInfo.isStable = true;
                balInfo.bal0 = b2;
                balInfo.bal1 = b3;
                balInfo.isDirect = false;
            }
        }

        // handle cases where direct route is the best/only route
        if (balInfo.isDirect) {
            // calculate ratio based on reserves for volatile pools
            if (!balInfo.isStable) {

                uint256 w = balInfo.bal0 * balInfo.bal1;
                rate = rate + balInfo.bal1 * 1e18 / balInfo.bal0 * w;
                weight = weight + w;

                if (weight > 0) {
                    unchecked { rate /= weight; }
                    weight = weight.sqrt();
                }
            }

            // calculate ratio based on stableswap formula for stable pools
            else {
                uint256 srcTokenDecimals = IERC20Decimals(address(srcToken)).decimals();
                uint256 outputAmount = IVeloPair(_pairFor(srcToken, dstToken, true)).getAmountOut((10**srcTokenDecimals), address(srcToken));
                rate = (outputAmount * 1e18) / (10**srcTokenDecimals);
            }
        }
        //non-direct route where first hop is a volatile pool
        else if (!balInfo.isStable) {
            SecondHopBalanceInfo memory hopBalInfo;
            hopBalInfo = SecondHopBalanceInfo(0, 0, 0, 0, false);

            uint256 w = balInfo.bal0 * balInfo.bal1;
            rate = rate + balInfo.bal1 * 1e18 / balInfo.bal0 * w;
            weight = weight + w;

            if (weight > 0) {
                unchecked { rate /= weight; }
                weight = weight.sqrt();
            }

            (hopBalInfo.bal0, hopBalInfo.bal1) = _getBalances(connectors[balInfo.connectorInd], dstToken, false);
            (hopBalInfo.bal2, hopBalInfo.bal3) = _getBalances(connectors[balInfo.connectorInd], dstToken, true);

            if (hopBalInfo.bal2 > hopBalInfo.bal0) {
                hopBalInfo.bal0 = hopBalInfo.bal2;
                hopBalInfo.bal1 = hopBalInfo.bal3;
                hopBalInfo.isStable = true;
            }

            if (!hopBalInfo.isStable) {

                uint256 w2 = hopBalInfo.bal0 * hopBalInfo.bal1;
                uint256 nextRate = hopBalInfo.bal1 * 1e18 / hopBalInfo.bal0 * w2;
                weight = w2;

                if (weight > 0) {
                    unchecked { nextRate /= weight; }
                    weight = weight.sqrt();
                }

                rate = (rate * nextRate) / 1e18;

            }
            else {
                uint256 connectorTokenDecimals = IERC20Decimals(address(connectors[balInfo.connectorInd])).decimals();
                uint256 outputAmount = IVeloPair(_pairFor(connectors[balInfo.connectorInd], dstToken, true)).getAmountOut((10**connectorTokenDecimals), address(connectors[balInfo.connectorInd]));
                uint256 nextRate = (outputAmount * 1e18) / (10**connectorTokenDecimals);
                rate = (rate * nextRate) / 1e18;
            }


        }

        //non-direct route where first hop is a stable pool
        else {

        }


    }

    // calculates the CREATE2 address for a pair without making any external calls
    function _pairFor(IERC20 tokenA, IERC20 tokenB, bool stable) private view returns (address pair) {
        pair = address(uint160(uint256(keccak256(abi.encodePacked(
                hex"ff",
                factory,
                keccak256(abi.encodePacked(tokenA, tokenB, stable)),
                initcodeHash
            )))));
    }

    // returns the reserves of a pool if it exists, preserving the order of srcToken and dstToken
    function _getBalances(IERC20 srcToken, IERC20 dstToken, bool stable) internal view returns (uint256 srcBalance, uint256 dstBalance) {
        (IERC20 token0, IERC20 token1) = srcToken < dstToken ? (srcToken, dstToken) : (dstToken, srcToken);
        address pairAddress = _pairFor(token0, token1, stable);

        // if the pair doesn't exist, return 0
        if(!Address.isContract(pairAddress)) {
            srcBalance = 0;
            dstBalance = 0;
        }
        else {
            (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(_pairFor(token0, token1, stable)).getReserves();
            (srcBalance, dstBalance) = srcToken == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        }
    }
}
