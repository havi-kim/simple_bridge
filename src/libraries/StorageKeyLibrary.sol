// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {StorageKey, Token, ChainId} from "src/types/CustomTypes.sol";

/*
 * @title StorageKeyLibrary
 * @dev Library for storage key derivation from seed
 */
library StorageKeyLibrary {
    /*
     * @dev Derive storage key from existing key and address type seed
     * @param _storage StorageKey to derive
     * @param _seed Address type seed to derive
     * @return Derived storage key
     */
    function derive(StorageKey _storage, address _seed) internal pure returns (StorageKey) {
        return StorageKey.wrap(keccak256(abi.encode(_storage, _seed)));
    }

    /*
     * @dev Derive storage key from existing key and bytes32 type seed
     * @param _storage StorageKey to derive
     * @param _seed Bytes32 type seed to derive
     * @return Derived storage key
     */
    function derive(StorageKey _storage, bytes32 _seed) internal pure returns (StorageKey) {
        return StorageKey.wrap(keccak256(abi.encode(_storage, _seed)));
    }

    /*
     * @dev Derive storage key from key and uint256 type seed
     * @param _storage StorageKey to derive
     * @param _seed Uint256 type seed to derive
     * @return Derived storage key
     */
    function derive(StorageKey _storage, uint256 _seed) internal pure returns (StorageKey) {
        return StorageKey.wrap(keccak256(abi.encode(_storage, _seed)));
    }

    /*
     * @dev Derive storage key from key and string type seed
     * @param _storage StorageKey to derive
     * @param _seed String type seed to derive
     * @return Derived storage key
     */
    function derive(StorageKey _storage, string memory _seed) internal pure returns (StorageKey) {
        return StorageKey.wrap(keccak256(abi.encode(_storage, _seed)));
    }

    /*
     * @dev Derive storage key from key and Token type seed
     * @param _storage StorageKey to derive
     * @param _seed Token type seed to derive
     * @return Derived storage key
     */
    function derive(StorageKey _storage, Token _seed) internal pure returns (StorageKey) {
        return StorageKey.wrap(keccak256(abi.encode(_storage, _seed)));
    }

    /*
     * @dev Derive storage key from key and ChainId type seed
     * @param _storage StorageKey to derive
     * @param _seed ChainId type seed to derive
     * @return Derived storage key
     */
    function derive(StorageKey _storage, ChainId _seed) internal pure returns (StorageKey) {
        return StorageKey.wrap(keccak256(abi.encode(_storage, _seed)));
    }

    /*
     * @dev Derive storage key
     * @param _storage StorageKey to derive
     * @param _seed0 ChainId type seed to derive
     * @param _seed1 Uint64 type seed to derive
     * @return Derived storage key
     */
    function derive(StorageKey _storage, ChainId _seed0, uint64 _seed1) internal pure returns (StorageKey) {
        return StorageKey.wrap(keccak256(abi.encode(_storage, _seed0, _seed1)));
    }
}
