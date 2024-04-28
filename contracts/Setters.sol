// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Storage.sol";
import "./libraries/Errors.sol";

/// @title Setters
/// @notice Manages updating and setting various internal states of the contract.
/// @dev Provides internal functions to update state variables that are essential for the contract’s operations.
abstract contract Setters is Storage {
    // Events declaration
    event AllowedTokenUpdated(address indexed token, bool status);
    event VaultAddressUpdated(address newVaultAddress, address oldVaultAddress);
    event ExchangeRateUpdated(
        address assetAddress,
        uint256 numerator,
        uint256 denominator
    );
    event DiscountFactorUpdated(uint256 discountFactor);

    // Modifiers for common checks
    modifier notZeroAddress(address _addr) {
        require(_addr != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
        _;
    }

    modifier valueChanged(
        address _addr,
        uint256 _numerator,
        uint256 _denominator
    ) {
        require(
            addressToExchangeRate[_addr].numerator != _numerator ||
                addressToExchangeRate[_addr].denominator != _denominator,
            Errors.VALUE_ALREADY_SET
        );
        _;
    }

    modifier differentValue(bool current, bool newValue) {
        require(current != newValue, Errors.VALUE_ALREADY_SET);
        _;
    }

    modifier validDiscountFactor(uint256 _value) {
        require(_value > 99, Errors.BAD_DISCOUNT_FACTOR);
        _;
    }

    /// @notice Updates the allowed status of a token allowed as a deposit token within the contract
    /// @dev Emits an AllowedTokenUpdated event upon successful update
    /// @param _token The address of the token to update
    /// @param _status The new allowed status
    function setAllowedToken(
        address _token,
        bool _status
    ) internal differentValue(allowedTokens[_token], _status) onlySetter {
        allowedTokens[_token] = _status;
        emit AllowedTokenUpdated(_token, _status);
    }

    /// @notice Changes the vault address to a new one
    /// @dev Emits a VaultAddressUpdated event, capturing the old and new addresses
    /// @param _vaultAddress The new vault address to set
    function setVaultAddress(
        address _vaultAddress
    ) internal notZeroAddress(_vaultAddress) onlySetter {
        require(_vaultAddress != vaultAddress, Errors.VALUE_ALREADY_SET);
        address oldVaultAddress = vaultAddress;
        vaultAddress = _vaultAddress;
        // Invariant to check vault address change correctly applied
        assert(
            vaultAddress == _vaultAddress && vaultAddress != oldVaultAddress
        );
        emit VaultAddressUpdated(_vaultAddress, oldVaultAddress);

        
    }

    /// @notice Sets the exchange rate for a specific asset
    /// @dev Emits ExchangeRateUpdated when the exchange rate is changed
    /// @param _assetAddress The address of the asset
    /// @param numerator The numerator of the new exchange rate
    /// @param denominator The denominator of the new exchange rate
    function setAssetExchangeRate(
        address _assetAddress,
        uint256 numerator,
        uint256 denominator
    )
        internal
        notZeroAddress(_assetAddress)
        valueChanged(_assetAddress, numerator, denominator)
        onlySetter
    {
        addressToExchangeRate[_assetAddress] = Structs.ExchangeRate(
            numerator,
            denominator
        );
        
        emit ExchangeRateUpdated(_assetAddress, numerator, denominator);
    }

    /// @notice Updates the discount factor used in pricing calculations
    /// @dev Emits DiscountFactorUpdated upon changing the factor
    /// @param _discountFactorInBasisPoints The new discount factor, in basis points
    function setDiscountFactor(
        uint256 _discountFactorInBasisPoints
    ) internal validDiscountFactor(_discountFactorInBasisPoints) onlySetter {
        require(
            _discountFactorInBasisPoints != discountFactorInBasisPoints,
            Errors.VALUE_ALREADY_SET
        );
        discountFactorInBasisPoints = _discountFactorInBasisPoints;
        emit DiscountFactorUpdated(_discountFactorInBasisPoints);
    }
}
