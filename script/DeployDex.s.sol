// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "lib/forge-std/src/Script.sol";
import {Dex} from "src/core/Dex.sol";


contract DeployDex is Script {
    function run() external returns(Dex) {
        vm.startBroadcast(msg.sender);
        Dex dex = new Dex(1_000_000 * 1e18);
        vm.stopBroadcast();
        return dex;
    }
}
