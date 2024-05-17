// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../contracts/libraries/Structs.sol";
import "./Permissions.sol";

/// @title Storage
/// @notice Acts as the central data storage for all contract states across the platform.
/// @dev This abstract contract holds all the important state variables used by other contracts.
abstract contract Storage is Permissions {
    
    /// @notice Address of the vault, central to the financial logic of the platform.
    address internal vaultAddress;

    /// @notice Address of the asset factory contract.
    address internal assetFactoryAddress;

    // /// @notice Discount factor in basis points used for calculating discounts on transactions.
    // uint256 internal discountFactorInBasisPoints;

    /// @notice Nonce used for generating unique identifiers for assets.
    uint256 internal nonce;

    /// @notice Mapping of token addresses to their allowance status within the platform.
    mapping(address acceptedToken => bool) internal isAllowedToken;

    /// @notice Mapping of asset addresses to their corresponding asset details.
    mapping(address assetAddress => Structs.Asset) internal addressToAsset;

    /// @notice Tracks whether a position associated with an asset has been exited.
    mapping(address assetAddress => bool) internal positionHasExited;

    // /// @notice Mapping of asset addresses to their current exchange rates.
    // mapping(address assetAddress => Structs.ExchangeRate) internal addressToExchangeRate;

    
}
