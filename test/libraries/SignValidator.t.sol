// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "src/libraries/SignValidator.sol";
import "test/shared/TestUtils.sol";

contract SignValidatorTest is Test, TestUtils {
    using SignValidator for IExtsload;

    // Common variables for tests
    IExtsload private self = IExtsload(address(this));
    uint256 private constant signerCount = 3;
    uint256 private constant threshold = 2;
    bytes32 private constant testHash = keccak256(abi.encodePacked("test"));

    // @sucess_test
    function test_setSigner() public {
        // Arrange
        address[] memory signers = new address[](signerCount);
        signers[0] = bob;
        signers[1] = alice;
        signers[2] = trudy;

        // Act
        SignValidator.setSigners(signers);

        // Assert
        assertEq(self.querySigners().length, signerCount);
    }

    // @sucess_test
    function test_validate_bob_and_alice() public {
        // Arrange
        address[] memory signers = new address[](signerCount);
        signers[0] = bob;
        signers[1] = alice;
        signers[2] = trudy;
        SignValidator.setSigners(signers);

        bytes[] memory signatures = new bytes[](threshold);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobPk, testHash);
        signatures[0] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(alicePk, testHash);
        signatures[1] = bytes.concat(r, s, bytes1(v));

        // Act
        SignValidator.validate(testHash, signatures);
    }

    // @sucess_test
    function test_validate_all() public {
        // Arrange
        address[] memory signers = new address[](signerCount);
        signers[0] = bob;
        signers[1] = alice;
        signers[2] = trudy;
        SignValidator.setSigners(signers);

        bytes[] memory signatures = new bytes[](signerCount);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobPk, testHash);
        signatures[0] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(alicePk, testHash);
        signatures[1] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(trudyPk, testHash);
        signatures[2] = bytes.concat(r, s, bytes1(v));

        // Act
        SignValidator.validate(testHash, signatures);
    }

    // @sucess_test
    function test_validate_trudy_and_alice() public {
        // Arrange
        address[] memory signers = new address[](signerCount);
        signers[0] = bob;
        signers[1] = alice;
        signers[2] = trudy;
        SignValidator.setSigners(signers);

        bytes[] memory signatures = new bytes[](threshold);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(trudyPk, testHash);
        signatures[0] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(alicePk, testHash);
        signatures[1] = bytes.concat(r, s, bytes1(v));

        // Act
        SignValidator.validate(testHash, signatures);
    }

    // @failure_test
    function test_validate_failure() public {
        // Arrange
        bytes[] memory signatures = new bytes[](1);

        // Act
        vm.expectRevert("SignValidator: invalid signature length");
        SignValidator.validate(testHash, signatures);
    }

    // @failure_test
    function test_validate_failure_duplicate_signature() public {
        // Arrange
        address[] memory signers = new address[](signerCount);
        signers[0] = bob;
        signers[1] = alice;
        signers[2] = trudy;
        SignValidator.setSigners(signers);

        bytes[] memory signatures = new bytes[](threshold);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobPk, testHash);
        signatures[0] = bytes.concat(r, s, bytes1(v));
        signatures[1] = signatures[0];

        // Act
        vm.expectRevert("SignValidator: invalid signature");
        SignValidatorTest(address(this)).call_validate(signatures);
    }

    // @failure_test
    function test_validate_failure_invalid() public {
        // Arrange
        address[] memory signers = new address[](signerCount);
        signers[0] = bob;
        signers[1] = alice;
        signers[2] = trudy;
        SignValidator.setSigners(signers);

        bytes[] memory signatures = new bytes[](threshold);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobPk, testHash);
        signatures[0] = bytes.concat(r, s, bytes1(v));

        // Act
        vm.expectRevert();
        SignValidatorTest(address(this)).call_validate(signatures);
    }

    // This is helper function for library revert test
    function call_validate(bytes[] memory signatures) public {
        SignValidator.validate(testHash, signatures);
    }
}
