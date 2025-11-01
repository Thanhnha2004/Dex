// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

abstract contract DexStorage {
    struct Pool {
        address tokenA;
        address tokenB;
        uint256 reserveA;
        uint256 reserveB;
        uint256 totalLiquidity;
        uint256 accumulatedRewards;
    }

    mapping(bytes32 => Pool) public s_pools;

    // Liquidity tracking
    mapping(bytes32 => mapping(address => uint256)) public liquidityProvided; 

    // Reward tracking
    uint256 public rewardRate = 1000; // 1% (1e4 = 100%)
    mapping(address => uint256) public pendingRewards;
    mapping(bytes32 => mapping(address => uint256)) public rewardDebt;
}