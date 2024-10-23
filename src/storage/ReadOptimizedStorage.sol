// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {StorageKey} from "src/types/CustomTypes.sol";

/*
 * @title ReadOptimizedStorage
 * @dev Library for storing data in a read-optimized storage contract. The idea is to store data in a contract code and when
 * reading the data, copy it to transient storage. This is useful when you need to store data that is not going to
 * change often but you need to read it frequently.
 */
library ReadOptimizedStorage {
    bytes32 private constant _STORAGE_CONTRACT = keccak256("src.repository.ReadOptimizedStorage.StorageContractSlot");
    bytes32 private constant _UNCOMMITTED_KEY_ARRAY =
        keccak256("src.repository.ReadOptimizedStorage.UncommittedKeyArray");

    /*
     * @dev Write a uint256 value to the read-optimized storage
     * @param _key The key to write
     * @param _value The value to write
     */
    function writeUint256(StorageKey _key, uint256 _value) internal {
        writeBytes32(_key, bytes32(_value));
    }

    /*
     * @dev Read a uint256 value from the read-optimized storage
     * @param _key The key to read
     * @return value The value stored in the key
     */
    function readUint256(StorageKey _key) internal returns (uint256 value) {
        assembly {
            value := tload(_key)
        }
        if (value != 0) {
            return value;
        }
        if (copyToTransientStorage()) {
            assembly {
                value := tload(_key)
            }
        }
    }

    /*
     * @dev Write an address value to the read-optimized storage
     * @param _key The key to write
     * @param _value The value to write
     */
    function writeAddress(StorageKey _key, address _value) internal {
        writeBytes32(_key, bytes32(uint256(uint160(_value))));
    }

    /*
     * @dev Read an address value from the read-optimized storage
     * @param _key The key to read
     * @return value The value stored in the key
     */
    function readAddress(StorageKey _key) internal returns (address value) {
        assembly {
            value := tload(_key)
        }
        if (value != address(0)) {
            return value;
        }
        if (copyToTransientStorage()) {
            assembly {
                value := tload(_key)
            }
        }
    }

    /*
     * @dev Write a bytes32 value to the read-optimized storage
     * @param _key The key to write
     * @param _value The value to write
     */
    function writeBytes32(StorageKey _key, bytes32 _value) internal {
        store(_key, _value);
    }

    /*
     * @dev Read a bytes32 value from the read-optimized storage
     * @param _key The key to read
     * @return value The value stored in the key
     */
    function readBytes32(StorageKey _key) internal returns (bytes32 value) {
        assembly {
            value := tload(_key)
        }
        if (value != bytes32(0)) {
            return value;
        }
        if (copyToTransientStorage()) {
            assembly {
                value := tload(_key)
            }
        }
    }

    /*
     * @dev Copy the data from the read-optimized storage to the transient storage
     * @return true if the data was copied, false otherwise
     */
    function copyToTransientStorage() private returns (bool) {
        bytes32 location = _STORAGE_CONTRACT;
        address storageContract;
        assembly {
            storageContract := tload(location)
        }

        if (storageContract != address(0)) {
            return false;
        }

        assembly {
            storageContract := sload(location)
            tstore(location, storageContract)
        }

        require(storageContract != address(0));

        uint256 size;
        assembly {
            size := extcodesize(storageContract)
        }

        bytes memory code = new bytes(size);
        assembly {
            extcodecopy(storageContract, add(code, 0x20), 0, size)
        }

        (bytes32[] memory keys, bytes32[] memory values) = abi.decode(code, (bytes32[], bytes32[]));

        assembly {
            let keysLength := mload(keys)
            let keysPtr := add(keys, 0x20)
            let valuesPtr := add(values, 0x20)
            let end := add(keysPtr, mul(keysLength, 0x20))

            for {} lt(keysPtr, end) {
                keysPtr := add(keysPtr, 0x20)
                valuesPtr := add(valuesPtr, 0x20)
            } {
                let key := mload(keysPtr)
                let value := mload(valuesPtr)
                tstore(key, value)
            }
        }

        return true;
    }

    /*
     * @dev Store a key-value pair in the transient storage. If want to store eternally, call `commit()`.
     * @param _key The key to store
     * @param _value The value to store
     */
    function store(StorageKey _key, bytes32 _value) private {
        bytes32 location = _UNCOMMITTED_KEY_ARRAY;
        assembly {
            let freeKeyPointer := tload(location)
            if iszero(freeKeyPointer) { freeKeyPointer := location }
            freeKeyPointer := add(freeKeyPointer, 0x20)
            tstore(location, freeKeyPointer)
            tstore(freeKeyPointer, _key)

            // Store value
            tstore(_key, _value)
        }
    }

    /*
     * @dev Get the key array from the transient storage
     * @return keys The keys stored in the transient storage to commit to the read-optimized storage
     */
    function getKeysFromTransientStorage() internal view returns (StorageKey[] memory keys) {
        bytes32 location = _UNCOMMITTED_KEY_ARRAY;
        assembly {
            let freeKeyPointer := tload(location)
            if freeKeyPointer {
                let keysLength := div(sub(freeKeyPointer, location), 0x20)
                keys := mload(0x40)
                mstore(keys, keysLength)
                mstore(0x40, add(keys, add(sub(freeKeyPointer, location), 0x20))) // Update free memory pointer

                let keyPointer := location
                for { let i := 1 } lt(i, add(keysLength, 1)) { i := add(i, 1) } {
                    keyPointer := add(keyPointer, 0x20)
                    mstore(add(keys, mul(i, 0x20)), tload(keyPointer))
                }
            }
        }
    }

    /*
     * @dev Commit the data stored in the transient storage to the read-optimized storage
     */
    function commit() internal {
        bytes32 location = _STORAGE_CONTRACT;
        StorageKey[] memory newKeys = getKeysFromTransientStorage();
        bytes32[] memory keys;
        bytes32[] memory values;
        {
            address storageContract;
            uint256 size;
            assembly {
                storageContract := sload(location)
                size := extcodesize(storageContract)
            }

            if (size > 0) {
                bytes memory code = new bytes(size);
                assembly {
                    extcodecopy(storageContract, add(code, 0x20), 0, size)
                }
                (keys, values) = abi.decode(code, (bytes32[], bytes32[]));
            }

            uint256 emptyIndex = keys.length;

            keys = copyBytes32Array(keys, int256(newKeys.length));
            values = copyBytes32Array(values, int256(newKeys.length));

            for (uint256 newKeyIndex = 0; newKeyIndex < newKeys.length; newKeyIndex++) {
                bytes32 key = StorageKey.unwrap(newKeys[newKeyIndex]);
                bytes32 value;
                assembly {
                    value := tload(key)
                }
                bool found;
                for (uint256 i = 0; i < keys.length; i++) {
                    if (keys[i] == key) {
                        values[i] = value;
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    keys[emptyIndex] = key;
                    values[emptyIndex] = value;
                    emptyIndex++;
                }
            }

            assembly {
                mstore(keys, emptyIndex)
                mstore(values, emptyIndex)
            }
        }

        bytes memory newCode = createContractCreationCode(abi.encode(keys, values));
        assembly {
            // Create new storage contract
            let newStorageContract := create(0, add(newCode, 0x20), mload(newCode))
            sstore(location, newStorageContract)

            // Copy the new storage to transient storage
            let keysLength := mload(keys)
            let keysPtr := add(keys, 0x20)
            let valuesPtr := add(values, 0x20)
            let end := add(keysPtr, mul(keysLength, 0x20))

            for {} lt(keysPtr, end) {
                keysPtr := add(keysPtr, 0x20)
                valuesPtr := add(valuesPtr, 0x20)
            } {
                let key := mload(keysPtr)
                let value := mload(valuesPtr)
                tstore(key, value)
                sstore(key, value) // This is only for Extsload
            }
        }
    }

    /*
     * @dev Create the contract creation code for the new storage contract
     * @param _code The code to store in the new storage contract
     * @return result The contract creation code
     */
    function createContractCreationCode(bytes memory _code) private pure returns (bytes memory) {
        return abi.encodePacked(hex"63", uint32(_code.length), hex"80600E6000396000F3", _code);
    }

    /*
     * @dev Copy a bytes32 array
     * @param source The source array to copy
     * @return destination The copied array
     */
    function copyBytes32Array(bytes32[] memory source, int256 sizeDelta) private pure returns (bytes32[] memory) {
        bytes32[] memory destination = sizeDelta > 0
            ? new bytes32[](source.length + uint256(sizeDelta))
            : new bytes32[](source.length - uint256(-1 * sizeDelta));

        assembly {
            let length := mload(source)
            let src := add(source, 0x20)
            let dest := add(destination, 0x20)
            for { let end := add(src, mul(length, 0x20)) } lt(src, end) {
                src := add(src, 0x20)
                dest := add(dest, 0x20)
            } { mstore(dest, mload(src)) }
        }
        return destination;
    }
}
