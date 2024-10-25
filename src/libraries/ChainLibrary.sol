// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IExtsload} from "src/interfaces/IExtsload.sol";

import {ChainId, StorageKey} from "src/types/CustomTypes.sol";
import {StorageKeyLibrary} from "src/libraries/StorageKeyLibrary.sol";
import {ReadOptimizedStorage} from "src/storage/ReadOptimizedStorage.sol";

/*
 * @title ChainLibrary
 * @dev Library for chain configuration
 */
library ChainLibrary {
    using ReadOptimizedStorage for StorageKey;
    using StorageKeyLibrary for StorageKey;

    StorageKey private constant _LIBRARY_UNIQUE_KEY = StorageKey.wrap(keccak256("src.libraries.ChainLibrary"));

    // @dev Same as below
    // mapping(ChainId => uint256) chainConfig;

    /*
     * @dev Set minimum confirmation for chainId
     * @param chainId ChainId
     * @param minimumConfirmation Minimum necessary confirmation count
     */
    function setMinimumConfirmation(ChainId chainId, uint256 minimumConfirmation) internal {
        // 0. Get storage key from chainId
        StorageKey key = _LIBRARY_UNIQUE_KEY.derive(chainId);

        // 1. Write minimumConfirmation to storage
        key.writeUint256(minimumConfirmation);
    }

    /*
     * @dev Validate confirmation count
     * @param chainId ChainId
     * @param confirmation Confirmation count
     */
    function validateConfirmation(ChainId chainId, uint256 confirmation) internal {
        // 0. Get storage key from chainId
        StorageKey key = _LIBRARY_UNIQUE_KEY.derive(chainId);

        // 1. Read chain config from storage
        uint256 minimumConfirmation = key.readUint256();

        // 2. Validate config
        require(minimumConfirmation >= 1, "ChainLibrary: Unregistered chainId");
        require(confirmation >= minimumConfirmation, "ChainLibrary: invalid confirmation");
    }

    /*
     * @dev Check if the chainId is this chain id
     * @param chainId Target chainId
     */
    function validateTargetChain(ChainId chainId) internal view {
        require(ChainId.unwrap(chainId) == block.chainid, "ChainLibrary: This chain is not target chain");
    }

    /*
     * @dev Query minimum confirmation
     * @param target IExtsload contract to query
     * @param chainId ChainId to query
     */
    function queryMinimumConfirmation(IExtsload target, ChainId chainId) internal view returns (uint256) {
        StorageKey key = _LIBRARY_UNIQUE_KEY.derive(chainId);
        return uint256(target.extsload(key));
    }
}
