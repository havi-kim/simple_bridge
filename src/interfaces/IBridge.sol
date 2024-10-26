// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ChainId, Token} from "src/types/CustomTypes.sol";
import {BridgeMessage, UpdateHashMessage, UpdateQuorumMessage, SetChainConfigMessage} from "src/types/Messages.sol";

interface IBridge {
    /**
     * @dev Emitted when the token is deposited.
     * @param hash The hash of the bridge message.
     * @param params The bridge message.
     */
    event Deposit(bytes32 indexed hash, BridgeMessage params);

    /**
     * @dev Emitted when the token is withdrawn.
     * @param hash The hash of the bridge message.
     * @param to The receiver of the token.
     * @param token The token to withdraw.
     * @param amount The amount to withdraw.
     */
    event Withdraw(bytes32 indexed hash, address to, Token token, uint256 amount);

    /**
     * @dev Emitted when the merkle root is updated.
     * @param hash The hash of the update message.
     * @param blockNumber The block number to update.
     */
    event Update(bytes32 indexed hash, uint64[] blockNumber);

    /**
     * @dev Emitted when the quorum is updated.
     * @param hash The hash of the update message.
     * @param newSigners The new signers.
     */
    event UpdateQuorum(bytes32 indexed hash, address[] newSigners);

    /**
     * @dev Emitted when the chain config is updated.
     * @param hash The hash of the set config message.
     * @param chainId The chainId to set config.
     * @param minimumConfirmation The minimum confirmation config.
     */
    event SetChainConfig(bytes32 indexed hash, ChainId chainId, uint256 minimumConfirmation);

    /**
     * @dev Deposit the token to the target chain.
     * @param target The target chainId.
     * @param token The token to deposit.
     * @param amount The amount to deposit.
     */
    function deposit(ChainId target, Token token, uint256 amount) external;

    /**
     * @dev Withdraw the token from the source chain.
     * @param bridgeMsg The bridge message.
     * @param proof The merkle proof.
     */
    function withdraw(BridgeMessage calldata bridgeMsg, bytes32[] calldata proof) external;

    /**
     * @dev Update the merkle root of the source chain.
     * @param updateMsg The update message.
     * @param signatures The signatures of the update message.
     */
    function update(UpdateHashMessage calldata updateMsg, bytes[] calldata signatures) external;

    /**
     * @dev Update the quorum of the target chain.
     * @param updateMsg The update message.
     * @param signatures The signatures of the update message.
     */
    function updateQuorum(UpdateQuorumMessage calldata updateMsg, bytes[] calldata signatures) external;

    /**
     * @dev Set the minimum confirmation of the chain.
     * @param setMsg The chain config message.
     * @param signatures The signatures of the message.
     */
    function setMinimumConfirmation(SetChainConfigMessage calldata setMsg, bytes[] calldata signatures) external;
}
