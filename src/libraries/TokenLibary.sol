// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {StorageKey, Token} from "src/types/CustomTypes.sol";
import {IERC20Extend} from "src/interfaces/IERC20Extend.sol";
import {WTokenFactory} from "src/libraries/WTokenFactory.sol";

/**
 * @title TokenLibrary
 * @dev Library for token operations
 */
library TokenLibrary {
    using SafeERC20 for IERC20Extend;

    StorageKey private constant _LIBRARY_UNIQUE_KEY = StorageKey.wrap(keccak256("src.libraries.Token"));

    /**
     * @dev If the token is wrapped token, burn the token. Otherwise, transfer token from sender to this contract.
     * @param token Token to transfer
     * @param from Sender address
     * @param amount Amount to transfer
     */
    function transferIn(Token token, address from, uint256 amount) internal {
        if (WTokenFactory.isWrappedToken(token)) {
            IERC20Extend(Token.unwrap(token)).burn(from, amount);
            return;
        }
        IERC20Extend(Token.unwrap(token)).safeTransferFrom(from, address(this), amount);
    }

    /**
     * @dev If the token is wrapped token, mint the token. Otherwise, transfer token to receiver.
     * @param token Token to transfer
     * @param to Receiver address
     * @param amount Amount to transfer
     */
    function transferOut(Token token, address to, uint256 amount) internal {
        if (WTokenFactory.isWrappedToken(token)) {
            IERC20Extend(Token.unwrap(token)).mint(to, amount);
            return;
        }
        IERC20Extend(Token.unwrap(token)).safeTransfer(to, amount);
    }

    /**
     * @dev Get balance of the token
     * @param token Token to get balance
     * @param owner Owner address
     * @return Balance of the token
     */
    function balanceOf(Token token, address owner) internal view returns (uint256) {
        return IERC20Extend(Token.unwrap(token)).balanceOf(owner);
    }
}
