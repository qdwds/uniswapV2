import { ethers } from "hardhat";
import { createContractInfo } from "../../utils/files/contractInfo";

const WETH_NAME = "WETH9";
export const WETH9 = async () => {
    const WETH = await ethers.getContractFactory(WETH_NAME);
    const weth = await WETH.deploy();
    await weth.deployed();
    await createContractInfo(weth.address, WETH_NAME);
    return weth;
}