//SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

import 'openzeppelin-solidity-2.3.0/contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-solidity-2.3.0/contracts/ownership/Ownable.sol';

import './StakingRewards.sol';

contract StakingRewardsFactory is Ownable {
    // immutables
    // 用作奖励的代币
    address public rewardsToken;
    // 质押挖矿开始时间
    uint public stakingRewardsGenesis;

    // the staking tokens for which the rewards contract has been deployed
    // 用来质押的代币数组 LPToken address
    address[] public stakingTokens;

    // info about rewards for a particular staking token
    struct StakingRewardsInfo {
        address stakingRewards; //  质押合约地址
        uint rewardAmount;      //  质押合约每周期的奖励总量
    }

    // rewards info by staking token
    // 用来保存质押代币和质押合约之间的映射
    mapping(address => StakingRewardsInfo) public stakingRewardsInfoByStakingToken;

    constructor(
        address _rewardsToken,  //  奖励token
        uint _stakingRewardsGenesis //  开始挖矿时间
    ) Ownable() public {
        require(_stakingRewardsGenesis >= block.timestamp, 'StakingRewardsFactory::constructor: genesis too soon');

        rewardsToken = _rewardsToken;
        stakingRewardsGenesis = _stakingRewardsGenesis;
    }

    ///// permissioned functions

    // deploy a staking reward contract for the staking token, and store the reward amount
    // the reward will be distributed to the staking reward contract no sooner than the genesis
    // 部署StakingRewards 合约的函数
    function deploy(
        address stakingToken,   //  质押代币 LPToken
        uint rewardAmount       //  奖励数量
    ) public onlyOwner {
        // lp token
        StakingRewardsInfo storage info = stakingRewardsInfoByStakingToken[stakingToken];
        // lp token 地址不能为空
        require(info.stakingRewards == address(0), 'StakingRewardsFactory::deploy: already deployed');

        info.stakingRewards = address(new StakingRewards(/*_rewardsDistribution=*/ address(this), rewardsToken, stakingToken));
        info.rewardAmount = rewardAmount;
        stakingTokens.push(stakingToken);
    }

    ///// permissionless functions

    // call notifyRewardAmount for all staking tokens.
    // 用来挖矿的代币转入质押合约中，并启动挖矿
    // 遍历质押代币数组，对每个代币再调用
    // 用来挖矿的LPToken 代币转入质押合约中。
    function notifyRewardAmounts() public {
        require(stakingTokens.length > 0, 'StakingRewardsFactory::notifyRewardAmounts: called before any deploys');
        for (uint i = 0; i < stakingTokens.length; i++) {
            notifyRewardAmount(stakingTokens[i]);
        }
    }

    // notify reward amount for an individual staking token.
    // this is a fallback in case the notifyRewardAmounts costs too much gas to call for all contracts
    // 这个函数的作用就是，把用来挖矿的代币 转入到质押合约中（奖励代币要熬先转入工厂合约中）。
    // 再调用的时候实现将奖励代币转到质押合约中。
    function notifyRewardAmount(address stakingToken) public {
        // 检查挖矿开始时间
        require(block.timestamp >= stakingRewardsGenesis, 'StakingRewardsFactory::notifyRewardAmount: not ready');
        // lp token
        StakingRewardsInfo storage info = stakingRewardsInfoByStakingToken[stakingToken];
        // address != 0;
        require(info.stakingRewards != address(0), 'StakingRewardsFactory::notifyRewardAmount: not deployed');

        // 质押合约周期奖励
        if (info.rewardAmount > 0) {
            // 取出指定的质押代币 
            uint rewardAmount = info.rewardAmount;
            // 避免重复下发奖励
            info.rewardAmount = 0;
            // 判断奖励的代币是否成功转账
            require(
                IERC20(rewardsToken).transfer(info.stakingRewards, rewardAmount),
                'StakingRewardsFactory::notifyRewardAmount: transfer failed'
            );
            // 递归调用自己？
            StakingRewards(info.stakingRewards).notifyRewardAmount(rewardAmount);
        }
    }
}