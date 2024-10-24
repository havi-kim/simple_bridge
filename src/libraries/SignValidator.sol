// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {IExtsload} from "src/interfaces/IExtsload.sol";

import {StorageKey} from "src/types/CustomTypes.sol";
import {StorageKeyLibrary} from "src/libraries/StorageKeyLibrary.sol";
import {ReadOptimizedStorage} from "../storage/ReadOptimizedStorage.sol";

/**
 * @title SignValidator
 * @notice Library for validating signatures with three signers. Duplicate signers are not allowed.
 */
library SignValidator {
    using ReadOptimizedStorage for StorageKey;
    using StorageKeyLibrary for StorageKey;

    StorageKey private constant _LIBRARY_UNIQUE_KEY = StorageKey.wrap(keccak256("src.libraries.SignValidator"));

    StorageKey private constant _SIGNER_0 = StorageKey.wrap(keccak256("src.libraries.SignValidator.signer_0"));
    StorageKey private constant _SIGNER_1 = StorageKey.wrap(keccak256("src.libraries.SignValidator.signer_1"));
    StorageKey private constant _SIGNER_2 = StorageKey.wrap(keccak256("src.libraries.SignValidator.signer_2"));

    uint256 private constant _SIGNER_COUNT = 3;
    uint256 private constant _THRESHOLD = 2;

    // @dev Same as below
    // When dealing with a large number of signers, it may be more efficient to manage signers
    // in a whitelist structure instead of individually comparing each recovered signer.
    // address signer0;
    // address signer1;
    // address signer2;

    /**
     * @dev Set signers. Duplicate signers are not allowed.
     * @param signers Signers to set
     */
    function setSigners(address[] memory signers) internal {
        require(signers.length == _SIGNER_COUNT, "SignValidator: invalid signer length");
        require(
            signers[0] != address(0) && signers[1] != address(0) && signers[2] != address(0),
            "SignValidator: invalid signer"
        );
        require(
            signers[0] != signers[1] && signers[0] != signers[2] && signers[1] != signers[2],
            "SignValidator: duplicate signer"
        );
        _SIGNER_0.writeAddress(signers[0]);
        _SIGNER_1.writeAddress(signers[1]);
        _SIGNER_2.writeAddress(signers[2]);
    }

    /**
     * @dev Validate signatures.
     * @param hash Hash to validate
     * @param signatures Signatures of the hash to validate
     */
    function validate(bytes32 hash, bytes[] memory signatures) internal {
        require(signatures.length >= _THRESHOLD, "SignValidator: invalid signature length");

        uint256 validSignCount = 0;
        address signer0 = _SIGNER_0.readAddress();
        address signer1 = _SIGNER_1.readAddress();
        address signer2 = _SIGNER_2.readAddress();

        for (uint256 i = 0; i < signatures.length; i++) {
            address signer = ECDSA.recover(hash, signatures[i]);
            if (signer == address(0)) {
                continue; // revert("SignValidator: invalid signature");
            }
            if (signer == signer0) {
                signer0 = address(0);
            } else if (signer == signer1) {
                signer1 = address(0);
            } else if (signer == signer2) {
                signer2 = address(0);
            } else {
                continue; // revert("SignValidator: invalid signature");
            }

            validSignCount++;
            if (validSignCount >= _THRESHOLD) {
                return;
            }
        }
        revert("SignValidator: invalid signature");
    }

    /**
     * @dev Query signers
     * @param target The target contract to query
     * @return signers Signers list of the target
     */
    function querySigners(IExtsload target) internal view returns (address[] memory signers) {
        StorageKey[] memory keys = new StorageKey[](_SIGNER_COUNT);
        signers = new address[](_SIGNER_COUNT);
        keys[0] = _SIGNER_0;
        keys[1] = _SIGNER_1;
        keys[2] = _SIGNER_2;
        bytes32[] memory queriedData = target.extsload(keys);
        for (uint256 i = 0; i < _SIGNER_COUNT; i++) {
            signers[i] = address(uint160(uint256(queriedData[i])));
        }
    }
}
