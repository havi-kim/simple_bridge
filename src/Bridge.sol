// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IBridge} from "src/interfaces/IBridge.sol";
import {Exttload} from "src/Exttload.sol";
import {Extsload} from "src/Extsload.sol";

import {ReadOptimizedStorage} from "src/storage/ReadOptimizedStorage.sol";
import {MerkleValidator} from "src/libraries/MerkleValidator.sol";
import {SignValidator} from "src/libraries/SignValidator.sol";
import {WTokenFactory} from "src/libraries/WTokenFactory.sol";
import {ChainId, Token} from "src/types/CustomTypes.sol";
import {TokenLibrary} from "src/libraries/TokenLibary.sol";
import {ChainLibrary} from "src/libraries/ChainLibrary.sol";
import {BridgeMessage, UpdateHashMessage, UpdateQuorumMessage, SetChainConfigMessage} from "src/types/Messages.sol";
import {MessageValidator} from "src/libraries/MessageValidator.sol";
import {MessageIdGenerator} from "src/libraries/MessageIdGenerator.sol";

/**
 * @title Bridge
 * @dev The Bridge contract is the main contract that handles the ERC20 cross-chain transfer.
 */
contract Bridge is IBridge, Exttload, Extsload {
    using TokenLibrary for Token;
    using ChainLibrary for ChainId;

    /**
     * @dev Construct the bridge with the initial signers and chainIds.
     * @param initialSigners The initial signers of the bridge.
     * @param chainIds The chainIds that the bridge will support.
     * @param minimumConfirmations The minimum confirmations for each chainId.
     */
    constructor(address[] memory initialSigners, ChainId[] memory chainIds, uint256[] memory minimumConfirmations) {
        // 0. Validate the input parameters
        require(chainIds.length == minimumConfirmations.length, "Bridge: invalid chainIds length");

        // 1. Set the initial signers
        SignValidator.setSigners(initialSigners);

        // 2. Set the chain configs
        for (uint256 i = 0; i < chainIds.length; i++) {
            chainIds[i].setMinimumConfirmation(minimumConfirmations[i]);
        }

        // 3. Commit the read-optimized storage
        // When this contract will uses a Proxy, it is better to delegate the commit to the Proxy. (like AOP)
        ReadOptimizedStorage.commit();
    }

    /**
     * @dev Deposit the token to the target chain.
     * @param target The target chainId.
     * @param token The token to deposit.
     * @param amount The amount to deposit.
     */
    function deposit(ChainId target, Token token, uint256 amount) external override {
        // 0. Create the bridge message
        BridgeMessage memory message = BridgeMessage({
            messageId: MessageIdGenerator.generate(),
            source: ChainId.wrap(uint32(block.chainid)),
            target: target,
            blockNumber: uint64(block.number),
            needWrapping: !WTokenFactory.isWrappedToken(token),
            sourceChainToken: token,
            to: msg.sender,
            amount: amount
        });

        if (message.needWrapping) {
            WTokenFactory.setPredictedWrappedToken(message.sourceChainToken);
        }

        // 1. Transfer the token to this contract
        token.transferIn(msg.sender, amount);

        // 2. Emit the deposit event
        emit Deposit(keccak256(abi.encode(message)), message);
    }

    /**
     * @dev Withdraw the token from the source chain.
     * @param bridgeMsg The bridge message.
     * @param proof The merkle proof.
     */
    function withdraw(BridgeMessage calldata bridgeMsg, bytes32[] calldata proof) external override {
        // 0. Validate the message
        bytes32 messageHash = keccak256(abi.encode(bridgeMsg));
        bridgeMsg.target.validateTargetChain();
        MessageValidator.validate(messageHash);
        MerkleValidator.validate(bridgeMsg.source, bridgeMsg.blockNumber, messageHash, proof);

        // 1. Get the output token
        Token token = WTokenFactory.flipToken(bridgeMsg.sourceChainToken, bridgeMsg.source, bridgeMsg.needWrapping);

        // 2. Expire the message
        MessageValidator.expire(messageHash);

        // 3. Transfer the token to the recipient
        token.transferOut(bridgeMsg.to, bridgeMsg.amount);

        // 4. Emit the withdraw event
        emit Withdraw(messageHash, bridgeMsg.to, token, bridgeMsg.amount);
    }

    /**
     * @dev Update the merkle root of the source chain.
     * @param updateMsg The update message.
     * @param signatures The signatures of the update message.
     */
    function update(UpdateHashMessage calldata updateMsg, bytes[] calldata signatures) external override {
        // 0. Validate the message
        require(updateMsg.blockNumbers.length == updateMsg.newMerkleRoots.length, "Bridge: invalid update message");
        bytes32 messageHash = keccak256(
            abi.encode(updateMsg.source, updateMsg.leastConfirmation, updateMsg.blockNumbers, updateMsg.newMerkleRoots)
        );
        MessageValidator.validate(messageHash);
        SignValidator.validate(messageHash, signatures);
        updateMsg.source.validateConfirmation(updateMsg.leastConfirmation);

        // 1. Expire the message
        MessageValidator.expire(messageHash);

        // 2. Set the new merkle root
        for (uint256 i = 0; i < updateMsg.blockNumbers.length; i++) {
            MerkleValidator.setMerkleRoot(updateMsg.source, updateMsg.blockNumbers[i], updateMsg.newMerkleRoots[i]);
        }

        // 3. Emit the update event
        emit Update(messageHash, updateMsg.blockNumbers);
    }

    /**
     * @dev Update the quorum of the target chain.
     * @param updateMsg The update message.
     * @param signatures The signatures of the update message.
     */
    function updateQuorum(UpdateQuorumMessage calldata updateMsg, bytes[] calldata signatures) external override {
        // 0. Validate the message
        bytes32 messageHash = keccak256(abi.encode(updateMsg.target, updateMsg.newSigners));
        MessageValidator.validate(messageHash);
        SignValidator.validate(messageHash, signatures);

        // 1. Expire the message
        MessageValidator.expire(messageHash);

        // 2. Set the new signers
        SignValidator.setSigners(updateMsg.newSigners);

        // 3. Commit the read-optimized storage
        // When this contract will uses a Proxy, it is better to delegate the commit to the Proxy. (like AOP)
        ReadOptimizedStorage.commit();

        // 4. Emit the update event
        emit UpdateQuorum(messageHash, updateMsg.newSigners);
    }

    /**
     * @dev Set the minimum confirmation of the chain.
     * @param setMsg The chain config message.
     * @param signatures The signatures of the message.
     */
    function setMinimumConfirmation(SetChainConfigMessage calldata setMsg, bytes[] calldata signatures)
        external
        override
    {
        // 0. Validate the message
        bytes32 messageHash = keccak256(abi.encode(setMsg));
        MessageValidator.validate(messageHash);
        SignValidator.validate(messageHash, signatures);

        // 1. Expire the message
        MessageValidator.expire(messageHash);

        // 2. Set the new minimum confirmation
        setMsg.chainId.setMinimumConfirmation(setMsg.minimumConfirmation);

        // 3. Commit the read-optimized storage
        // When this contract will uses a Proxy, it is better to delegate the commit to the Proxy. (like AOP)
        ReadOptimizedStorage.commit();

        // 4. Emit the update event
        emit SetChainConfig(messageHash, setMsg.chainId, setMsg.minimumConfirmation);
    }
}
