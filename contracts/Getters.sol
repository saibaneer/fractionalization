// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


import "./Storage.sol";
import "./libraries/Utils.sol";


/// @title Getters
/// @notice Provides read-only access to contract states for external callers.
/// @dev This contract contains functions that return various state informations stored in the contract.

abstract contract Getters is Storage {
    
    /// @notice Checks if an asset has exited (withdrawn/closed) position.
    /// @dev Useful for external contracts or UIs to check the status of an asset.
    /// @return bool indicating whether the asset has exited.
    function contractAssetHasExited() public view returns(bool) {
        return positionHasExited[msg.sender];
    }

    /// @notice Retrieves the current vault address stored in the contract.
    /// @dev The vault address is critical for many operations, including security checks and transfers.
    /// @return address The current vault address.
    function getVaultAddress() public view returns(address) {
        return vaultAddress;
    }

    /// @notice Determines if a token is allowed for transactions.
    /// @dev Checks the isAllowedToken mapping to see if a token is authorized for use in the contract.
    /// @param _tokenAddress The address of the token to check.
    /// @return bool True if the token is allowed, false otherwise.
    function isTokenAllowed(address _tokenAddress) public view returns(bool) {
        return isAllowedToken[_tokenAddress];
    }

    /// @notice Fetches the URL associated with an asset.
    /// @dev URLs can be used to retrieve more detailed information about an asset, often hosted externally.
    /// @param _assetAddress The address of the asset whose URL is being queried.
    /// @return string The URL associated with the asset.
    function getAssetUrl(address _assetAddress) public view returns(string memory) {
        return IAssetFactoryA(assetFactoryAddress).getAssetUrl(_assetAddress);
        // return Utils.decodeString(addressToUrl[_assetAddress]);
    }

    // /// @notice Gets the exchange rate details for an asset.
    // /// @dev Exchange rates are used to calculate transactions and conversions for the specified asset.
    // /// @param _assetAddress The address of the asset whose exchange rate is being queried.
    // /// @return Structs.ExchangeRate The exchange rate structure containing numerator and denominator.
    // function getAssetExchangeRate(address _assetAddress) public view returns(Structs.ExchangeRate memory) {
    //     return addressToExchangeRate[_assetAddress];
    // }

    //  /// @notice Retrieves the current discount factor in basis points.
    // /// @dev Discount factors are used to calculate discounted rates for various transactions.
    // /// @return uint256 The current discount factor in basis points.
    // function getDiscountFactor() public view returns(uint256) {
    //     return discountFactorInBasisPoints;
    // }
    
}

interface IAssetFactoryA {
    function getAssetUrl(address _assetAddress) external view returns (string memory);
}
