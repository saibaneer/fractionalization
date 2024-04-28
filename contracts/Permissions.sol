// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./libraries/Errors.sol";

/// @title Permissions
/// @notice Manages roles and permissions within the platform, utilizing OpenZeppelin's Access Control.
/// @dev This contract extends OpenZeppelin's AccessControl to provide role-based permissions across the system.
abstract contract Permissions is AccessControl {
    
    /// @notice Role identifier for asset holders.
    bytes32 public constant HOLDER = keccak256("HOLDER");
    
    /// @notice Role identifier for those allowed to manage setters.
    bytes32 public constant SETTER_MANAGER_ROLE = keccak256("SETTER_MANAGER_ROLE");
    
    /// @notice Role identifier for administrative privileges.
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    /// @notice Role identifier for multisig operations controllers.
    bytes32 public constant MULTISIG_CONTROLLER_ROLE = keccak256("MULTISIG_CONTROLLER_ROLE");

    /// @dev Modifier to restrict functions to users with the Setter role.
    modifier onlySetter() {
        require(hasSetterRole(msg.sender), Errors.NO_SETTER_ROLE);
        _;
    }

    /// @dev Modifier to restrict functions to users with the Admin role.
    modifier onlyAdmin() {
        require(hasAdminRole(msg.sender), Errors.NO_ADMIN_ROLE);
        _;
    }

    /// @dev Modifier to restrict functions to users with the Multisig Controller role.
    modifier onlyMultisigController() {
        require(hasMultisigControllerRole(msg.sender), Errors.NO_MULTISIG_CONTROLLER_ROLE);
        _;
    }

    /// @dev Modifier to restrict functions to users who are asset holders.
    modifier onlyHolder() {
        require(hasHolderRole(msg.sender), Errors.NO_HOLDER_ROLE);
        _;
    }

    /// @notice Checks if an address has the Setter role.
    /// @param _address The address to check.
    /// @return bool True if the address has the Setter role, false otherwise.
    function hasSetterRole(address _address) public view returns(bool) {
        return hasRole(SETTER_MANAGER_ROLE, _address);
    }

    /// @notice Checks if an address has the Admin role.
    /// @param _address The address to check.
    /// @return bool True if the address has the Admin role, false otherwise.
    function hasAdminRole(address _address) public view returns(bool) {
        return hasRole(ADMIN_ROLE, _address);
    }

    /// @notice Checks if an address has the Multisig Controller role.
    /// @param _address The address to check.
    /// @return bool True if the address has the Multisig Controller role, false otherwise.
    function hasMultisigControllerRole(address _address) public view returns(bool) {
        return hasRole(MULTISIG_CONTROLLER_ROLE, _address);
    }

    /// @notice Checks if an address is an asset holder.
    /// @param _address The address to check.
    /// @return bool True if the address is an asset holder, false otherwise.
    function hasHolderRole(address _address) public view returns(bool) {
        return hasRole(HOLDER, _address);
    }
}
