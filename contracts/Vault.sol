// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Storage.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Vault
/// @dev Manages token withdrawals, holding the core financial logic.
contract Vault is ReentrancyGuard, Storage {

    constructor() ReentrancyGuard() {}

    using SafeERC20 for IERC20;

    /// @notice Withdraws tokens to a specified recipient
    /// @param _tokenAddress The address of the token to withdraw
    /// @param _recipient The address of the recipient
    /// @param amount The amount of tokens to withdraw
    function withdrawTo(address _tokenAddress, address _recipient, uint256 amount) public onlyMultisigController nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(_tokenAddress != address(0), "Token address cannot be 0");
        require(_recipient != address(0), "Recipient address cannot be 0");

        IERC20 depositToken = IERC20(_tokenAddress);
        uint256 initialVaultBalance = depositToken.balanceOf(address(this));
        uint256 initialRecipientBalance = depositToken.balanceOf(_recipient);
        depositToken.safeTransfer(_recipient, amount);

        // Invariants to ensure tokens are correctly debited and credited
        assert(depositToken.balanceOf(address(this)) == initialVaultBalance - amount);
        assert(depositToken.balanceOf(_recipient) == initialRecipientBalance + amount);
    }

    /// @notice Gets the balance of tokens held by the contract for a specified token
    /// @param _tokenAddress The address of the token to query
    /// @return The token balance
    function getBalance(address _tokenAddress) public view returns (uint256) {
        IERC20 depositToken = IERC20(_tokenAddress);
        return depositToken.balanceOf(address(this));
    }

}