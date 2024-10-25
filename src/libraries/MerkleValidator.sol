// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IExtsload} from "src/interfaces/IExtsload.sol";

import {ChainId, StorageKey} from "src/types/CustomTypes.sol";
import {StorageKeyLibrary} from "src/libraries/StorageKeyLibrary.sol";
import {InternalStorage} from "../storage/InternalStorage.sol";

/**
 * @title MerkleValidator
 * @notice Library for validating merkle proofs
 */
library MerkleValidator {
    using StorageKeyLibrary for StorageKey;
    using InternalStorage for StorageKey;

    StorageKey private constant _LIBRARY_UNIQUE_KEY = StorageKey.wrap(keccak256("src.libraries.MerkleValidator"));

    // @dev Same as below
    // mapping(ChainId => mapping(uint64 => bytes32)) merkleRoot;
    // mapping(ChainId => uint256) lastUpdateBlockNumber;

    /**
     * @dev Set merkle root
     * @param chainId Chain ID to set merkle root
     * @param blockNumber chain's block number to set merkle root
     * @param merkleRoot Merkle root to set
     */
    function setMerkleRoot(ChainId chainId, uint64 blockNumber, bytes32 merkleRoot) internal {
        StorageKey merkleRootKey = _LIBRARY_UNIQUE_KEY.derive(chainId, blockNumber);
        require(merkleRootKey.readBytes32() == 0, "MerkleValidator: merkle root already set");
        merkleRootKey.writeBytes32(merkleRoot);

        StorageKey lastBlockNumberKey = _LIBRARY_UNIQUE_KEY.derive(chainId);
        uint256 lastUpdateBlockNumber = lastBlockNumberKey.readUint256();
        if (lastUpdateBlockNumber < blockNumber) {
            lastBlockNumberKey.writeUint256(blockNumber);
        }
    }

    /**
     * @dev Validate merkle proof with the given leaf
     * @param chainId Chain ID which merkle root belongs to
     * @param blockNumber chain's block number which is merkle root belongs to
     * @param leaf Leaf node to validate
     * @param proof Merkle proof to prove the leaf node is in the tree
     */
    function validate(ChainId chainId, uint64 blockNumber, bytes32 leaf, bytes32[] memory proof) internal view {
        StorageKey key = _LIBRARY_UNIQUE_KEY.derive(chainId, blockNumber);
        bytes32 merkleRoot = key.readBytes32();
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        require(computedHash == merkleRoot, "MerkleValidator: invalid proof");
    }

    /**
     * @dev Query merkle root
     * @param target The target contract to query
     * @param chainId Chain ID to query merkle root
     * @param blockNumber chain's block number to query merkle root
     * @return Merkle root
     */
    function queryMerkleRoot(IExtsload target, ChainId chainId, uint64 blockNumber) internal view returns (bytes32) {
        StorageKey key = _LIBRARY_UNIQUE_KEY.derive(chainId, blockNumber);
        return target.extsload(key);
    }
}
