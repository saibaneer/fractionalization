// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./InternalLogic.sol";
import "./Getters.sol";
import "./Setters.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract EntryPoint is ReentrancyGuard, Setters, Getters, InternalLogic {

    constructor(address _multiSigController) ReentrancyGuard() {
        _grantRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, ADMIN_ROLE);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SETTER_MANAGER_ROLE, msg.sender);
        _grantRole(MULTISIG_CONTROLLER_ROLE, _multiSigController);
    }
    
    function enterPosition(
        address _assetAddress,
        address _tokenAddress,
        uint units
    ) public nonReentrant {
        _enterPosition(_assetAddress, _tokenAddress, msg.sender, units);
    }

    // function exitPosition(
    //     address _assetAddress,
    //     address _tokenAddress,
    //     uint units
    // ) public nonReentrant {
    //     _exitPosition(_assetAddress, _tokenAddress, msg.sender, units);
    // }

    function listPositionForSale(
        address _assetAddress,
        address _tokenAddress,
        uint units,
        uint pricePerToken
    ) public nonReentrant {
        _listPositionForSale(_assetAddress, _tokenAddress, msg.sender, units, pricePerToken);
    }

    function buyPosition(
        bytes32 positionHash,
        uint units
    ) public nonReentrant {
        _buyPosition(positionHash, msg.sender, units);
    }

    function delistPosition(bytes32 positionHash, uint256 units) public nonReentrant {
        _delistAsset(positionHash, msg.sender, units);
    }
    

}
