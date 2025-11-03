pragma solidity ^0.8.0;
import {console} from "lib/forge-std/src/console.sol";
import {Events} from "../utils/Events.sol";
import {Constants} from "../utils/Constants.sol";
import "../utils/Errors.sol";
import {DexStorage} from "../storage/DexStorage.sol";
import "./Pool.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

abstract contract Swap is DexStorage, Pool {

    /// @notice Swap tokens in a pool
    /// @param amountIn Amount of input tokens
    /// @param tokenIn Address of input token
    /// @param tokenOut Address of output token
    /// @param minAmountOut Minimum output amount (slippage protection)
    /// @param deadline Transaction deadline timestamp
    function swap(
        uint256 amountIn,
        address tokenIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 deadline
    ) public {
        bytes32 poolId = getPoolId(tokenIn, tokenOut);
        Pool storage pool = s_pools[poolId];

        // Validation checks
        if(block.timestamp > deadline) {
            revert Dex__TransactionExpired();
        }
        if(tokenIn == address(0) || tokenOut == address(0)){
            revert Dex__TokensNotSet();
        }
        if(amountIn == 0){
            revert Dex__AmountMustBeAboveZero();
        }
        if(pool.reserveA == 0 || pool.reserveB == 0){
            revert Dex__InsufficientLiquidity();
        }
        if(pool.tokenA == address(0)){
            revert Dex__PoolNotFound();
        }

        // Determine swap direction (A->B or B->A)
        bool isSwapAForB = (tokenIn == pool.tokenA);
        
        // Transfer input tokens
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // Calculate output amount
        uint256 amountOut;
        uint256 fee;
        
        if(isSwapAForB) {
            (amountOut, fee) = getSwapToken1Estimate(amountIn, pool);
            
            // Slippage protection
            if(amountOut < minAmountOut) {
                revert Dex__InsufficientOutputAmount();
            }
            if(pool.reserveB < amountOut) {
                revert Dex__InsufficientLiquidity();
            }
            
            // Update reserves
            pool.reserveA += amountIn;
            pool.reserveB -= amountOut;
        } else {
            (amountOut, fee) = getSwapToken2Estimate(amountIn, pool);
            
            // Slippage protection
            if(amountOut < minAmountOut) {
                revert Dex__InsufficientOutputAmount();
            }
            if(pool.reserveA < amountOut) {
                revert Dex__InsufficientLiquidity();
            }
            
            // Update reserves
            pool.reserveB += amountIn;
            pool.reserveA -= amountOut;
        }

        // Calculate and distribute rewards
        uint256 reward = (fee * rewardRate) / Constants.FEE_DENOMINATOR;
        if(reward > 0) {
            _updateRewards(reward, pool);
        }

        // Transfer output tokens
        IERC20(tokenOut).transfer(msg.sender, amountOut);
        
        emit Events.Swapped(msg.sender, amountIn, amountOut, reward);
    }

    /// @notice Calculate output amount for A->B swap
    /// @param amountAIn Amount of token A to swap
    /// @param pool Pool storage reference
    /// @return amountBOut Amount of token B to receive
    /// @return fee Swap fee amount
    function getSwapToken1Estimate(
        uint256 amountAIn, 
        Pool storage pool
    ) internal view returns(uint256 amountBOut, uint256 fee){
        fee = (amountAIn  * Constants.SWAP_FEE) / Constants.FEE_DENOMINATOR;
        uint256 numerator = pool.reserveB * amountAIn;
        uint256 denominator = pool.reserveA + amountAIn - fee;
        amountBOut = numerator / denominator;
    }

    /// @notice Calculate output amount for B->A swap
    /// @param amountBIn Amount of token B to swap
    /// @param pool Pool storage reference
    /// @return amountAOut Amount of token A to receive
    /// @return fee Swap fee amount
    function getSwapToken2Estimate(
        uint256 amountBIn, 
        Pool storage pool
    ) internal view returns(uint256 amountAOut, uint256 fee){
        fee = (amountBIn * Constants.SWAP_FEE) / Constants.FEE_DENOMINATOR;
        uint256 numerator = pool.reserveA * amountBIn;
        uint256 denominator = pool.reserveB + amountBIn - fee;
        amountAOut = numerator / denominator;
    }

    /// @notice Update accumulated rewards for liquidity providers
    /// @param newReward New reward amount to distribute
    /// @param pool Pool storage reference
    function _updateRewards(
        uint256 newReward, 
        Pool storage pool
    ) internal {
        if (pool.totalLiquidity > 0) {
            pool.accumulatedRewards += (newReward * 1e18) / pool.totalLiquidity;
        }
    }
}