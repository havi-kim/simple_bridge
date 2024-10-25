// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "test/shared/TestUtils.sol";
import "src/libraries/MerkleValidator.sol";

contract MerkleValidatorTest is Test, TestUtils {
    using MerkleValidator for IExtsload;

    // Common variables for tests
    IExtsload private self = IExtsload(address(this));
    ChainId private chainId = ChainId.wrap(1);
    uint64 private blockNumber = 2;

    // @sucess_test
    function test_setMerkleRoot() public {
        // Arrange
        bytes32 merkleRoot = hex"1234";

        // Act
        MerkleValidator.setMerkleRoot(chainId, blockNumber, merkleRoot);

        // Assert
        assertEq(self.queryMerkleRoot(chainId, blockNumber), merkleRoot);
    }

    // @sucess_test
    function test_validate_left_to_right() public {
        // Arrange
        bytes32 leaf0 = hex"2345";
        bytes32 leaf1 = hex"3456";
        bytes32 merkleRoot = keccak256(abi.encodePacked(leaf0, leaf1));
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = leaf1;

        MerkleValidator.setMerkleRoot(chainId, blockNumber, merkleRoot);

        // Act
        MerkleValidator.validate(chainId, blockNumber, leaf0, proof);
    }

    // @sucess_test
    function test_validate_right_to_left() public {
        // Arrange
        bytes32 leaf0 = hex"2345";
        bytes32 leaf1 = hex"1234";
        bytes32 merkleRoot = keccak256(abi.encodePacked(leaf1, leaf0));
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = leaf1;

        MerkleValidator.setMerkleRoot(chainId, blockNumber, merkleRoot);

        // Act
        MerkleValidator.validate(chainId, blockNumber, leaf0, proof);
    }

    // @failure_test
    function test_validate_failure() public {
        // Arrange
        bytes32 leaf0 = hex"2345";
        bytes32 leaf1 = hex"3456";
        bytes32 merkleRoot = keccak256(abi.encodePacked(leaf0, leaf1));
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = leaf0;

        MerkleValidator.setMerkleRoot(chainId, blockNumber, merkleRoot);

        // Act
        vm.expectRevert("MerkleValidator: invalid proof");
        MerkleValidator.validate(chainId, blockNumber, leaf0, proof);
    }

    // @sucess_test
    function test_validate_deep_depth() public {
        // Arrange
        bytes32 leaf0 = hex"01";
        bytes32 leaf1 = hex"02";
        bytes32 leaf2 = hex"03";
        bytes32 leaf3 = hex"04";
        bytes32 computedHash = keccak256(abi.encodePacked(leaf0, leaf1));
        bytes32 merkleRoot = keccak256(abi.encodePacked(leaf3, keccak256(abi.encodePacked(leaf2, computedHash))));
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = leaf1;
        proof[1] = leaf2;
        proof[2] = leaf3;

        MerkleValidator.setMerkleRoot(chainId, blockNumber, merkleRoot);

        // Act
        MerkleValidator.validate(chainId, blockNumber, leaf0, proof);
    }

    function test_hash() external {
        /*		{
			left:     "6b86b273ff34fce19d6b804eff5a3f5745a96c7e3c20cd9f32d60df7141baf22",
			right:    "d4735e3a265e16eee03f59718b9b5d7b20e2a975f19d66e788a7f34b47a4b4e9",
			expected: "9277be367611993a6df870f0b2b5b3a718a97a6105d7793c882860458d05b24b",
		},
		{
			left:     "4e07408562bedb8b60ce05c1decfe3ad16b8224aa2a24e09f3d6b8e6dd7698c9",
			right:    "4b227777d4dd1fc61c6f884f48641d02ac8e53e52dd103eda9c1d3e5a90a660a",
			expected: "0819ea34cb19575b476ebd24d5121b4491b68aa11e4cb2854d49b25c9ef9b2a8",
		},
		*/
        bytes32 left = 0x6b86b273ff34fce19d6b804eff5a3f5745a96c7e3c20cd9f32d60df7141baf22;
        bytes32 right = 0xd4735e3a265e16eee03f59718b9b5d7b20e2a975f19d66e788a7f34b47a4b4e9;
        bytes32 expected = 0x9277be367611993a6df870f0b2b5b3a718a97a6105d7793c882860458d05b24b;
        bytes32 computedHash = keccak256(abi.encodePacked(left, right));
        assertEq(computedHash, expected);

        left = 0x4e07408562bedb8b60ce05c1decfe3ad16b8224aa2a24e09f3d6b8e6dd7698c9;
        right = 0x4b227777d4dd1fc61c6f884f48641d02ac8e53e52dd103eda9c1d3e5a90a660a;
        expected = 0x0819ea34cb19575b476ebd24d5121b4491b68aa11e4cb2854d49b25c9ef9b2a8;
        computedHash = keccak256(abi.encodePacked(left, right));
        assertEq(computedHash, expected);
    }
}
