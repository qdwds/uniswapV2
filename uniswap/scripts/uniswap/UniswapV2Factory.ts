import { ethers } from "hardhat"
import { createContractInfo } from "../../utils/files/contractInfo";
const FACTORY_NAME = "UniswapV2Factory";


export const uniswapV2Factory = async(deploy: string)=>{
    const UniswapV2Factory = await ethers.getContractFactory(FACTORY_NAME);
    const uniswapV2Factory = await UniswapV2Factory.deploy(deploy);
    await uniswapV2Factory.deployed();
    await createContractInfo(uniswapV2Factory.address, FACTORY_NAME);
    return uniswapV2Factory;
}