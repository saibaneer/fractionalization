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

    // modifier valueChanged(
    //     address _addr,
    //     uint256 _numerator,
    //     uint256 _denominator
    // ) {
    //     require(
    //         addressToExchangeRate[_addr].numerator != _numerator ||
    //             addressToExchangeRate[_addr].denominator != _denominator,
    //         Errors.VALUE_ALREADY_SET
    //     );
    //     _;
    // }

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
    ) public differentValue(isAllowedToken[_token], _status) onlySetter {
        isAllowedToken[_token] = _status;
        emit AllowedTokenUpdated(_token, _status);
    }

    /// @notice Changes the vault address to a new one
    /// @dev Emits a VaultAddressUpdated event, capturing the old and new addresses
    /// @param _vaultAddress The new vault address to set
    function setVaultAddress(
        address _vaultAddress
    ) public notZeroAddress(_vaultAddress) onlySetter {
        require(_vaultAddress != vaultAddress, Errors.VALUE_ALREADY_SET);
        address oldVaultAddress = vaultAddress;
        vaultAddress = _vaultAddress;
        // Invariant to check vault address change correctly applied
        assert(
            vaultAddress == _vaultAddress && vaultAddress != oldVaultAddress
        );
        emit VaultAddressUpdated(_vaultAddress, oldVaultAddress);

        
    }

    function setFactoryAddress(
        address _factoryAddress
    ) public notZeroAddress(_factoryAddress) onlySetter {
        require(_factoryAddress != assetFactoryAddress, Errors.VALUE_ALREADY_SET);
        address oldFactoryAddress = assetFactoryAddress;
        assetFactoryAddress = _factoryAddress;
        // Invariant to check vault address change correctly applied
        assert(
            assetFactoryAddress == _factoryAddress && assetFactoryAddress != oldFactoryAddress
        );
        emit VaultAddressUpdated(_factoryAddress, oldFactoryAddress);

        
    }
}
