// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.13;

import "interfaces/IVeloOracle.sol";
import "../interfaces/IERC20Decimals.sol";

/// @title PriceFetcher
/// @notice A wrapper contract for VeloOracle. It emits events for fetched prices.
/// @dev The emitted events, incl. the token address and the fetched price, are indexed
/// on Dune Analytics. The events serve as price feeds for tokens live on Velodrome pools.
/// The table name is velodrome_v2_optimism.PriceFetcher_evt_PriceFetched on Dune.
contract PriceFetcher{
    IVeloOracle public oracle;
    address public owner;

    /// @notice Emitted when a price for a token is fetched.
    /// @param token The address of the token.
    /// @param price The fetched price of the token.
    event PriceFetched(address indexed token, uint256 price);

    /// @notice Creates a new PriceFetcher contract.
    /// @param _oracle The address of the VeloOracle to use for fetching prices.
    constructor(IVeloOracle _oracle) {
        oracle = _oracle;
        owner = msg.sender;
    }

    /// @notice Changes the owner of the contract.
    /// @dev Can only be called by the current owner.
    /// @param _owner The address of the new owner.
    function change_owner(address _owner) public{
        require(msg.sender == owner);
        owner = _owner;
    }

    /// @notice Changes the oracle used for fetching prices.
    /// @dev Can only be called by the current owner.
    /// @param _oracle The address of the new VeloOracle.
    function change_oracle(IVeloOracle _oracle) public{
        require(msg.sender == owner);
        oracle = _oracle;
    }

    /// @notice Fetches prices for a list of tokens.
    /// @dev Can only be called by the owner. Emits a PriceFetched event for each token.
    /// @param src_len The number of tokens to fetch prices for.
    /// @param connectors The list of tokens to fetch prices for.
    function fetchPrices(uint8 src_len, IERC20[] memory connectors) public {
        require(msg.sender == owner);

        uint256[] memory prices = oracle.getManyRatesWithConnectors(src_len, connectors);

        for(uint8 i = 0; i < src_len; i++) {
            emit PriceFetched(address(connectors[i]), prices[i]);
        }
    }
}
