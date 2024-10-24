// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "src/libraries/StorageKeyLibrary.sol";

contract StorageKeyLibraryTest is Test {
    using StorageKeyLibrary for StorageKey;

    // Common variables for tests
    StorageKey private key = StorageKey.wrap(keccak256("TestKey"));

    // @sucess_test
    function test_derive_address() external view {
        // Arrange
        address seed = address(0x1);

        // Act
        StorageKey derived = key.derive(seed);

        // Assert
        assertEq(StorageKey.unwrap(derived), keccak256(abi.encode(key, seed)));
    }

    // @sucess_test
    function test_derive_bytes32() external view {
        // Arrange
        bytes32 seed = hex"1234";

        // Act
        StorageKey derived = key.derive(seed);

        // Assert
        assertEq(StorageKey.unwrap(derived), keccak256(abi.encode(key, seed)));
    }

    // @sucess_test
    function test_derive_uint256() external view {
        // Arrange
        uint256 seed = 1234;

        // Act
        StorageKey derived = key.derive(seed);

        // Assert
        assertEq(StorageKey.unwrap(derived), keccak256(abi.encode(key, seed)));
    }

    // @sucess_test
    function test_derive_string() external view {
        // Arrange
        string memory seed = "1234";

        // Act
        StorageKey derived = key.derive(seed);

        // Assert
        assertEq(StorageKey.unwrap(derived), keccak256(abi.encode(key, seed)));
    }

    // @sucess_test
    function test_derive_Token() external view {
        // Arrange
        Token seed = Token.wrap(address(0x1));

        // Act
        StorageKey derived = key.derive(seed);

        // Assert
        assertEq(StorageKey.unwrap(derived), keccak256(abi.encode(key, seed)));
    }

    // @sucess_test
    function test_derive_ChainId() external view {
        // Arrange
        ChainId seed = ChainId.wrap(1);

        // Act
        StorageKey derived = key.derive(seed);

        // Assert
        assertEq(StorageKey.unwrap(derived), keccak256(abi.encode(key, seed)));
    }

    // @sucess_test
    function test_derive_ChainId_uint64() external view {
        // Arrange
        ChainId seed0 = ChainId.wrap(1);
        uint64 seed1 = 1234;

        // Act
        StorageKey derived = key.derive(seed0, seed1);

        // Assert
        assertEq(StorageKey.unwrap(derived), keccak256(abi.encode(key, seed0, seed1)));
    }
}
