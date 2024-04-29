// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ModelERC20 is ERC20 {

    uint256 public maxSupply;
    constructor(string memory name, string memory symbol, uint256 units) ERC20(name, symbol) {
        maxSupply = units;
    }

    function mint(address to, uint256 amount) public {
        //add modifier 
        require(totalSupply() + amount <= maxSupply, "ModelERC20: max supply exceeded");
        _mint(to, amount);
    }
}