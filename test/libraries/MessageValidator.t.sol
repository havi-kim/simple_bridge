// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "src/libraries/MessageValidator.sol";
import {TestUtils} from "../shared/TestUtils.sol";

contract MessageValidatorTest is Test, TestUtils {
    using MessageValidator for IExtsload;

    // Common variables for tests
    IExtsload private self = IExtsload(address(this));

    // @sucess_test
    function test_expire() public {
        // Arrange
        bytes32 messageHash = keccak256("messageHash");
        MessageValidator.validate(messageHash);

        // Act
        MessageValidator.expire(messageHash);

        // Assert
        assertTrue(self.queryMessageExpired(messageHash));
    }

    // @failure_test
    function test_expire_failure() public {
        // Arrange
        bytes32 messageHash = keccak256("messageHash");
        MessageValidator.expire(messageHash);

        // Act
        vm.expectRevert("MessageLibrary: message expired");
        MessageValidator.validate(messageHash);
    }
}
