// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library Events {
    event LiquidityAdded(
        address indexed user,
        uint256 amountA,
        uint256 amountB
    );
    event Swapped(
        address indexed user,
        uint256 amountIn,
        uint256 amountOut,
        uint256 reward
    );
    event LiquidityRemoved(
        address indexed user,
        uint256 amountA,
        uint256 amountB
    );
    event RewardsClaimed(address indexed user, uint256 amount);
    event PoolCreated(address tokenA, address tokenB, bytes32 poolId);
    event PoolRemoved(address tokenA, address tokenB, bytes32 poolId);
    event RewardRateUpdated(uint256 oldRate, uint256 rewardRate);
}