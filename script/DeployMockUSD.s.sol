// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockUSD} from "../src/MockUSD.sol";

contract DeployMockUSD is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        new MockUSD("Drosera USD", "dUSD", 100_000e18);

        vm.stopBroadcast();
    }
}