// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


library Structs {

    struct Asset {
        uint256 units;
        address assetAddress;
        string assetName;
        string assetSymbol;
        string assetUrl;
    }

    // struct ExchangeRate {
    //     uint256 numerator;
    //     uint256 denominator;
    // }


    struct Position {
        bytes32 hashId;
        address assetAddress;
        address preferredTokenForSale;
        address owner;
        uint256 units;
        uint256 price;
        uint256 nonce;
    }


    function reduceUnits(Position storage self, uint256 newUnits) internal {
        require(newUnits > 0, "Structs: Units should be greater than 0");
        require(self.units - newUnits > 0, "Structs: Reduce units!");
        self.units = self.units - newUnits;
    }


    
}

