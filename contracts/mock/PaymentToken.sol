// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PaymentERC20 is ERC20 {

 
    constructor(uint256 units) ERC20("PayToken", "PAY") {
        // maxSupply = units;
        _mint(msg.sender, units * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public {
        //add modifier 
        // require(totalSupply() + amount <= maxSupply, "ModelERC20: max supply exceeded");
        _mint(to, amount);
    }
}