// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "lib/forge-std/src/Script.sol";
import {TokenAhn} from "src/core/TokenAhn.sol";


contract DeployTokenAhn is Script {
    function run() external returns(TokenAhn) {
        vm.startBroadcast();
        TokenAhn tokenAhn = new TokenAhn(1_000_000 * 1e18);
        vm.stopBroadcast();
        return tokenAhn;
    }
}
