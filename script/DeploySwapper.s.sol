// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Swapper} from "../src/Swapper.sol";

contract DeploySwapper is Script {
    uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
    function run() public {
        vm.startBroadcast(deployerPrivateKey);
        Swapper swapper = new Swapper();
        console.log("Deployed swapper at address: ", address(swapper));
        vm.stopBroadcast();
    }
}

// forge script DeploySwapper --rpc-url bartio --broadcast --verify
