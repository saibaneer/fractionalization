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

    /// @notice Discount factor in basis points used for calculating discounts on transactions.
    uint256 internal discountFactorInBasisPoints;

    /// @notice Mapping of token addresses to their allowance status within the platform.
    mapping(address => bool) internal allowedTokens;

    /// @notice Mapping of asset addresses to their corresponding asset details.
    mapping(address => Structs.Asset) internal addressToAsset;

    /// @notice Tracks whether a position associated with an asset has been exited.
    mapping(address => bool) internal positionHasExited;

    /// @notice Mapping of asset addresses to their current exchange rates.
    mapping(address => Structs.ExchangeRate) internal addressToExchangeRate;

    /// @notice Mapping of asset addresses to their respective URLs for external information.
    mapping(address => bytes) internal addressToUrl;
}
