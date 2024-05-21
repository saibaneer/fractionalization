// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../contracts/FactoryInternalLogic.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract AssetFactory is ReentrancyGuard, FactoryInternalLogic {



//TODO: Add modifiers to restrict access to functions
    constructor() ReentrancyGuard() {
        _grantRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, ADMIN_ROLE);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SETTER_MANAGER_ROLE, msg.sender);
        // _grantRole(MULTISIG_CONTROLLER_ROLE, _multiSigController);
    }
    
    function createNewAsset(Structs.Asset calldata _asset) public nonReentrant {
        _createNewAsset(_asset);
    }

    function updateAssetUrl(
        address _assetAddress,
        string calldata _url
    ) public {
        _updateAssetUrl(_assetAddress, _url);
    }

    function getAssetUrl(
        address _assetAddress
    ) public view returns (string memory) {
        require(_assetAddress != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
        return Utils.decodeString(addressToUrl[_assetAddress]);
    }

    function getAsset(
        address _assetAddress
    ) public  view returns (Structs.Asset memory) {
        require(_assetAddress != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);
        return addressToAsset[_assetAddress];
    }

    function deleteAsset(address _assetAddress) public {
        _deleteAsset(_assetAddress);
    }
}
