// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


import "./libraries/Structs.sol";

abstract contract SupplementaryStorage {

    mapping(address userAddress => Structs.Position[]) public userToPosition;


    mapping(bytes32 positionHash => Structs.Position) internal positionHashToAsset;

}