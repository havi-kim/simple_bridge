// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "src/libraries/ChainLibrary.sol";
import "test/shared/TestUtils.sol";

contract ChainLibraryTest is Test, TestUtils {
    using ChainLibrary for ChainId;
    using ChainLibrary for IExtsload;

    // Common variables for tests
    IExtsload private self = IExtsload(address(this));
    ChainId private chain = ChainId.wrap(1);
    uint256 private minimumConfirmation = 10;

    // @sucess_test
    function test_setMinimumConfirmation() public {
        // Arrange
        uint256 newMinimumConfirmation = 20;

        // Act
        chain.setMinimumConfirmation(newMinimumConfirmation);
        ReadOptimizedStorage.commit();

        // Assert
        assertEq(self.queryMinimumConfirmation(chain), newMinimumConfirmation);
    }

    // @sucess_test
    function test_validateConfirmation() public {
        // Arrange
        uint256 confirmation = 10;
        chain.setMinimumConfirmation(minimumConfirmation);

        // Act
        chain.validateConfirmation(confirmation);
    }

    // @failure_test
    function test_validateConfirmation_failure() public {
        // Arrange
        uint256 confirmation = 9;
        chain.setMinimumConfirmation(minimumConfirmation);

        // Act
        vm.expectRevert("ChainLibrary: invalid confirmation");
        chain.validateConfirmation(confirmation);
    }

    // @sucess_test
    function test_isTargetChain() public {
        // Arrange
        ChainId curChain = ChainId.wrap(uint32(block.chainid));

        // Act
        curChain.validateTargetChain();
    }

    // @failure_test
    function test_isTargetChain_failure() public {
        // Arrange
        ChainId tmpChain = ChainId.wrap(2);

        // Act
        vm.expectRevert("ChainLibrary: This chain is not target chain");
        tmpChain.validateTargetChain();
    }
}
