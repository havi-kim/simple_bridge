// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "src/libraries/WTokenFactory.sol";
import "src/mocks/MintFreeERC20.sol";
import "test/shared/TestUtils.sol";
import "../../src/types/Messages.sol";

contract WTokenFactoryTest is Test, TestUtils {
    using WTokenFactory for IExtsload;

    // Common variables for tests
    IExtsload private self = IExtsload(address(this));
    string private name = "Wrapped Token";
    string private symbol = "WTK";
    ChainId private chainId = ChainId.wrap(1001);
    Token private originalToken = Token.wrap(address(0x1));

    // @sucess_test
    function test_createWrappedToken() public {
        // Act
        Token token = WTokenFactory.createWrappedToken(chainId, originalToken);

        // Assert
        assertTrue(WTokenFactory.isWrappedToken(token));
        assertTrue(self.queryIsWrappedToken(token));
    }

    // @sucess_test
    function test_predictWrappedTokenAddress() public {
        // Arrange
        Token createdToken = WTokenFactory.createWrappedToken(chainId, originalToken);

        // Act
        Token predictedToken = WTokenFactory.predictWrappedToken(chainId, address(this), originalToken);

        // Assert
        assertTrue(createdToken == predictedToken);
    }

    // @sucess_test
    function test_setWrappedTokenMetadata() public {
        // Arrange
        Token token = WTokenFactory.createWrappedToken(chainId, originalToken);

        // Act
        WTokenFactory.setWrappedTokenMetadata(token, name, symbol);

        // Assert
        WrappedToken wrappedToken = WrappedToken(Token.unwrap(token));
        assertEq(wrappedToken.name(), name);
        assertEq(wrappedToken.symbol(), symbol);
    }
}
