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

    struct ExchangeRate {
        uint256 numerator;
        uint256 denominator;
    }



    
}

