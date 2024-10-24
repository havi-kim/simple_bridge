// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ChainId, Token} from "src/types/CustomTypes.sol";

struct BridgeMessage {
    uint256 messageId;
    ChainId source;
    ChainId target;
    uint64 blockNumber;
    bool needWrapping;
    Token sourceChainToken;
    address to;
    uint256 amount;
}

struct UpdateHashMessage {
    ChainId source;
    uint256 leastConfirmation;
    uint64[] blockNumbers;
    bytes32[] newMerkleRoots;
}

struct UpdateQuorumMessage {
    ChainId target;
    address[] newSigners;
}

struct SetChainConfigMessage {
    ChainId chainId;
    uint256 minimumConfirmation;
    bytes32 separator;
}
