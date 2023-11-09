// SPDX-License-Identifier: MIT

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
    address[] public source_tokens;
    address[] public connectors;

    function add_tokens(bool is_connector, address[] calldata _tokens) public{
        _only_owner();
        address[] storage arr = is_connector ? connectors : source_tokens;
        for (uint i = 0; i < _tokens.length; i++) {
            arr.push(_tokens[i]);
        }
    }

    function remove_tokens(bool is_connector, uint256[] calldata _indices) public{
        _only_owner();
        address[] storage arr = is_connector ? connectors : source_tokens;
        for (uint i = 0; i < _indices.length; i++) {
            arr[_indices[i]] = arr[arr.length - 1];
            arr.pop();
        }
    }

    function _construct_oracle_args(uint256 _src_len, uint256 _src_offset) internal view returns (IERC20Metadata[] memory oracle_args){
        oracle_args = new IERC20Metadata[]( _src_len + connectors.length );
        for (uint i = _src_offset; i < _src_offset + _src_len; i++) {
            oracle_args[i - _src_offset] = IERC20Metadata(source_tokens[i]);
        }
        for (uint i = _src_len; i < oracle_args.length; i++) {
            oracle_args[i] = IERC20Metadata(connectors[i - _src_len]);
        }
    }

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

    function _only_owner() internal view{
        require(msg.sender == owner);
    }

    /// @notice Adds a caller to the callers set.
    /// @dev Can only be called by the owner.
    /// @param _caller The address to be added.
    function add_caller(address _caller) public {
        _only_owner();
        callers[_caller] = true;
    }

    /// @notice Removes an caller from callers set.
    /// @dev Can only be called by the owner.
    /// @param _caller The address to be removed.
    function remove_caller(address _caller) public {
        _only_owner();
        callers[_caller] = false;
    }

    /// @notice Changes the owner of the contract.
    /// @dev Can only be called by the current owner.
    /// @param _owner The address of the new owner.
    function change_owner(address _owner) public {
        _only_owner();
        owner = _owner;
    }

    /// @notice Changes the oracle used for fetching prices.
    /// @dev Can only be called by the current owner.
    /// @param _oracle The address of the new VeloOracle.
    function change_oracle(IVeloOracle _oracle) public {
        _only_owner();
        oracle = _oracle;
    }

    /// @notice Fetches prices for a list of tokens.
    /// @dev Can only be called by the owner. Emits a PriceFetched event for each token.
    /// @param _src_len The number of source tokens to fetch prices for.
    /// @param _src_offset The number of source tokens to skip. 
    function fetchPrices(uint _src_len, uint _src_offset) public {
        require(msg.sender == owner || callers[msg.sender]);

        uint256[] memory prices = oracle.getManyRatesWithConnectors(uint8(_src_len), _construct_oracle_args(_src_len, _src_offset));

        for (uint i = _src_offset; i < _src_offset + _src_len; i++) {
            emit PriceFetched(source_tokens[i], prices[i - _src_offset]);
        }
    }

}