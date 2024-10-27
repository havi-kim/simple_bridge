// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "src/mocks/MintFreeERC20.sol";
import "src/Bridge.sol";
import "test/shared/TestUtils.sol";

contract OneTouchDeployer is Script, TestUtils {
    function run() public {
        address user0 = vm.envOr("USER0", address(0));
        address user1 = vm.envOr("USER1", address(0));
        address user2 = vm.envOr("USER2", address(0));
        uint256 pk0 = vm.envOr("PK0", uint256(0));
        uint256 pk1 = vm.envOr("PK1", uint256(0));
        uint256 pk2 = vm.envOr("PK2", uint256(0));

        // This is for anvil (hardhat) test
        if (user0 == address(0)) {
            user0 = bob;
            user1 = alice;
            user2 = trudy;
            pk0 = bobPk;
            pk1 = alicePk;
            pk2 = trudyPk;
        }

        vm.startBroadcast(pk0);

        // Create params for Bridge
        address[] memory initialSigners = new address[](3);
        initialSigners[0] = user0;
        initialSigners[1] = user1;
        initialSigners[2] = user2;
        ChainId[] memory chainIds = new ChainId[](2);
        chainIds[0] = ChainId.wrap(1);
        chainIds[1] = ChainId.wrap(2);
        uint256[] memory minimumConfirmations = new uint256[](2);
        minimumConfirmations[0] = 1;
        minimumConfirmations[1] = 1;

        // Deploy
        Bridge bridge = new Bridge(initialSigners, chainIds, minimumConfirmations);
        IERC20Extend TestToken = new MintFreeERC20("Test", "TST", 18);

        // Mint & Approve
        TestToken.mint(user0, 2e30);

        // Log the address
        console.log("Bridge address:", address(bridge));
        console.log("Test Token address:", address(TestToken));

        vm.stopBroadcast();
    }
}
