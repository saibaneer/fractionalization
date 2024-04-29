// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Storage.sol";
import "./libraries/Errors.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract InternalLogic is Storage {

    using SafeERC20 for IERC20;


    /// @notice Enters a position for an asset with specific units
    /// @dev Transfers the specified units from the caller to the vault
    /// @param _assetAddress The address of the asset to enter position
    /// @param _tokenAddress The address of the token used for the position
    /// @param _caller The address of the caller entering the position
    /// @param units The number of units for the position
    function _enterPosition(
        address _assetAddress,
        address _tokenAddress,
        address _caller,
        uint units
    ) internal {
        require(!positionHasExited[_assetAddress], Errors.POSITION_HAS_EXITED);
        require(allowedTokens[_tokenAddress], Errors.TOKEN_NOT_ALLOWED);
        require(vaultAddress != address(0), Errors.VAULT_ADDRESS_NOT_SET);
        require(units > 0, Errors.INVALID_UNITS);
        require(_caller != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
        require(addressToUrl[_assetAddress].length > 0, Errors.ASSET_DOES_NOT_EXIST);

        IERC20 depositToken = IERC20(_tokenAddress);
        uint256 initialCallerBalance = depositToken.balanceOf(_caller);
        uint256 initialVaultBalance = depositToken.balanceOf(vaultAddress);

        depositToken.safeTransferFrom(_caller, vaultAddress, units);

        IERC20 assetToken = IERC20(_assetAddress);
        assetToken.safeTransfer(_caller, units); // has to be called 

        // Invariants to ensure tokens are correctly transferred
        assert(depositToken.balanceOf(_caller) == initialCallerBalance - units);
        assert(depositToken.balanceOf(vaultAddress) == initialVaultBalance + units);
        assert(assetToken.balanceOf(_caller) >= units);  // Assuming assetToken starts from zero or increases


        _grantRole(HOLDER, _caller);
        
    }

    /// @notice Exits a position for an asset with specific units
    /// @dev Handles the asset and token transfer based on the defined exchange rate and discount
    /// @param _assetAddress The address of the asset to exit position
    /// @param _tokenAddress The address of the token used for settling the position
    /// @param _caller The address of the caller exiting the position
    /// @param units The number of units to exit
    function _exitPosition(
        address _assetAddress,
        address _tokenAddress,
        address _caller,
        uint units
    ) internal onlyHolder {
        // get exchange rate
        Structs.ExchangeRate memory exchangeRate = addressToExchangeRate[_assetAddress];
        require(exchangeRate.numerator > 0, Errors.EXCHANGE_RATE_NOT_SET);
        require(exchangeRate.denominator > 0, Errors.EXCHANGE_RATE_NOT_SET);
        require(_tokenAddress != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
        require(_assetAddress != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
        require(allowedTokens[_tokenAddress], Errors.TOKEN_NOT_ALLOWED);
        require(discountFactorInBasisPoints > 99, Errors.BAD_DISCOUNT_FACTOR);
        require(units > 0, Errors.INVALID_UNITS);
        IERC20 assetToken = IERC20(_assetAddress);
        IERC20 depositToken = IERC20(_tokenAddress);
        require(assetToken.balanceOf(_caller) >= units, Errors.INVALID_UNITS);

        uint256 initialCallerAssetBalance = assetToken.balanceOf(_caller);
        uint256 initialVaultDepositBalance = depositToken.balanceOf(vaultAddress);
        

        // calculate units
        uint256 correspondingStableValueDue = (units * exchangeRate.numerator) / exchangeRate.denominator;
        if(!positionHasExited[_assetAddress]) {
            correspondingStableValueDue = (correspondingStableValueDue * discountFactorInBasisPoints) / 10000;
            depositToken.safeTransfer(_caller, correspondingStableValueDue);

            // Invariants to check if the balances are adjusted correctly
            assert(depositToken.balanceOf(vaultAddress) == initialVaultDepositBalance - correspondingStableValueDue);
            assert(assetToken.balanceOf(_caller) == initialCallerAssetBalance - units);
        } else {
            depositToken.safeTransfer(_caller, correspondingStableValueDue);
            // Invariants to check if the balances are adjusted correctly
            assert(depositToken.balanceOf(vaultAddress) == initialVaultDepositBalance - correspondingStableValueDue);
            assert(assetToken.balanceOf(_caller) == initialCallerAssetBalance - units);
        }

        if(assetToken.balanceOf(_caller) == 0) {
            _revokeRole(HOLDER, _caller);
        }

    }

    
}
