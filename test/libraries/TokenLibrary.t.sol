// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "test/shared/TestUtils.sol";
import "src/mocks/MintFreeERC20.sol";
import "src/libraries/TokenLibary.sol";
import "src/libraries/WTokenFactory.sol";

contract TokenLibraryTest is Test, TestUtils {
    using TokenLibrary for Token;

    // Common variables for tests
    IERC20Extend private tokenContract;
    Token private token;

    function setUp() public {
        tokenContract = new MintFreeERC20("Test", "TST", 18);
        tokenContract.mint(address(this), 100e18);
        tokenContract.mint(bob, 100e18);
        token = Token.wrap(address(tokenContract));
        vm.prank(bob);
        tokenContract.approve(address(this), 1e18);
    }

    // @sucess_test
    function test_transferIn() public {
        // Arrange
        uint256 amount = 1e18;
        uint256 beforeBalanceOfBob = token.balanceOf(bob);
        uint256 beforeBalanceOfThis = token.balanceOf(address(this));

        // Act
        token.transferIn(bob, amount);

        // Assert
        assertEq(token.balanceOf(bob), beforeBalanceOfBob - amount);
        assertEq(token.balanceOf(address(this)), beforeBalanceOfThis + amount);
    }

    // @sucess_test
    function test_transferIn_wrappedToken_burn() public {
        // Arrange
        uint256 amount = 1e18;
        Token wToken = WTokenFactory.createWrappedToken(ChainId.wrap(1001), token);
        IERC20Extend(Token.unwrap(wToken)).mint(bob, amount);
        uint256 beforeBalanceOfBob = wToken.balanceOf(bob);
        uint256 beforeBalanceOfThis = wToken.balanceOf(address(this));

        // Act
        wToken.transferIn(bob, amount); // Burn

        // Assert
        assertEq(wToken.balanceOf(bob), beforeBalanceOfBob - amount); // Decrease balance of bob
        assertEq(wToken.balanceOf(address(this)), beforeBalanceOfThis); // Not increase balance of this
    }

    // @sucess_test
    function test_transferOut() public {
        // Arrange
        uint256 amount = 1e18;
        uint256 beforeBalanceOfBob = token.balanceOf(bob);
        uint256 beforeBalanceOfThis = token.balanceOf(address(this));

        // Act
        token.transferOut(bob, amount);

        // Assert
        assertEq(token.balanceOf(bob), beforeBalanceOfBob + amount);
        assertEq(token.balanceOf(address(this)), beforeBalanceOfThis - amount);
    }

    // @sucess_test
    function test_transferOut_wrappedToken_mint() public {
        // Arrange
        uint256 amount = 1e18;
        Token wToken = WTokenFactory.createWrappedToken(ChainId.wrap(1001), token);
        uint256 beforeBalanceOfBob = wToken.balanceOf(bob);
        uint256 beforeBalanceOfThis = wToken.balanceOf(address(this));

        // Act
        wToken.transferOut(bob, amount); // Mint

        // Assert
        assertEq(wToken.balanceOf(bob), beforeBalanceOfBob + amount); // Increase balance of bob
        assertEq(wToken.balanceOf(address(this)), beforeBalanceOfThis); // Not decrease balance of this
    }
}
