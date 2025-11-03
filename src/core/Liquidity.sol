pragma solidity ^0.8.0;
import {console} from "lib/forge-std/src/console.sol";
import {Events} from "../utils/Events.sol";
import {Constants} from "../utils/Constants.sol";
import "../utils/Errors.sol";
import {DexStorage} from "../storage/DexStorage.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./Pool.sol";

abstract contract Liquidity is DexStorage, Pool {

    /// @notice Add liquidity to pool
    /// @param tokenA First token address
    /// @param tokenB Second token address
    /// @param amountADesired Desired tokenA amount
    /// @param amountBDesired Desired tokenB amount
    /// @param amountAMin Min tokenA (slippage protection)
    /// @param amountBMin Min tokenB (slippage protection)
    /// @param minLiquidity Min LP tokens to receive
    /// @return amountA Actual tokenA deposited
    /// @return amountB Actual tokenB deposited
    /// @return liquidity LP tokens minted
    function addLiquidity(
        address tokenA, 
        address tokenB,  
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin, 
        uint256 amountBMin,
        uint256 minLiquidity
    ) public returns(
        uint256 amountA, 
        uint256 amountB, 
        uint256 liquidity
    ) {
        address lq = msg.sender;
        if(tokenA == address(0) || tokenB == address(0)){
            revert Dex__TokensNotSet();
        }
        if(amountADesired <= 0 || amountBDesired <= 0){
            revert Dex__AmountMustBeAboveZero();
        }

        bytes32 poolId = getPoolId(tokenA, tokenB);
        Pool storage pool = s_pools[poolId];

        if(pool.tokenA == address(0)){
            revert Dex__PoolNotFound();
        }

        // Update pending rewards before changing liquidity
        _updateUserRewards(lq, poolId);

        // Tính toán amountA và amountB thực tế
        if (pool.totalLiquidity == 0) {
            amountA = amountADesired;
            amountB = amountBDesired;
            liquidity = sqrt(amountA * amountB);

            if(liquidity < Constants.MINIMUM_LIQUIDITY){  // Uniswap V2 burns first 1000 wei
                revert Dex__InsufficientLiquidityMinted();
            }

            // Burn first 1000 LP tokens
            pool.totalLiquidity = Constants.MINIMUM_LIQUIDITY;  // Locked forever
            liquidity = liquidity - Constants.MINIMUM_LIQUIDITY;

        } else {
            uint256 amountBOptimal = (amountADesired * pool.reserveB) / pool.reserveA;
        
            if (amountBOptimal <= amountBDesired) {
                if(amountBOptimal < amountBMin){
                    revert Dex__InsufficientBAmount();
                }
                amountA = amountADesired;
                amountB = amountBOptimal;
            } else {
                uint256 amountAOptimal = (amountBDesired * pool.reserveA) / pool.reserveB;
                if(amountAOptimal > amountADesired){
                    revert Dex__InsufficientAAmount();
                }
                if(amountAOptimal < amountAMin){
                    revert Dex__InsufficientAAmount();
                }
                amountA = amountAOptimal;
                amountB = amountBDesired;
            }
        
            liquidity = (amountA * pool.totalLiquidity) / pool.reserveA;
        }

        if(liquidity < minLiquidity){
            revert Dex__InsufficientLiquidityMinted();
        }

        // Transfer tokens
        IERC20(pool.tokenA).transferFrom(lq, address(this), amountADesired);
        IERC20(pool.tokenB).transferFrom(lq, address(this), amountBDesired);

        // Refund phần dư (nếu có)
        uint256 refundA = amountADesired - amountA;
        uint256 refundB = amountBDesired - amountB;

        if (refundA > 0) {
            IERC20(pool.tokenA).transfer(msg.sender, refundA);
        }
        if (refundB > 0) {
            IERC20(pool.tokenB).transfer(msg.sender, refundB);
        }

        // Update tracking
        liquidityProvided[poolId][lq] += liquidity;
        pool.totalLiquidity += liquidity;
        pool.reserveA += amountA;
        pool.reserveB += amountB;

        emit Events.LiquidityAdded(lq, amountA, amountB);

        return (amountA, amountB, liquidity);
    }

    /// @notice Remove liquidity from pool
    /// @param tokenA First token address
    /// @param tokenB Second token address
    /// @param minAmountA Min tokenA to receive
    /// @param minAmountB Min tokenB to receive
    function removeLiquidity(
        address tokenA, 
        address tokenB,
        uint256 minAmountA,
        uint256 minAmountB
    ) public {
        bytes32 poolId = getPoolId(tokenA, tokenB);
        Pool storage pool = s_pools[poolId];

        if(tokenA == address(0) || tokenB == address(0)){
            revert Dex__TokensNotSet();
        }
        uint256 liquidity = liquidityProvided[poolId][msg.sender];
        if(liquidity <= 0){
            revert Dex__NoLiquidityToRemove();
        }
        if(pool.tokenA == address(0)){
            revert Dex__PoolNotFound();
        }

        // Update pending rewards before removing liquidity
        _updateUserRewards(msg.sender, poolId);

        // Calculate share of pool
        uint256 amountA = (pool.reserveA * liquidity) / pool.totalLiquidity;
        uint256 amountB = (pool.reserveB * liquidity) / pool.totalLiquidity;

        // Slippage protection
        if(amountA < minAmountA || amountB < minAmountB){
            revert Dex__InsufficientOutputAmount();
        }

        // Update state before transfers
        liquidityProvided[poolId][msg.sender] = 0;
        pool.totalLiquidity -= liquidity;
        pool.reserveA -= amountA;
        pool.reserveB -= amountB;

        // Transfer tokens
        IERC20(pool.tokenA).transfer(msg.sender, amountA);
        IERC20(pool.tokenB).transfer(msg.sender, amountB);

        emit Events.LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /// @notice Update user rewards before liquidity changes
    /// @param user User address
    /// @param poolId Pool identifier
    function _updateUserRewards(address user, bytes32 poolId) internal {
        Pool storage pool = s_pools[poolId];
        uint256 userLiquidity = liquidityProvided[poolId][user];

        if (userLiquidity > 0) {
            uint256 pending = (userLiquidity *
                (pool.accumulatedRewards - rewardDebt[poolId][user])) / 1e18;
            pendingRewards[user] += pending;
            rewardDebt[poolId][user] = pool.accumulatedRewards;
        }
    }

    /// @notice Calculate square root (Babylonian method)
    /// @param x Input value
    /// @return y Square root of x
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}