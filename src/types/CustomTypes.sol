// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

type ChainId is uint32;

type Token is address;

type StorageKey is bytes32;

using {equalChainId as ==} for ChainId global;

function equalChainId(ChainId a, ChainId b) pure returns (bool) {
    return ChainId.unwrap(a) == ChainId.unwrap(b);
}

using {equalToken as ==} for Token global;

function equalToken(Token a, Token b) pure returns (bool) {
    return Token.unwrap(a) == Token.unwrap(b);
}

using {equalStorageKey as ==} for StorageKey global;

function equalStorageKey(StorageKey a, StorageKey b) pure returns (bool) {
    return StorageKey.unwrap(a) == StorageKey.unwrap(b);
}
