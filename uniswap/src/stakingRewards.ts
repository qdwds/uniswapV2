import {  deployStakingRewards } from "../scripts/liquidity/liquidity";
import { connectNetwork, createContracts } from "../utils/contracts/createContract";
import { addLiquidity } from "./addLiquidity";
import address from "../abi/uniswapV2.json";
import { Contract, Wallet } from "ethers";
import uniInfo from "../abi/Uni.json";
import { ethers } from "hardhat";
import { parseUnits } from "ethers/lib/utils";

let account:String;
// 获取pair合约
const deployPair = async (signer:Wallet,factory:Contract, token0:Contract, token1:Contract) => {
    const pairAddress = await factory.getPair(token0.address, token1.address);
    const pair = await ethers.getContractAt("UniswapV2Pair", pairAddress, signer);
    console.log(pair.address);
    return pair;
}

const deploy = async (signer:Wallet,factory:Contract, token0:Contract, token1:Contract) => {
    const pair = await deployPair(signer,factory,token0, token1);
    const stakingRewards = await deployStakingRewards(signer.address, address.uni, pair.address);
    console.log("stakingRewards", stakingRewards.address)
    return{
        pair,
        stakingRewards
    }
}

// 存入奖励
const start = async () => {
    const { signer } = await connectNetwork();
    account = signer.address;
    const { token0, token1, uni, factory} = await createContracts(signer);
    const { stakingRewards, pair } = await deploy(signer, factory, token0, token1);
    // 质押奖励代币到合约中
    await stakingRewards.stake(parseUnits("100"))


    // 存入奖励token
    await uni.transfer(pair.address, parseUnits("1000"));
    await pair.approve(stakingRewards.address, parseUnits("1000"))
    // 设置奖励
    await stakingRewards.notifyRewardAmount(parseUnits("100"));

    // 开始结束时间
    const startTime = await stakingRewards.lastUpdateTime();
    const endTime = await stakingRewards.periodFinish();
    console.log(startTime, endTime)
    // 开始挖矿

    
    // 设置奖励
    // const start = await stakingRewards.notifyRewardAmount(parseUnits("100"));
    // const transaction  = await start.wait()

   
}

// 质押 LPToken
const mining = async (pair:Contract, stakingRewards:Contract) => {
    console.log(pair.safeTransferFrom)
    const balance = await pair.balanceOf(account);
    console.log(balance);
    // await stakingRewards.stake(balance,{gasLimit:10000000}).catch((err:any) => {console.log(err)})
}

// 获取自己的奖励额度
const getReword = async () => {

}

const main = async () => {
    // const { signer } = await connectNetwork();
    // const { token0, token1, uni, factory} = await createContracts(signer);
    // const { pair, stakingRewards } = await deploy(signer, factory, token0, token1);


    // // 存入奖励token
    // await uni.transfer(stakingRewards.address, parseUnits("1000"));


    // const start = await stakingRewards.notifyRewardAmount(parseUnits("100"));
    // const transaction  = await start.wait()
    // console.log(transaction)
    await start();

}

main()
    .catch(err => {
        console.log(err);
        process.exit(1);
    })