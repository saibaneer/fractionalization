// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./InternalLogic.sol";
import "./Getters.sol";
import "./Setters.sol";

contract EntryPoint is Setters, Getters, InternalLogic {

    constructor(address _multiSigController){
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
    ) public {
        _enterPosition(_assetAddress, _tokenAddress, msg.sender, units);
    }

    function exitPosition(
        address _assetAddress,
        address _tokenAddress,
        uint units
    ) public {
        _exitPosition(_assetAddress, _tokenAddress, msg.sender, units);
    }

    

}
