// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title DEX Constants
/// @notice System-wide constant values
library Constants {
    /// @notice Minimum liquidity locked forever
    uint256 public constant MINIMUM_LIQUIDITY = 1000;
    /// @notice Fee denominator (10000 = 100%)
    uint256 public constant FEE_DENOMINATOR = 10000;
    /// @notice Swap fee (30 = 0.3%)
    uint256 public constant SWAP_FEE = 30;
    /// @notice Pool manager role identifier
    bytes32 public constant POOL_MANAGER_ROLE = keccak256("POOL_MANAGER_ROLE");
    /// @notice Rate manager role identifier
    bytes32 public constant RATE_MANAGER_ROLE = keccak256("RATE_MANAGER_ROLE");

    uint256 public constant BASE_SEPOLIA_CHAIN_ID = 84532;
    uint256 public constant ANVIL_CHAIN_ID = 31337;
}