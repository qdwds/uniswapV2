import { Contract } from "ethers";
import { ethers } from "hardhat"
import { createContractInfo } from "../../utils/files/contractInfo";

export const deployStakingRewardsFactory = async (rewardsToken:string,stakingRewardsGenesis:number ):Promise<Contract> => {
    const StakingRewardsFactory  = await ethers.getContractFactory("StakingRewardsFactory");
    const stakingRewardsFactory  = await StakingRewardsFactory.deploy(rewardsToken, stakingRewardsGenesis);
    await createContractInfo(stakingRewardsFactory.address, "StakingRewardsFactory");
    return stakingRewardsFactory
}

export const deployStakingRewards = async (rewardsDistribution:string,rewardsToken:string,stakingToken:string):Promise<Contract> => {
    const StakingRewards = await ethers.getContractFactory("StakingRewards");
    const stakingRewards = await StakingRewards.deploy(rewardsDistribution, rewardsToken, stakingToken);
    await createContractInfo(stakingRewards.address, "StakingRewards");
    return stakingRewards
}