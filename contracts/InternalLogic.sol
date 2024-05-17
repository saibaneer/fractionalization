// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Storage.sol";
import "./libraries/Errors.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./SupplementaryEntryPointStorage.sol";



abstract contract InternalLogic is SupplementaryStorage, Storage {
    using SafeERC20 for IERC20;

    event EnteredPosition(
        address indexed assetAddress,
        address indexed tokenAddress,
        address indexed caller,
        uint units
    );

    event ListedPositionForSale(
        address indexed assetAddress,
        address indexed tokenAddress,
        address indexed caller,
        uint units,
        uint price,
        bytes32 positionHash
    );

    event BoughtPosition(
        address indexed assetAddress,
        address indexed tokenAddress,
        address indexed caller,
        uint units,
        uint price,
        bytes32 positionHash
    );

    event DelistedPosition(
        address indexed assetAddress,
        address indexed tokenAddress,
        address indexed caller,
        uint units,
        bytes32 positionHash
    );

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
        require(isAllowedToken[_tokenAddress], Errors.TOKEN_NOT_ALLOWED);
        require(vaultAddress != address(0), Errors.VAULT_ADDRESS_NOT_SET);
        require(units > 0, Errors.INVALID_UNITS);
        require(_caller != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
        string memory url = IAssetFactory(assetFactoryAddress).getAssetUrl(_assetAddress);
        require(
            bytes(url).length > 0,
            Errors.ASSET_DOES_NOT_EXIST
        );

        IERC20 depositToken = IERC20(_tokenAddress);
        uint256 initialCallerBalance = depositToken.balanceOf(_caller);
        uint256 initialVaultBalance = depositToken.balanceOf(vaultAddress);

        depositToken.safeTransferFrom(_caller, vaultAddress, units);

        IERC20 assetToken = IERC20(_assetAddress);
        IModelERC20(_assetAddress).mint(_caller, units); // has to be called

        // Invariants to ensure tokens are correctly transferred
        assert(depositToken.balanceOf(_caller) == initialCallerBalance - units);
        assert(
            depositToken.balanceOf(vaultAddress) == initialVaultBalance + units
        );
        assert(assetToken.balanceOf(_caller) >= units); // Assuming assetToken starts from zero or increases

        _grantRole(HOLDER, _caller);
        emit EnteredPosition(_assetAddress, _tokenAddress, _caller, units);
    }

    // / @notice Exits a position for an asset with specific units
    // / @dev Handles the asset and token transfer based on the defined exchange rate and discount
    // / @param _assetAddress The address of the asset to exit position
    // / @param _tokenAddress The address of the token used for settling the position
    // / @param _caller The address of the caller exiting the position
    // / @param units The number of units to exit
    // function _exitPosition(
    //     address _assetAddress,
    //     address _tokenAddress,
    //     address _caller,
    //     uint units
    // ) internal onlyHolder {
    //     // get exchange rate
    //     Structs.ExchangeRate memory exchangeRate = addressToExchangeRate[
    //         _assetAddress
    //     ];
    //     require(exchangeRate.numerator > 0, Errors.EXCHANGE_RATE_NOT_SET);
    //     require(exchangeRate.denominator > 0, Errors.EXCHANGE_RATE_NOT_SET);
    //     require(_tokenAddress != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
    //     require(_assetAddress != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
    //     require(isAllowedToken[_tokenAddress], Errors.TOKEN_NOT_ALLOWED);
    //     require(discountFactorInBasisPoints > 99, Errors.BAD_DISCOUNT_FACTOR);
    //     require(units > 0, Errors.INVALID_UNITS);
    //     IERC20 assetToken = IERC20(_assetAddress);
    //     IERC20 depositToken = IERC20(_tokenAddress);
    //     require(assetToken.balanceOf(_caller) >= units, Errors.INVALID_UNITS);

    //     uint256 initialCallerAssetBalance = assetToken.balanceOf(_caller);
    //     uint256 initialVaultDepositBalance = depositToken.balanceOf(
    //         vaultAddress
    //     );

    //     // calculate units
    //     uint256 correspondingStableValueDue = (units * exchangeRate.numerator) /
    //         exchangeRate.denominator;
    //     if (!positionHasExited[_assetAddress]) {
    //         correspondingStableValueDue =
    //             (correspondingStableValueDue * discountFactorInBasisPoints) /
    //             10000;
    //         depositToken.safeTransfer(_caller, correspondingStableValueDue);
    //         assetToken.safeTransferFrom(_caller, address(assetToken), units);

    //         // Invariants to check if the balances are adjusted correctly
    //         assert(
    //             depositToken.balanceOf(vaultAddress) ==
    //                 initialVaultDepositBalance - correspondingStableValueDue
    //         );
    //         assert(
    //             assetToken.balanceOf(_caller) ==
    //                 initialCallerAssetBalance - units
    //         );
    //     } else {
    //         depositToken.safeTransfer(_caller, correspondingStableValueDue);
    //         assetToken.safeTransferFrom(_caller, address(assetToken), units);
    //         // Invariants to check if the balances are adjusted correctly
    //         assert(
    //             depositToken.balanceOf(vaultAddress) ==
    //                 initialVaultDepositBalance - correspondingStableValueDue
    //         );
    //         assert(
    //             assetToken.balanceOf(_caller) ==
    //                 initialCallerAssetBalance - units
    //         );
    //     }

    //     if (assetToken.balanceOf(_caller) == 0) {
    //         _revokeRole(HOLDER, _caller);
    //     }
    // }

    function _listPositionForSale(
        address _assetAddress,
        address _preferredToken,
        address _caller,
        uint units,
        uint price
    ) internal {
        require(!positionHasExited[_assetAddress], Errors.POSITION_HAS_EXITED);
        require(isAllowedToken[_preferredToken], Errors.TOKEN_NOT_ALLOWED);
        require(_assetAddress != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
        require(_preferredToken != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
        require(units > 0, Errors.INVALID_UNITS);
        string memory url = IAssetFactory(assetFactoryAddress).getAssetUrl(_assetAddress);
        require(
            bytes(url).length > 0,
            Errors.ASSET_DOES_NOT_EXIST
        );

        IERC20 assetToken = IERC20(_assetAddress);

        require(
            assetToken.balanceOf(_caller) >= units,
            Errors.INVALID_UNITS
        );

        //create a hash_id for the position created
        bytes32 hash_id = keccak256(
            abi.encode(_assetAddress, _preferredToken, units, nonce)
        );
        nonce += 1;

        positionHashToAsset[hash_id] = Structs.Position({
            hashId: hash_id,
            assetAddress: _assetAddress,
            preferredTokenForSale: _preferredToken,
            owner: _caller,
            units: units,
            nonce: nonce,
            price: price
        });

        uint256 initialCallerAssetBalance = assetToken.balanceOf(_caller);

        assetToken.safeTransferFrom(_caller, address(this), units);

        // Invariants to check if the balances are adjusted correctly
        assert(
            assetToken.balanceOf(_caller) ==
                initialCallerAssetBalance - units
        );

        userToPosition[_caller].push(positionHashToAsset[hash_id]);
        emit ListedPositionForSale(
            _assetAddress,
            _preferredToken,
            _caller,
            units,
            price,
            hash_id
        );
    }

    function _delistAsset(bytes32 positionHash, address _calller, uint units) internal {
        Structs.Position storage position = positionHashToAsset[positionHash];
        require(
            position.assetAddress != address(0),
            Errors.ASSET_DOES_NOT_EXIST
        );

        require(
            position.owner == _calller,
            Errors.ONLY_OWNER_CAN_DELIST
        );

        IERC20 assetToken = IERC20(position.assetAddress);

        require(
            assetToken.balanceOf(address(this)) >= units,
            Errors.INSUFFICIENT_AMOUNT_IN_CONTRACT
        );
        Structs.Position memory position_m = position;
        if (position.units == units) {
            for (uint i = 0; i < userToPosition[position.owner].length; i++) {
                if (userToPosition[position.owner][i].hashId == positionHash) {
                    userToPosition[position.owner][i] = userToPosition[
                        position.owner
                    ][userToPosition[position.owner].length - 1];
                    userToPosition[position.owner].pop();
                    break;
                }
            }
            delete positionHashToAsset[positionHash];
            _revokeRole(HOLDER, position.owner);
        } else {
            Structs.reduceUnits(position, units);
            for(uint i = 0; i < userToPosition[position.owner].length; i++) {
                if(userToPosition[position.owner][i].hashId == positionHash) {
                    Structs.reduceUnits(userToPosition[position.owner][i], units);
                    break;
                }
            }
        }

        assetToken.safeTransfer(_calller, units);

        if (assetToken.balanceOf(_calller) > 0) {
            _grantRole(HOLDER, _calller);
        }

        emit DelistedPosition(
            position_m.assetAddress,
            position_m.preferredTokenForSale,
            _calller,
            units,
            positionHash
        );
    }

    function _buyPosition(bytes32 positionHash,address _caller, uint units) internal {
        Structs.Position storage position = positionHashToAsset[positionHash];
        require(
            position.assetAddress != address(0),
            Errors.ASSET_DOES_NOT_EXIST
        );

        uint value = (units * position.price)/10_000; // to get value corrected for basis points.

        IERC20 assetToken = IERC20(position.assetAddress);
        IERC20 preferredToken = IERC20(position.preferredTokenForSale);

        require(
            preferredToken.balanceOf(_caller) >= value,
            Errors.INSUFFICIENT_BALANCE
        );
        Structs.Position memory position_m  = position;
        if (position.units == units) {
            for (uint i = 0; i < userToPosition[position.owner].length; i++) {
                if (userToPosition[position.owner][i].hashId == positionHash) {
                    userToPosition[position.owner][i] = userToPosition[
                        position.owner
                    ][userToPosition[position.owner].length - 1];
                    userToPosition[position.owner].pop();
                    break;
                }
            }
            delete positionHashToAsset[positionHash];
            _revokeRole(HOLDER, position.owner);
            
        } else {
            Structs.reduceUnits(position, units);
            Structs.reduceUnits(positionHashToAsset[positionHash], units);
        }
    
        preferredToken.safeTransferFrom(_caller, position_m.owner, value);
        assetToken.safeTransfer(_caller, units);

        if (assetToken.balanceOf(_caller) > 0) {
            _grantRole(HOLDER, _caller);
        }
        emit BoughtPosition(
            position.assetAddress,
            position.preferredTokenForSale,
            _caller,
            units,
            position.price,
            positionHash
        );
    }
}

interface IModelERC20 {
    function mint(address to, uint256 amount) external;
}

interface IAssetFactory {
    function getAssetUrl(address _assetAddress) external view returns (string memory);
}
