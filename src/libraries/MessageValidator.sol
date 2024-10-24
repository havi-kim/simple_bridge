// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IExtsload} from "src/interfaces/IExtsload.sol";

import {StorageKey} from "src/types/CustomTypes.sol";
import {StorageKeyLibrary} from "src/libraries/StorageKeyLibrary.sol";
import {InternalStorage} from "../storage/InternalStorage.sol";

/**
 * @title MessageValidator
 * @notice Library for preventing replay attack
 */
library MessageValidator {
    using InternalStorage for StorageKey;
    using StorageKeyLibrary for StorageKey;

    struct Request {
        uint data;
        function(uint) external callback;
    }

    StorageKey private constant _LIBRARY_UNIQUE_KEY = StorageKey.wrap(keccak256("src.libraries.MessageLibrary"));

    // @dev Same as below
    // mapping(bytes32 => bool) expiredMessage;

    /**
     * @dev Expire message. This function is called after processing the message. It prevents replay attack.
     * @param messageHash Message hash to expire
     */
    function expire(bytes32 messageHash) internal {
        StorageKey key = _LIBRARY_UNIQUE_KEY.derive(messageHash);
        Request memory request;
        request.data = 1;
        key.writeBool(true);
    }

    /**
     * @dev Validate message. This function is called before processing the message.
     * @param messageHash Message hash to validate
     */
    function validate(bytes32 messageHash) internal view {
        StorageKey key = _LIBRARY_UNIQUE_KEY.derive(messageHash);
        require(!key.readBool(), "MessageLibrary: message expired");
    }

    /**
     * @dev Query message expiration
     * @param target The target contract to query
     * @param messageHash Message hash to query
     * @return Whether the message is expired
     */
    function queryMessageExpired(IExtsload target, bytes32 messageHash) internal view returns (bool) {
        StorageKey key = _LIBRARY_UNIQUE_KEY.derive(messageHash);
        return target.extsload(key) != hex"00";
    }
}
