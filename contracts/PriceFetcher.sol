// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.13;

import "interfaces/IVeloOracle.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title PriceFetcher
/// @notice A wrapper contract for VeloOracle. It emits events for fetched prices.
/// @dev The emitted events, incl. the token address and the fetched price, are indexed
/// on Dune Analytics. The events serve as price feeds for tokens live on Velodrome pools.
/// The table name is velodrome_v2_optimism.PriceFetcher_evt_PriceFetched on Dune.
contract PriceFetcher {
    IVeloOracle public oracle;
    address public owner;
    mapping(address => bool) public callers;

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

    /// @notice Adds a caller to the callers set.
    /// @dev Can only be called by the owner.
    /// @param _caller The address to be added.
    function add_caller(address _caller) public {
        require(msg.sender == owner);
        callers[_caller] = true;
    }

    /// @notice Removes an caller from callers set.
    /// @dev Can only be called by the owner.
    /// @param _caller The address to be removed.
    function remove_caller(address _caller) public {
        require(msg.sender == owner);
        callers[_caller] = false;
    }

    /// @notice Changes the owner of the contract.
    /// @dev Can only be called by the current owner.
    /// @param _owner The address of the new owner.
    function change_owner(address _owner) public {
        require(msg.sender == owner);
        owner = _owner;
    }

    /// @notice Changes the oracle used for fetching prices.
    /// @dev Can only be called by the current owner.
    /// @param _oracle The address of the new VeloOracle.
    function change_oracle(IVeloOracle _oracle) public {
        require(msg.sender == owner);
        oracle = _oracle;
    }

    /// @notice Fetches prices for a list of tokens.
    /// @dev Can only be called by the owner. Emits a PriceFetched event for each token.
    /// @param src_len The number of tokens to fetch prices for.
    /// @param connectors The list of tokens to fetch prices for.
    function fetchPrices(uint8 src_len, IERC20Metadata[] memory connectors) public {
        require(msg.sender == owner || callers[msg.sender]);

        uint256[] memory prices = oracle.getManyRatesWithConnectors(src_len, connectors);

        for (uint8 i = 0; i < src_len; i++) {
            emit PriceFetched(address(connectors[i]), prices[i]);
        }
    }
}
