//SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

import "openzeppelin-solidity-2.3.0/contracts/math/Math.sol";
import "openzeppelin-solidity-2.3.0/contracts/math/SafeMath.sol";
import "openzeppelin-solidity-2.3.0/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity-2.3.0/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity-2.3.0/contracts/utils/ReentrancyGuard.sol";
import "hardhat/console.sol";
// Inheritance
import "../interfaces/IStakingRewards.sol";
import "./RewardsDistributionRecipient.sol";

contract StakingRewards is IStakingRewards, RewardsDistributionRecipient, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */
    // 奖励的 token 合约
    IERC20 public rewardsToken;
    // 质押代币 LPToken 合约
    IERC20 public stakingToken;
    // 质押挖矿结束时间
    uint256 public periodFinish = 0;
    // 挖矿速率 每秒挖矿奖励的数量  挖矿奖励总量除以挖矿奖励时长，得到挖矿速率 rewardRate
    uint256 public rewardRate = 0;
    // 挖矿时间 默认60天
    uint256 public rewardsDuration = 60 days;
    // 最近一次更新时间
    uint256 public lastUpdateTime;
    // 每次奖励数量
    uint256 public rewardPerTokenStored;
    // 用户的每单位 token 奖励数量
    mapping(address => uint256) public userRewardPerTokenPaid;
    // 用户的奖励数量
    mapping(address => uint256) public rewards;

    // 总质押量
    uint256 private _totalSupply;
    // 用户质押余额
    mapping(address => uint256) private _balances;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _rewardsDistribution,   //  owenr address
        address _rewardsToken,          //  奖励的token
        address _stakingToken           //  质押的token
    ) public {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        rewardsDistribution = _rewardsDistribution;
    }

    /* ========== VIEWS ========== */
    // 总质押奖励
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    // 用户质押的余额
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    // 从当前区块时间和挖矿结束时间中，取最小值。
    // 挖矿未结束就是当前区块时间
    // 当完矿结束时 返回的就是 区块结束时间
    // 有奖励的最近区块数
    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    // 获取每单位 质押代币的奖励数量
    // 挖矿结束后则 不会再产生增量，rewardPerTokenStored就不会增加。
    // 每单位 Token 奖励数量
    function rewardPerToken() public view returns (uint256) {
        // 总质押量为0  就返回每次奖励
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        // 
        return
        // 每次奖励 + 最后更新时间 / 挖矿速率 / 1*(10**18)+总量
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
            );
    }
    // 计算用户当前的挖矿奖励。
    // 计算 每质押单位代币的挖矿奖励
    // 用户已赚但未提取的奖励数量
    function earned(address account) public view returns (uint256) {
        // 每质押代币的挖矿奖励 * 用户的质押额度 得到增量的总挖矿奖励 + 之前已经存储的挖矿奖励 = 当前总挖矿奖励
        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }
    // 挖矿奖励总量
    function getRewardForDuration() external view returns (uint256) {
        return rewardRate.mul(rewardsDuration);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stakeWithPermit(uint256 amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);

        // permit
        IUniswapV2ERC20(address(stakingToken)).permit(msg.sender, address(this), amount, deadline, v, r, s);

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    // 质押代币函数
    function stake(uint256 amount) external nonReentrant updateReward(msg.sender) {
        // 判断质押的额度
        require(amount > 0, "Cannot stake 0");
        // 更新质押额度
        _totalSupply = _totalSupply.add(amount);
        // 更新用户质押额度
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        // 质押代币转入合约中
        console.log(msg.sender);
        console.log(address(this));
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    // 提取质押代币
    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        // 检测提取质押代币
        require(amount > 0, "Cannot withdraw 0");
        // 更新质押总量
        _totalSupply = _totalSupply.sub(amount);
        // 更新用户质押额度
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        // 合约中的额度转入调用者
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
    // 领取挖矿奖励
    function getReward() public nonReentrant updateReward(msg.sender) {
        // 获取当前用户 可以提取的简历余额
        uint256 reward = rewards[msg.sender];
        console.log("reward", reward);
        if (reward > 0) {
            // 先清空在转账
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }
    
    // 提取质押 领取奖励
    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */
    // 该函数由工厂合约触发执行，只会被触发一次
    //  设置时间每秒 奖励的额度
    function notifyRewardAmount(uint256 reward) external onlyRewardsDistribution updateReward(address(0)) {
        // 区块时间要大于结束时间
        if (block.timestamp >= periodFinish) {
            // 挖矿总量 / 挖矿奖励时间 得到挖矿速率 == 每秒挖矿的数量
            rewardRate = reward.div(rewardsDuration);
            console.log("rewardRate", rewardRate);
        } else {
            // 在原有的池子中增加 奖励
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
            console.log("add rewardRate", rewardRate);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        // 获取当前合约中有多少 奖励的token
        uint balance = rewardsToken.balanceOf(address(this));
        // 计算挖矿总量 要小于或者等于  
        // 取保挖矿奖励是充足的
        // 每秒奖励额度 <= 当前合约中 奖励的额度 / 挖矿天数
        require(rewardRate <= balance.div(rewardsDuration), "Provided reward too high");

        //  更新设置的挖矿时间
        lastUpdateTime = block.timestamp;
        // 当前区块时间+挖矿时长 得到挖矿结束时间
        periodFinish = block.timestamp.add(rewardsDuration);
        console.log("periodFinish", periodFinish);
        emit RewardAdded(reward);
    }

    /* ========== MODIFIERS ========== */

    // 更新奖励
    modifier updateReward(address account) {
        // 代币奖励
        rewardPerTokenStored = rewardPerToken();
        // 获取最小时间
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            //  获取已经挣了多少钱
            rewards[account] = earned(account);
            // 用户每秒奖励
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}

interface IUniswapV2ERC20 {
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}
