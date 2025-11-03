pragma solidity ^0.8.0;
import {console} from "lib/forge-std/src/console.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {Events} from "../utils/Events.sol";
import {Constants} from "../utils/Constants.sol";
import "../utils/Errors.sol";
import {DexStorage} from "../storage/DexStorage.sol";
import {Liquidity} from "./Liquidity.sol";
import {Swap} from "./Swap.sol";
import {Reward} from "./Reward.sol";
import {Getter} from "./Getter.sol";
import {Pool} from "./Pool.sol";

/// @title Decentralized Exchange (DEX)
/// @notice AMM DEX with liquidity mining rewards
/// @dev Uses constant product formula (x*y=k) and role-based access control
contract Dex is ReentrancyGuard, AccessControl, Pool, Liquidity, Swap, Reward, Getter {

    bytes32 internal constant POOL_MANAGER_ROLE = Constants.POOL_MANAGER_ROLE;
    bytes32 public constant RATE_MANAGER_ROLE = Constants.RATE_MANAGER_ROLE;

    /// @notice Initialize DEX with reward token supply
    /// @param initialSupply Initial PRT token supply
    constructor(uint256 initialSupply) ERC20("Pool Reward Token", "PRT") {
        _mint(msg.sender, initialSupply);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // Setup role hierarchy
        _setRoleAdmin(POOL_MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(RATE_MANAGER_ROLE, DEFAULT_ADMIN_ROLE);

        _grantRole(POOL_MANAGER_ROLE, msg.sender);
        _grantRole(RATE_MANAGER_ROLE, msg.sender);
    }

    function createPoolFromDex(
        address tokenA,
        address tokenB
    ) external nonReentrant onlyRole(POOL_MANAGER_ROLE){
        createPool(tokenA, tokenB);
    }

    function removePoolFromDex(
        address tokenA,
        address tokenB
    ) external nonReentrant onlyRole(POOL_MANAGER_ROLE){
        removePool(tokenA, tokenB);
    }

    function addLiquidityFromDex(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 minLiquidity
    ) external nonReentrant{
        addLiquidity(
            tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, minLiquidity
        );
    }

    function removeLiquidityFromDex(
        address tokenA,
        address tokenB,
        uint256 minAmountA,
        uint256 minAmountB
    ) external nonReentrant{
        removeLiquidity(tokenA, tokenB, minAmountA, minAmountB);
    }

    function swapFromDex(
        uint256 amountIn,
        address tokenIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 deadline
    ) external nonReentrant{
        swap(amountIn, tokenIn, tokenOut, minAmountOut, deadline);
    }

    function claimRewardsFromDex() external nonReentrant{
        claimRewards();
    }

    function setRewardRateFromDex(
        uint256 _rewardRate
    ) external nonReentrant onlyRole(RATE_MANAGER_ROLE){
        setRewardRate(_rewardRate);
    }

    function getLiquidityProvidedFromDex(
        address tokenA,
        address tokenB
    ) external nonReentrant{
        getLiquidityProvided(tokenA, tokenB);
    }

    function getTotalLiquidityFromDex(
        address tokenA,
        address tokenB
    ) external nonReentrant{
        getTotalLiquidity(tokenA, tokenB);
    }

}