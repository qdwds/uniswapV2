pragma solidity >=0.4.24;

interface IStakingRewards {
    // Views
    // 有奖励的最近时间
    function lastTimeRewardApplicable() external view returns (uint256);

    // 没党委token的奖励数量
    function rewardPerToken() external view returns (uint256);

    // 用户已经转但是未提取的代币
    function earned(address account) external view returns (uint256);

    //  挖矿奖励总量
    function getRewardForDuration() external view returns (uint256);

    // 总质押量
    function totalSupply() external view returns (uint256);

    // 用户的质押
    function balanceOf(address account) external view returns (uint256);

    // Mutative
    // 充值
    function stake(uint256 amount) external;

    // 提现 > 接触质押
    function withdraw(uint256 amount) external;

    // 充值
    function getReward() external;

    // 推出
    function exit() external;
}
