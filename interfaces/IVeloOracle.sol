pragma solidity ^0.8.13;
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IVeloOracle {
    /**
    * @notice Gets exchange rates between a series of source tokens and a destination token.
    * @param src_len The length of the source tokens.
    * @param connectors Array of ERC20 tokens where the first src_len elements are source tokens, 
    *        the elements from src_len to len(connectors)-2 are connector tokens, 
    *        and the last element is the destination token.
    * @return rates Array of exchange rates.
    */
    function getManyRatesWithConnectors(uint8 src_len, IERC20Metadata[] memory connectors) external view returns (uint256[] memory rates);
}