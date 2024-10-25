// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IExtsload} from "src/interfaces/IExtsload.sol";
import {WrappedToken} from "src/token/WrappedToken.sol";

import {InternalStorage} from "src/storage/InternalStorage.sol";
import {Token, ChainId, StorageKey} from "src/types/CustomTypes.sol";
import {StorageKeyLibrary} from "src/libraries/StorageKeyLibrary.sol";

library WTokenFactory {
    using InternalStorage for StorageKey;
    using StorageKeyLibrary for StorageKey;

    StorageKey private constant _WRAPPED_TO_ORIGINAL = StorageKey.wrap(keccak256("src.libraries.WTokenFactory.wrappedToneToOriginal"));

    // @dev Same as below
    // mapping(Token => address) wrappedTokenToOriginal;

    /**
     * @dev Create wrapped token from original token and chain ID
     * @param chainId The source chain ID
     * @param originalToken The original token to wrap
     */
    function createWrappedToken(ChainId chainId, Token originalToken) internal returns (Token token) {
        token = Token.wrap(address(new WrappedToken{salt: getSalt(chainId, originalToken)}(chainId, originalToken)));
        StorageKey tokenKey = _WRAPPED_TO_ORIGINAL.derive(token);
        tokenKey.writeAddress(Token.unwrap(originalToken));
    }

    /**
     * @dev Set predicted wrapped token address from original token and chain ID
     * @param originalToken The original token to wrap
     */
    function setPredictedWrappedToken(Token originalToken) internal {
        Token predictedToken = predictWrappedToken(ChainId.wrap(uint32(block.chainid)), address(this), originalToken);
        StorageKey tokenKey = _WRAPPED_TO_ORIGINAL.derive(predictedToken);
        if (tokenKey.readAddress() == address(0)) {
            tokenKey.writeAddress(Token.unwrap(originalToken));
        }
    }

    /**
     * @dev Predict wrapped token address from original token and chain ID
     * @param chainId The source chain ID
     * @param factory The factory address
     * @param originalToken The original token to wrap
     */
    function predictWrappedToken(ChainId chainId, address factory, Token originalToken) internal pure returns (Token) {
        bytes32 salt = getSalt(chainId, originalToken);
        bytes32 deployHash =
            keccak256(abi.encodePacked(type(WrappedToken).creationCode, abi.encode(chainId, originalToken)));
        return
            Token.wrap(address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), factory, salt, deployHash))))));
    }

    /**
     * @dev Set wrapped token metadata (name, symbol)
     * @param token Wrapped token to set metadata
     * @param name Token name (e.g. "Wrapped Ethereum")
     * @param symbol Token symbol (e.g. "WETH")
     */
    function setWrappedTokenMetadata(Token token, string memory name, string memory symbol) internal {
        WrappedToken(Token.unwrap(token)).setMetadata(name, symbol);
    }

    /**
     * @dev Check if the token is wrapped token
     * @param token Token to check
     * @return Whether the token is wrapped token
     */
    function isWrappedToken(Token token) internal view returns (bool) {
        StorageKey tokenKey = _WRAPPED_TO_ORIGINAL.derive(token);
        return tokenKey.readAddress() != address(0);
    }

    /**
     * @dev Flip token to wrapped token or original token based on needWrapping
     * @param sourceChainToken Token on the source chain
     * @param source Source chain ID
     * @param needWrapping Whether the token needs wrapping
     */
    function flipToken(Token sourceChainToken, ChainId source, bool needWrapping) internal returns (Token token) {
        if (needWrapping) {
            token = predictWrappedToken(source, address(this), sourceChainToken);
            if (!isWrappedToken(token)) {
                createWrappedToken(source, sourceChainToken);
            }
        } else {
            token = getOriginalToken(sourceChainToken);
        }
    }

    /**
     * @dev Get original token from wrapped token
     * @param token Wrapped token
     * @return Original token
     */
    function getOriginalToken(Token token) internal view returns (Token) {
        StorageKey tokenKey = _WRAPPED_TO_ORIGINAL.derive(token);
        return Token.wrap(tokenKey.readAddress());
    }

    /**
     * @dev Get salt for creating wrapped token
     * @param chain Chain ID
     * @param token Token to wrap
     * @return Salt
     */
    function getSalt(ChainId chain, Token token) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(chain, token));
    }

    /**
     * @dev Query wrapped token
     * @param target The target contract to query
     * @param token Token to query
     * @return Whether the token is wrapped token
     */
    function queryIsWrappedToken(IExtsload target, Token token) internal view returns (bool) {
        StorageKey tokenKey = _WRAPPED_TO_ORIGINAL.derive(token);
        return target.extsload(tokenKey) != hex"00";
    }
}
