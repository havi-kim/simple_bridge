// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "src/interfaces/IExtsload.sol";

import "src/types/CustomTypes.sol";
import "src/libraries/StorageKeyLibrary.sol";
import "src/storage/InternalStorage.sol";

library MessageIdGenerator {
    using InternalStorage for StorageKey;
    using StorageKeyLibrary for StorageKey;

    StorageKey private constant _LIBRARY_UNIQUE_KEY = StorageKey.wrap(keccak256("src.libraries.MessageIdGenerator"));

    // @dev Same as below
    // uint256 incrementId;

    /**
     * @dev Generate message id
     * @return Message id
     */
    function generate() internal returns (uint256) {
        uint256 incrementId = _LIBRARY_UNIQUE_KEY.readUint256();
        incrementId += 1;
        _LIBRARY_UNIQUE_KEY.writeUint256(incrementId);
        return incrementId;
    }

    /**
     * @dev Query message id
     * @param target The target contract to query
     * @return Message id
     */
    function queryMessageId(IExtsload target) internal view returns (uint256) {
        return uint256(target.extsload(_LIBRARY_UNIQUE_KEY));
    }
}
