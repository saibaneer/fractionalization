// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// import "../contracts/libraries/Structs.sol";
import "../contracts/libraries/Utils.sol";
import "../contracts/libraries/Errors.sol";
import "./mock/ModelERC20.sol";
import "./Storage.sol";

/// @title Factory Internal Logic
/// @notice Manages the creation, update, and deletion of assets within the platform
/// @dev This contract includes internal functions that can only be called by authorized roles
abstract contract FactoryInternalLogic is Storage {

    /// @notice Mapping of asset addresses to their respective URLs for external information.
    mapping(address assetAddress => bytes) internal addressToUrl;

    event CreatedNewAsset(Structs.Asset newAsset);
    

    /// @notice Creates a new asset with given parameters
    /// @dev This function only can be invoked by admins
    /// @param _asset The Struct containing asset details (address, name, symbol, units, URL)
    function _createNewAsset(Structs.Asset calldata _asset) internal onlyAdmin {
        require(_asset.units > 0, Errors.INVALID_UNITS);
        require(
            _asset.assetAddress == address(0),
            Errors.ADDRESS_MUST_BE_EMPTY
        );
        require(bytes(_asset.assetName).length > 0, Errors.BAD_ASSET_NAME);
        require(
            bytes(_asset.assetSymbol).length > 2 &&
                bytes(_asset.assetSymbol).length <= 4,
            Errors.BAD_ASSET_SYMBOL
        );
        require(bytes(_asset.assetUrl).length > 0, Errors.BAD_ASSET_URL);

        address newAsset = address(
            new ModelERC20(_asset.assetName, _asset.assetSymbol, _asset.units)
        );
        Structs.Asset memory asset = _asset;
        bytes memory url = Utils.encodeString(_asset.assetUrl);

        asset.assetAddress = newAsset;
        addressToAsset[newAsset] = asset;
        addressToUrl[newAsset] = url;
        emit CreatedNewAsset(asset);
    }

    /// @notice Updates the URL associated with an asset
    /// @dev This function only can be invoked by admins
    /// @param _assetAddress The address of the asset to be updated
    /// @param _url The new URL to associate with the asset
    
    function _updateAssetUrl(
        address _assetAddress,
        string calldata _url
    ) internal onlyAdmin {
        require(_assetAddress != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
        require(bytes(_url).length > 0, Errors.BAD_ASSET_URL);

        Structs.Asset storage asset = addressToAsset[_assetAddress];
        asset.assetUrl = _url;
        addressToUrl[_assetAddress] = Utils.encodeString(_url);
    }

    /// @notice Deletes an asset from the registry
    /// @dev This function only can be invoked by admins
    /// @param _assetAddress The address of the asset to be deleted
    function _deleteAsset(address _assetAddress) internal onlyAdmin {
        require(_assetAddress != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
        delete addressToAsset[_assetAddress];
        delete addressToUrl[_assetAddress];
    }
    
}