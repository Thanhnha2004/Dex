// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "lib/forge-std/src/Script.sol";
import {Constants} from "src/utils/Constants.sol";

contract HelperConfig is Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        uint256 initialSupply;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public s_networkConfigs;

    constructor() {
        s_networkConfigs[Constants.BASE_SEPOLIA_CHAIN_ID] = getSepoliaNetworkConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getNetworkConfig(block.chainid);
    }

    function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            initialSupply: 1_000_000 * 1e18
        });
    }

    function getLocalNetworkConfig() public returns (NetworkConfig memory) {
        localNetworkConfig = NetworkConfig({
            initialSupply: 1_000_000 * 1e18
        });

        return localNetworkConfig;
    }

    function getNetworkConfig(uint256 chainId) public returns (NetworkConfig memory) {
        if (chainId == Constants.BASE_SEPOLIA_CHAIN_ID) {
            return s_networkConfigs[chainId];
        } else if (chainId == Constants.ANVIL_CHAIN_ID) {
            return getLocalNetworkConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }
}
