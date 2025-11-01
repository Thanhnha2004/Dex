// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IDexRouter {
    function factory() external view returns(address);
    function rewardToken() external view returns(address);

    // Liquidity functions
    function addLiquidity(
        address tokenA, 
        address tokenB,  
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin, 
        uint256 amountBMin,
        uint256 minLiquidity,
        address to
    ) external returns(
        uint256 amountA, 
        uint256 amountB, 
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA, 
        address tokenB,
        uint256 minAmountA,
        uint256 minAmountB,
        address to
    ) external returns(
        uint256 amountA, 
        uint256 amountB
    );

    // Swap functions
    function swapExactTokensForTokens(
        uint256 amountAIn, 
        address tokenA, 
        address tokenB, 
        uint256 minAmountBOut, 
        uint256 deadline,
        address to
    ) external;

    function swapTokensForExactTokens(
        uint256 amountAIn, 
        address tokenA, 
        address tokenB, 
        uint256 minAmountBOut, 
        uint256 deadline,
        address to
    ) external;
}