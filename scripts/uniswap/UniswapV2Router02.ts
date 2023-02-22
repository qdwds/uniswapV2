import { ethers } from "hardhat";
import { createContractInfo } from "../../utils/files/contractInfo";

const ROUTER2_NAME = "UniswapV2Router02";
export const uniswapV2Router02 = async (factory:string, weth:string) => {
    const UniswapV2Router02 = await ethers.getContractFactory(ROUTER2_NAME);
    const uniswapV2Router02 = await UniswapV2Router02.deploy(factory, weth);
    await uniswapV2Router02.deployed();
    await createContractInfo(uniswapV2Router02.address, ROUTER2_NAME);
    return uniswapV2Router02;
}