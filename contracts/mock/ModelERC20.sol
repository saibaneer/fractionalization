// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ModelERC20 is ERC20 {

    constructor(string memory name, string memory symbol, uint256 units) ERC20(name, symbol) {
        _mint(msg.sender, units * 10 ** decimals());
    }
}