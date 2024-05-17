// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


library Errors {

    string internal constant VALUE_ALREADY_SET = "Value already has this status";
    string internal constant INVALID_UNITS = "Units must be greater than 0";
    string internal constant ADDRESS_MUST_BE_EMPTY = "Asset address must be 0x0";
    string internal constant ADDRESS_ZERO_NOT_ALLOWED = "Asset address must not be 0x0";
    string internal constant BAD_ASSET_NAME = "Asset name must not be empty";
    string internal constant BAD_ASSET_SYMBOL = "Asset symbol must be between 2 and 4 characters";
    string internal constant BAD_ASSET_URL = "Asset url must not be empty";
    string internal constant TOKEN_NOT_ALLOWED = "Token not allowed";
    string internal constant VAULT_ADDRESS_NOT_SET = "Vault address not set";
    string internal constant ASSET_DOES_NOT_EXIST = "Asset does not exist";
    string internal constant POSITION_HAS_EXITED = "Position has exited";
    string internal constant EXCHANGE_RATE_NOT_SET = "Exchange rate not set";
    string internal constant BAD_DISCOUNT_FACTOR = "Discount factor must be greater than 99";
    string internal constant NO_SETTER_ROLE = "Not Authorized to set function";
    string internal constant NO_ADMIN_ROLE = "Not Authorized to call function";
    string internal constant NO_MULTISIG_CONTROLLER_ROLE = "Bad Multisig Controller Role";
    string internal constant NO_HOLDER_ROLE = "Not Authorized";
    string internal constant INSUFFICIENT_BALANCE = "Insufficient balance";
    string internal constant ONLY_OWNER_CAN_DELIST = "Only owner can delist";
    string internal constant INSUFFICIENT_AMOUNT_IN_CONTRACT = "Insufficient amount in contract";
}

