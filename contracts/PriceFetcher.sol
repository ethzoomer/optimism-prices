pragma solidity ^0.8.13;

import "interfaces/IVeloOracle.sol";
import "../interfaces/IERC20Decimals.sol";

contract PriceFetcher {
    IVeloOracle public oracle;
    address public owner;

    event PriceFetched(address indexed token, uint256 price);

    constructor(IVeloOracle _oracle) {
        oracle = _oracle;
        owner = msg.sender;
    }

    function change_owner(address _owner) public{
        require(msg.sender == owner);
        owner = _owner;
    }

    function change_oracle(IVeloOracle _oracle) public{
        require(msg.sender == owner);
        oracle = _oracle;
    }

    function fetchPrices(uint8 src_len, IERC20[] memory connectors) public {
        require(msg.sender == owner);

        uint256[] memory prices = oracle.getManyRatesWithConnectors(src_len, connectors);

        for(uint8 i = 0; i < src_len; i++) {
            emit PriceFetched(address(connectors[i]), prices[i]);
        }
    }
}
