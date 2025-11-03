pragma solidity ^0.8.0;
import {console} from "lib/forge-std/src/console.sol";
import {Events} from "../utils/Events.sol";
import {Constants} from "../utils/Constants.sol";
import "../utils/Errors.sol";
import {DexStorage} from "../storage/DexStorage.sol";
import "./Pool.sol";

/// @title View Functions
/// @notice Query pool and liquidity data
abstract contract Getter is DexStorage, Pool {

    /// @notice Get caller's liquidity in pool
    /// @param tokenA First token address
    /// @param tokenB Second token address
    /// @return Liquidity amount
    function getLiquidityProvided(address tokenA, address tokenB) public view returns(uint256){
        bytes32 poolId = getPoolId(tokenA, tokenB);
        return liquidityProvided[poolId][msg.sender];
    }

    /// @notice Get total pool liquidity
    /// @param tokenA First token address
    /// @param tokenB Second token address
    /// @return Total liquidity
    function getTotalLiquidity(address tokenA, address tokenB) public view returns(uint256){
        bytes32 poolId = getPoolId(tokenA, tokenB);
        Pool storage pool = s_pools[poolId];
        return pool.totalLiquidity;
    }
}