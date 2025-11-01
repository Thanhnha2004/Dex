pragma solidity ^0.8.0;
import {console} from "lib/forge-std/src/console.sol";
import {Events} from "../utils/Events.sol";
import {Constants} from "../utils/Constants.sol";
import "../utils/Errors.sol";
import {DexStorage} from "../storage/DexStorage.sol";

/**
 * @title Pool
 * @notice Quản lý liquidity pools với role-based access control
*/
abstract contract Pool is DexStorage {

    /**
     * @notice Tạo pool mới cho cặp token
     * @dev Chỉ POOL_MANAGER_ROLE có quyền gọi. Reverts nếu tokens không hợp lệ hoặc pool đã tồn tại.
     * @param tokenA Địa chỉ token đầu tiên
     * @param tokenB Địa chỉ token thứ hai
    */
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

    /**
     * @notice Xóa pool của một cặp token
     * @dev Chỉ DEFAULT_ADMIN_ROLE có quyền gọi. Reverts nếu pool không tồn tại hoặc vẫn còn liquidity.
     * @param tokenA Địa chỉ token đầu tiên
     * @param tokenB Địa chỉ token thứ hai
    */
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

    /**
     * @notice Tính toán ID duy nhất cho pool từ 2 token addresses
     * @dev Token có địa chỉ nhỏ hơn đứng trước để đảm bảo getPoolId(A,B) == getPoolId(B,A).
     * @param tokenA Địa chỉ token đầu tiên
     * @param tokenB Địa chỉ token thứ hai
     * @return poolId Hash 32 bytes định danh pool
    */
    function getPoolId(address tokenA, address tokenB) public pure returns (bytes32) {
        return tokenA < tokenB
            ? keccak256(abi.encodePacked(tokenA, tokenB))
            : keccak256(abi.encodePacked(tokenB, tokenA));
    }
}