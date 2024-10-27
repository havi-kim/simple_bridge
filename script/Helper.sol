// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "src/mocks/MintFreeERC20.sol";
import "src/Bridge.sol";
import "test/shared/TestUtils.sol";
import "src/types/Messages.sol";

contract Helper is Script, TestUtils {
    function run() public {
        address user0 = vm.envOr("USER0", address(0));
        address user1 = vm.envOr("USER1", address(0));
        address user2 = vm.envOr("USER2", address(0));
        uint256 pk0 = vm.envOr("PK0", uint256(0));
        uint256 pk1 = vm.envOr("PK1", uint256(0));
        uint256 pk2 = vm.envOr("PK2", uint256(0));
        address bridgeAddr;
        // This is for anvil (hardhat) test
        if (user0 == address(0)) {
            user0 = 0x4B246Da409f5265f523464a096F673884FE8B6eA;
            user1 = bob;
            user2 = trudy;
            pk0 = uint256(0xd82055a853f0e219787ee56beb191591291c521e61d7303e5b715a02aea41529);
            pk1 = bobPk;
            pk2 = trudyPk;
            bridgeAddr = address(0xdb10fEFfc6C65f23a30809A9D5B72fDF84c4B49d);
        }

        IBridge bridge = IBridge(bridgeAddr);

        SetChainConfigMessage memory message0 = SetChainConfigMessage({
            chainId: ChainId.wrap(17000),
            minimumConfirmation: 1,
            separator: bytes32(0)
        });
        bytes32 message0Hash = keccak256(abi.encode(message0));
        bytes[] memory signaturesOfMessage0 = new bytes[](3);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk0, message0Hash);
        signaturesOfMessage0[0] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(pk1, message0Hash);
        signaturesOfMessage0[1] = bytes.concat(r, s, bytes1(v));
        (v, r, s) = vm.sign(pk2, message0Hash);
        signaturesOfMessage0[2] = bytes.concat(r, s, bytes1(v));

        vm.startBroadcast(pk0);
        bridge.setMinimumConfirmation(message0, signaturesOfMessage0);

        vm.stopBroadcast();

        // Log the address
    }
}
