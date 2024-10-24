// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "src/libraries/MessageIdGenerator.sol";
import {TestUtils} from "test/shared/TestUtils.sol";

contract MessageIdGeneratorTest is Test, TestUtils {
    using MessageIdGenerator for IExtsload;

    // Common variables for tests
    IExtsload private self = IExtsload(address(this));

    // @sucess_test
    function test_expire() public {
        // Act
        uint256 messageId = MessageIdGenerator.generate();

        // Assert
        assertEq(messageId, 1);
    }

    // @sucess_test
    function test_queryMessageId() public {
        // Arrange
        MessageIdGenerator.generate();
        MessageIdGenerator.generate();
        MessageIdGenerator.generate();

        // Act
        uint256 messageId = MessageIdGenerator.queryMessageId(self);

        // Assert
        assertEq(messageId, 3);
    }
}
