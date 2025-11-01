// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "lib/forge-std/src/Script.sol";
import {TokenHMG} from "src/core/TokenHMG.sol";


contract DeployTokenHMG is Script {
    function run() external returns(TokenHMG) {
        vm.startBroadcast();
        TokenHMG tokenHMG = new TokenHMG(1_000_000 * 1e18);
        vm.stopBroadcast();
        return tokenHMG;
    }
}
