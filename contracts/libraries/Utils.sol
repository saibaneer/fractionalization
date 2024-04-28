// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

library Utils {


    function encodeString(string memory _string) internal pure returns (bytes memory) {
        return abi.encode(_string);
    }

    function decodeString(bytes memory _payload) internal pure returns(string memory) {
        return abi.decode(_payload, (string));
    }
    
}