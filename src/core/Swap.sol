pragma solidity ^0.8.0;
import {console} from "lib/forge-std/src/console.sol";
import {Events} from "../utils/Events.sol";
import {Constants} from "../utils/Constants.sol";
import "../utils/Errors.sol";
import {DexStorage} from "../storage/DexStorage.sol";
import "./Pool.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

abstract contract Swap is DexStorage, Pool {

    function swapAForB(
        uint256 amountAIn, 
        address tokenA, 
        address tokenB, 
        uint256 minAmountBOut, 
        uint256 deadline
    ) public {
        bytes32 poolId = getPoolId(tokenA, tokenB);
        Pool storage pool = s_pools[poolId];

        if(block.timestamp > deadline) {
            revert Dex__TransactionExpired();
        }
        if(tokenA == address(0) || tokenB == address(0)){
            revert Dex__TokensNotSet();
        }
        if(amountAIn == 0){
            revert Dex__AmountMustBeAboveZero();
        }
        if(pool.reserveA == 0 || pool.reserveB == 0){
            revert Dex__InsufficientLiquidity();
        }
        if(pool.tokenA == address(0)){
            revert Dex__PoolNotFound();
        }

        IERC20(pool.tokenA).transferFrom(msg.sender, address(this), amountAIn);

        // Calculate output amount using constant product formula
        (uint256 amountBOut, uint256 fee) = getSwapToken1Estimate(amountAIn, pool);

        // SLIPPAGE PROTECTION
        if(amountBOut < minAmountBOut) {
            revert Dex__InsufficientOutputAmount();
        }
        if(pool.reserveB < amountBOut) {
            revert Dex__InsufficientLiquidity();
        }

        // Update reserves
        pool.reserveA += amountAIn;
        pool.reserveB -= amountBOut;

        // Calculate and distribute rewards
        uint256 reward = (fee * rewardRate) / Constants.FEE_DENOMINATOR;
        if(reward > 0) {
            _updateRewards(reward, pool);
        }

        IERC20(pool.tokenB).transfer(msg.sender, amountBOut);
        
        emit Events.Swapped(msg.sender, amountAIn, amountBOut, reward);
    }

    function swapBForA(
        uint256 amountBIn, 
        address tokenA, 
        address tokenB, 
        uint256 minAmountAOut, 
        uint256 deadline
    ) public {
        bytes32 poolId = getPoolId(tokenA, tokenB);
        Pool storage pool = s_pools[poolId];

        if(block.timestamp > deadline) {
            revert Dex__TransactionExpired();
        }
        if(tokenA == address(0) || tokenB == address(0)){
            revert Dex__TokensNotSet();
        }
        if(amountBIn == 0){
            revert Dex__AmountMustBeAboveZero();
        }
        if(pool.reserveA == 0 || pool.reserveB == 0){
            revert Dex__InsufficientLiquidity();
        }
        if(pool.tokenA == address(0)){
            revert Dex__PoolNotFound();
        }

        IERC20(pool.tokenB).transferFrom(msg.sender, address(this), amountBIn);

        (uint256 amountAOut, uint256 fee) = getSwapToken2Estimate(amountBIn, pool);

        // SLIPPAGE PROTECTION
        if(amountAOut < minAmountAOut) {
            revert Dex__InsufficientOutputAmount();
        }
        if(pool.reserveA < amountAOut) {
            revert Dex__InsufficientLiquidity();
        }

        // Update reserves
        pool.reserveB += amountBIn;
        pool.reserveA -= amountAOut;

        // Calculate and distribute rewards
        uint256 reward = (fee * rewardRate) / Constants.FEE_DENOMINATOR;
        if(reward > 0) {
            _updateRewards(reward, pool);
        }

        IERC20(pool.tokenA).transfer(msg.sender, amountAOut);

        emit Events.Swapped(msg.sender, amountBIn, amountAOut, reward);
    }

    function getSwapToken1Estimate(
        uint256 amountAIn, 
        Pool storage pool
    ) internal view returns(uint256 amountBOut, uint256 fee){
        fee = (amountAIn  * Constants.SWAP_FEE) / Constants.FEE_DENOMINATOR;
        uint256 numerator = pool.reserveB * amountAIn;
        uint256 denominator = pool.reserveA + amountAIn - fee;
        amountBOut = numerator / denominator;
    }

    // function getSwapToken1EstimateGivenToken2(uint256 amountBOut, Pool storage pool) internal view returns(uint256 amountAIn) {
    //     uint256 numerator = pool.reserveA * amountBOut;
    //     uint256 denominator = pool.reserveB - amountBOut;
    //     amountAIn = numerator / denominator;
    // }

    function getSwapToken2Estimate(
        uint256 amountBIn, 
        Pool storage pool
    ) internal view returns(uint256 amountAOut, uint256 fee){
        fee = (amountBIn * Constants.SWAP_FEE) / Constants.FEE_DENOMINATOR;
        uint256 numerator = pool.reserveA * amountBIn;
        uint256 denominator = pool.reserveB + amountBIn - fee;
        amountAOut = numerator / denominator;
    }

    // function getSwapToken2EstimateGivenToken1(uint256 amountAOut, Pool storage pool) internal view returns(uint256 amountBIn) {
    //     uint256 numerator = pool.reserveB * amountAOut;
    //     uint256 denominator = pool.reserveA - amountAOut;
    //     amountBIn = numerator / denominator;
    // }

    function _updateRewards(
        uint256 newReward, 
        Pool storage pool
    ) internal {
        if (pool.totalLiquidity > 0) {
            pool.accumulatedRewards += (newReward * 1e18) / pool.totalLiquidity;
        }
    }
}