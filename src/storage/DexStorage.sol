// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/// @title DEX Storage
/// @notice Centralized storage for DEX state
abstract contract DexStorage {
    /// @notice Pool data structure
    struct Pool {
        address tokenA;
        address tokenB;
        uint256 reserveA;
        uint256 reserveB;
        uint256 totalLiquidity;
        uint256 accumulatedRewards;
    }

    /// @notice Pool ID to pool mapping
    mapping(bytes32 => Pool) public s_pools;

    /// @notice User liquidity per pool
    mapping(bytes32 => mapping(address => uint256)) public liquidityProvided; 

    /// @notice Reward rate (1000 = 10%)
    uint256 public rewardRate = 1000; // 1% (1e4 = 100%)
    /// @notice Pending rewards per user
    mapping(address => uint256) public pendingRewards;
    /// @notice Reward debt per user per pool
    mapping(bytes32 => mapping(address => uint256)) public rewardDebt;
}