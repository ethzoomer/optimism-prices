pragma solidity ^0.8.13;
import "../interfaces/IERC20Decimals.sol";

interface IVeloOracle {
    function getManyRatesWithConnectors(uint8 src_len, IERC20[] memory connectors) external view returns (uint256[] memory rates);
}