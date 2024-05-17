// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


import "./libraries/Structs.sol";

abstract contract SupplementaryStorage {

    mapping(address userAddress => Structs.Position[]) internal userToPosition;


    mapping(bytes32 positionHash => Structs.Position) public positionHashToAsset;


    function getUserPositions(address userAddress) public view returns(Structs.Position[] memory) {
        return userToPosition[userAddress];
    }

}