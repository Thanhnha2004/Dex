// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "lib/forge-std/src/Script.sol";
import {Dex} from "src/core/Dex.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDex is Script {
    function run() external returns(Dex, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getNetworkConfig(block.chainid);
        vm.startBroadcast();
        Dex dex = new Dex(
            networkConfig.initialSupply
        );
        vm.stopBroadcast();
        return (dex, helperConfig);
    }
}
