// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "test/shared/TestUtils.sol";
import "src/Bridge.sol";
import "src/mocks/MintFreeERC20.sol";
import "src/types/CustomTypes.sol";

contract BridgeTest is Test, TestUtils {
    using SignValidator for Bridge;
    using ChainLibrary for Bridge;
    using TokenLibrary for Token;
    using MerkleValidator for Bridge;
    using MessageValidator for Bridge;

    // Common variables for testing
    Bridge private testBridge;
    ChainId private chainId = ChainId.wrap(1001);
    uint256 private minimumConfirmation = 2;
    uint256 private signerCount = 3;
    IERC20Extend private tokenContract;
    Token private token;

    function setUp() public {
        // Deploy Bridge contract
        address[] memory signers = new address[](signerCount);
        signers[0] = bob;
        signers[1] = alice;
        signers[2] = trudy;
        ChainId[] memory chainIds = new ChainId[](1);
        chainIds[0] = chainId;
        uint256[] memory minimumConfirmations = new uint256[](1);
        minimumConfirmations[0] = minimumConfirmation;
        testBridge = new Bridge(signers, chainIds, minimumConfirmations);

        // Deploy Token contract
        tokenContract = new MintFreeERC20("Test", "TST", 18);
        tokenContract.mint(address(testBridge), 100e18);
        tokenContract.mint(bob, 100e18);
        token = Token.wrap(address(tokenContract));
        vm.prank(bob);
        tokenContract.approve(address(testBridge), 1e18);
    }

    // @sucess_test
    function test_constructor() public {
        // Arrange
        address[] memory signers = new address[](signerCount);
        signers[0] = bob;
        signers[1] = alice;
        signers[2] = trudy;
        ChainId[] memory chainIds = new ChainId[](1);
        chainIds[0] = chainId;
        uint256[] memory minimumConfirmations = new uint256[](1);
        minimumConfirmations[0] = minimumConfirmation;

        // Act
        Bridge bridge = new Bridge(signers, chainIds, minimumConfirmations);

        // Assert
        address[] memory queriedSigners = bridge.querySigners();
        uint256 queriedMinimumConfirmations = bridge.queryMinimumConfirmation(chainId);
        assertEq(queriedSigners.length, signerCount);
        assertEq(queriedSigners[0], bob);
        assertEq(queriedSigners[1], alice);
        assertEq(queriedSigners[2], trudy);
        assertEq(queriedMinimumConfirmations, minimumConfirmation);
    }

    // @sucess_test
    function test_deposit() public {
        // Arrange
        uint256 amount = 1e18;
        uint256 beforeBalanceOfBridge = token.balanceOf(address(testBridge));
        uint256 beforeBalanceOfBob = token.balanceOf(bob);

        // Act
        vm.prank(bob);
        testBridge.deposit(chainId, token, amount);

        // Assert
        assertEq(token.balanceOf(address(testBridge)), beforeBalanceOfBridge + amount);
        assertEq(token.balanceOf(bob), beforeBalanceOfBob - amount);
    }

    function test_withdraw() public {
        // Arrange
        BridgeMessage memory bridgeMessage = BridgeMessage({
            messageId: 1,
            source: chainId,
            target: ChainId.wrap(uint32(block.chainid)),
            blockNumber: 1,
            sourceChainToken: token,
            needWrapping: true,
            to: bob,
            amount: 1e18
        });
        bytes32 bridgeMessageHash = keccak256(abi.encode(bridgeMessage));
        bytes32 leftHash = bytes32(uint256(1));
        bytes32 rootHash = keccak256(abi.encodePacked(leftHash, bridgeMessageHash));

        bytes32[] memory proof = new bytes32[](1);
        proof[0] = leftHash;
        uint64[] memory blockNumbers = new uint64[](1);
        blockNumbers[0] = 1;
        bytes32[] memory newMerkleRoots = new bytes32[](1);
        newMerkleRoots[0] = rootHash;

        UpdateHashMessage memory updateMsg = UpdateHashMessage({
            source: chainId,
            leastConfirmation: 2,
            blockNumbers: blockNumbers,
            newMerkleRoots: newMerkleRoots
        });
        bytes32 updateMessageHash = keccak256(
            abi.encode(updateMsg.source, updateMsg.leastConfirmation, updateMsg.blockNumbers, updateMsg.newMerkleRoots)
        );

        bytes[] memory signatures = new bytes[](signerCount);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobPk, updateMessageHash);
        signatures[0] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(alicePk, updateMessageHash);
        signatures[1] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(trudyPk, updateMessageHash);
        signatures[2] = bytes.concat(r, s, bytes1(v));

        testBridge.update(updateMsg, signatures);

        // Act
        vm.prank(bob);
        testBridge.withdraw(bridgeMessage, proof);

        // Assert
        Token wToken = WTokenFactory.predictWrappedToken(ChainId.wrap(1001), address(testBridge), token);
        assertEq(wToken.balanceOf(bob), bridgeMessage.amount);
    }

    // @sucess_test
    function test_update() public {
        // Arrange
        uint64[] memory blockNumbers = new uint64[](1);
        blockNumbers[0] = 1;
        bytes32[] memory newMerkleRoots = new bytes32[](1);
        newMerkleRoots[0] = hex"01";

        UpdateHashMessage memory updateMsg = UpdateHashMessage({
            source: chainId,
            leastConfirmation: 2,
            blockNumbers: blockNumbers,
            newMerkleRoots: newMerkleRoots
        });
        bytes32 messageHash =
            keccak256(abi.encode(updateMsg.source, updateMsg.leastConfirmation, blockNumbers, newMerkleRoots));

        bytes[] memory signatures = new bytes[](signerCount);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobPk, messageHash);
        signatures[0] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(alicePk, messageHash);
        signatures[1] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(trudyPk, messageHash);
        signatures[2] = bytes.concat(r, s, bytes1(v));

        // Act
        testBridge.update(updateMsg, signatures);

        // Assert
        bytes32 merkleRoot = testBridge.queryMerkleRoot(chainId, updateMsg.blockNumbers[0]);
        assertEq(merkleRoot, updateMsg.newMerkleRoots[0]);
        assertTrue(testBridge.queryMessageExpired(messageHash));
    }

    // @sucess_test
    function test_updateQuorum() public {
        // Arrange
        UpdateQuorumMessage memory updateMsg =
            UpdateQuorumMessage({target: chainId, newSigners: new address[](signerCount)});
        updateMsg.newSigners[0] = alice;
        updateMsg.newSigners[1] = trudy;
        updateMsg.newSigners[2] = bob;

        bytes32 messageHash = keccak256(abi.encode(updateMsg.target, updateMsg.newSigners));
        bytes[] memory signatures = new bytes[](signerCount);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobPk, messageHash);
        signatures[0] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(alicePk, messageHash);
        signatures[1] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(trudyPk, messageHash);
        signatures[2] = bytes.concat(r, s, bytes1(v));

        // Act
        testBridge.updateQuorum(updateMsg, signatures);

        // Assert
        address[] memory queriedSigners = testBridge.querySigners();
        assertEq(queriedSigners.length, signerCount);
        assertEq(queriedSigners[0], alice);
        assertEq(queriedSigners[1], trudy);
        assertEq(queriedSigners[2], bob);
        assertTrue(testBridge.queryMessageExpired(messageHash));
    }
}
