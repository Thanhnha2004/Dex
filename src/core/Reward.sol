pragma solidity ^0.8.0;
import {console} from "lib/forge-std/src/console.sol";
import {Events} from "../utils/Events.sol";
import {Constants} from "../utils/Constants.sol";
import "../utils/Errors.sol";
import {DexStorage} from "../storage/DexStorage.sol";
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

abstract contract Reward is DexStorage, ERC20 {

    function claimRewards() public {
        uint256 rewards = pendingRewards[msg.sender];
        if(rewards == 0){
            revert Dex__NoRewardsToClaim();
        }

        pendingRewards[msg.sender] = 0;
        _mint(msg.sender, rewards);

        emit Events.RewardsClaimed(msg.sender, rewards);
    }

    function setRewardRate(uint256 _rewardRate) public {
        if(_rewardRate > 10000){
            revert Dex__RewardRateTooHigh();
        }

        uint256 oldRate = rewardRate;
        rewardRate = _rewardRate;

        emit Events.RewardRateUpdated(oldRate, _rewardRate); 
    }

}