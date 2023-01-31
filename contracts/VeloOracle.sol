pragma solidity ^0.8.13;
pragma abicoder v1;

import "../interfaces/IVeloPair.sol";
import "../interfaces/IERC20Decimals.sol";
import "../libraries/Sqrt.sol";
import "../libraries/Address.sol";

contract VeloOracle {
    event Log(uint8 j, uint8 i, uint8[] visited, uint256 data);
    event Log2(string message, address a);
    event Log3(string message, bool a);
    using Sqrt for uint256;

    address public immutable factory;
    bytes32 public immutable initcodeHash;
    uint8 maxHop = 10;

    constructor(address _factory, bytes32 _initcodeHash) {
        factory = _factory;
        initcodeHash = _initcodeHash;
    }

    // source=-1, tgt=-2
    struct BalanceInfo {
        uint256 bal0;
        uint256 bal1;
        bool isStable;
        uint8 from_i;
        uint8 to_i;
    }

    // getting prices, while passing in connectors as an array
    // Assuming srcToken is the first entry of connectors, dstToken is the last entry of connectors
    function getRateWithConnectors(IERC20[] calldata connectors) external view returns (uint256 rate) {
        uint256 cur_rate = 1;
        uint8 from_i = 0;
        IERC20 dstToken = connectors[connectors.length - 1];

        // Caching decimals of all connector tokens
        int[] memory decimals = new int[](connectors.length);
        for (uint8 i = 0; i < connectors.length; i++){
            decimals[i] = int(uint(connectors[i].decimals()));
        }

        // Store visited connector indices
        uint8[] memory visited = new uint8[](connectors.length);
        uint8 j_max = max(maxHop, uint8(connectors.length));

        for (uint8 j = 0; j < j_max; j++){
            BalanceInfo memory balInfo; 
            IERC20 from;   
            balInfo = BalanceInfo(0, 0, false, 255, 255);
            from = connectors[from_i];
            uint8 to_i = 254;
            // Going through all connectors except for srcToken
            for (uint8 i = 1; i < connectors.length; i++) {
                // Check if the current connector has been used to prevent cycles
                bool seen = false;
                for (uint8 c = 0; c < j; c++){
                    if (visited[c] == i){seen = true; break;}
                }
                if (seen) {continue;}
                IERC20 to = connectors[i];
                (uint256 b0, uint256 b1) = _getBalances(from, to, false);
                (uint256 b2, uint256 b3) = _getBalances(from, to, true);
                // emit Log("b0", b0);
                // emit Log("b2", b2);
                if (b0 > balInfo.bal0 || b2 > balInfo.bal0) {
                    uint256 bal0; uint256 bal1; bool isStable;
                    if (b0 > b2) {(bal0, bal1, isStable) = (b0,b1,false);}
                    else {(bal0, bal1, isStable) = (b2,b3,true);}
                    balInfo.to_i = i;
                    balInfo.isStable = isStable;
                    balInfo.bal0 = bal0;
                    balInfo.bal1 = bal1;
                    to_i = i;
                }
            }

            if (to_i == 254){
                return 0;
            }
            // emit Log3("sel", balInfo.isStable);
            if (balInfo.isStable) {rate = _stableRate(from, connectors[to_i], decimals[from_i] - decimals[to_i]);}
            else                  {rate = _volatileRate(balInfo.bal0, balInfo.bal1, decimals[from_i] - decimals[to_i]);} 

            visited[j] = to_i;
            from_i = to_i;
            // emit Log(j, to_i, visited, rate);
            cur_rate *= rate;
            if (j > 0){cur_rate /= 1e18;}
            if (connectors[to_i] == dstToken) {return cur_rate;}
        }                                                            
        return 0;
    }


    function _volatileRate(uint256 b0, uint256 b1, int dec_diff) internal pure returns (uint256 rate){
        // b0 has less 0s
        if (dec_diff < 0){
            rate = (1e18 * b1) / (b0 * 10**(uint(-dec_diff)));
        }
        // b0 has more 0s
        else{
            rate = (1e18 * 10**(uint(dec_diff)) * b1) / b0;
        }
    }

    function _stableRate(IERC20 t0, IERC20 t1, int dec_diff) internal view returns (uint256 rate){
        uint256 t0_dec = t0.decimals();
        address currentPair = _orderedPairFor(t0, t1, true);
        // newOut in t1
        uint256 newOut = IVeloPair(currentPair).getAmountOut((10**t0_dec), address(t0));

        // t0 has less 0s
        if (dec_diff < 0){
            rate = (1e18 * newOut) / (10**t0_dec * 10**(uint(-dec_diff)));
        }
        // t0 has more 0s
        else{
            rate = (1e18 * (newOut * 10**(uint(dec_diff)))) / (10**t0_dec);
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
            (uint256 reserve0, uint256 reserve1,) = IVeloPair(pairAddress).getReserves();
            (srcBalance, dstBalance) = srcToken == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        }
    }

    // fetch pair from tokens using correct order
    function _orderedPairFor(IERC20 tokenA, IERC20 tokenB, bool stable) internal view returns (address pairAddress) {
        (IERC20 token0, IERC20 token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pairAddress = _pairFor(token0, token1, stable);
    }

    function max(uint8 a, uint8 b) internal pure returns (uint8) {
        return a >= b ? a : b;
    }
}