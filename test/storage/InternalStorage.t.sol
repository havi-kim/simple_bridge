// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {StorageKey} from "src/types/CustomTypes.sol";
import "src/storage/InternalStorage.sol";

contract InternalStorageTest is Test {
    using InternalStorage for StorageKey;

    function setUp() public {
        StorageKey key0 = StorageKey.wrap(keccak256("setup0"));
        StorageKey key1 = StorageKey.wrap(keccak256("setup1"));
        StorageKey key2 = StorageKey.wrap(keccak256("setup2"));
        StorageKey key3 = StorageKey.wrap(keccak256("setup3"));
        StorageKey key4 = StorageKey.wrap(keccak256("setup4"));
        StorageKey key5 = StorageKey.wrap(keccak256("setup5"));
        StorageKey key6 = StorageKey.wrap(keccak256("setup6"));
        StorageKey key7 = StorageKey.wrap(keccak256("setup7"));

        bytes32 value = keccak256("value");

        key0.writeBytes32(value);
        key1.writeBytes32(value);
        key2.writeBytes32(value);
        key3.writeBytes32(value);
        key4.writeBytes32(value);
        key5.writeBytes32(value);
        key6.writeBytes32(value);
        key7.writeBytes32(value);
    }

    // @sucess_test
    function test_internal_storage() public {
        // Arrange
        StorageKey key = StorageKey.wrap(keccak256("key"));
        bytes32 value = keccak256("value");

        // Act
        key.writeBytes32(value);

        // Assert
        assertEq(key.readBytes32(), value);
    }

    // @sucess_test
    function test_internal_storage_multi_write() public {
        // Arrange
        StorageKey key0 = StorageKey.wrap(keccak256("key0"));
        StorageKey key1 = StorageKey.wrap(keccak256("key1"));
        StorageKey key2 = StorageKey.wrap(keccak256("key2"));
        StorageKey key3 = StorageKey.wrap(keccak256("key3"));
        StorageKey key4 = StorageKey.wrap(keccak256("key4"));
        bytes32 value0 = keccak256("value0");
        bytes32 value1 = keccak256("value1");
        bytes32 value2 = keccak256("value2");
        bytes32 value3 = keccak256("value3");
        bytes32 value4 = keccak256("value4");

        // Act
        key0.writeBytes32(value0);
        key1.writeBytes32(value1);
        key2.writeBytes32(value2);
        key3.writeBytes32(value3);
        key4.writeBytes32(value4);

        // Assert
        assertEq(key0.readBytes32(), value0);
        assertEq(key1.readBytes32(), value1);
        assertEq(key2.readBytes32(), value2);
        assertEq(key3.readBytes32(), value3);
        assertEq(key4.readBytes32(), value4);
    }

    // @sucess_test
    function test_internal_storage_read() public {
        // Arrange
        StorageKey key = StorageKey.wrap(keccak256("setup0"));

        // Act
        bytes32 value = key.readBytes32();

        // Assert
        assertEq(value, keccak256("value"));
    }

    // @sucess_test
    function test_internal_storage_read_multi() public {
        // Arrange
        StorageKey key0 = StorageKey.wrap(keccak256("setup0"));
        StorageKey key1 = StorageKey.wrap(keccak256("setup1"));
        StorageKey key2 = StorageKey.wrap(keccak256("setup2"));
        StorageKey key3 = StorageKey.wrap(keccak256("setup3"));
        StorageKey key4 = StorageKey.wrap(keccak256("setup4"));
        StorageKey key5 = StorageKey.wrap(keccak256("setup5"));
        StorageKey key6 = StorageKey.wrap(keccak256("setup6"));
        StorageKey key7 = StorageKey.wrap(keccak256("setup7"));

        // Act
        bytes32 value0 = key0.readBytes32();
        bytes32 value1 = key1.readBytes32();
        bytes32 value2 = key2.readBytes32();
        bytes32 value3 = key3.readBytes32();
        bytes32 value4 = key4.readBytes32();
        bytes32 value5 = key5.readBytes32();
        bytes32 value6 = key6.readBytes32();
        bytes32 value7 = key7.readBytes32();
    }
}
