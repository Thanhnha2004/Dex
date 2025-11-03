pragma solidity ^0.8.0;
import {console} from "lib/forge-std/src/console.sol";
import {Events} from "../utils/Events.sol";
import {Constants} from "../utils/Constants.sol";
import "../utils/Errors.sol";
import {DexStorage} from "../storage/DexStorage.sol";

/// @title Pool Management
/// @notice Create and remove liquidity pools
abstract contract Pool is DexStorage {

    /// @notice Create new pool for token pair
    /// @param tokenA First token address
    /// @param tokenB Second token address
    function createPool(address tokenA, address tokenB) public {
        if(tokenA == address(0) || tokenB == address(0) || tokenA == tokenB){
            revert Dex__InvalidToken();
        }

        bytes32 poolId = getPoolId(tokenA, tokenB);

        if(s_pools[poolId].tokenA != address(0)){
            revert Dex__PoolAlreadyExists();
        }

        s_pools[poolId] = Pool({
            tokenA: tokenA,
            tokenB: tokenB,
            reserveA: 0,
            reserveB: 0,
            totalLiquidity: 0,
            accumulatedRewards: 0
        });

        emit Events.PoolCreated(tokenA, tokenB, poolId);
    }

    /// @notice Remove empty pool
    /// @param tokenA First token address
    /// @param tokenB Second token address
    function removePool(address tokenA, address tokenB) public {
        if(tokenA == address(0) || tokenB == address(0) || tokenA == tokenB){
            revert Dex__InvalidToken();
        }

        bytes32 poolId = getPoolId(tokenA, tokenB);
        Pool storage pool = s_pools[poolId];

        if(pool.tokenA == address(0)){
            revert Dex__PoolNotFound();
        }
        if(pool.totalLiquidity != 0){
            revert Dex__PoolHasLiquidity();
        }

        delete s_pools[poolId];

        emit Events.PoolRemoved(tokenA, tokenB, poolId);
    }

    /// @notice Generate unique pool ID
    /// @param tokenA First token address
    /// @param tokenB Second token address
    /// @return poolId Unique pool identifier
    function getPoolId(address tokenA, address tokenB) public pure returns (bytes32) {
        return tokenA < tokenB
            ? keccak256(abi.encodePacked(tokenA, tokenB))
            : keccak256(abi.encodePacked(tokenB, tokenA));
    }
}