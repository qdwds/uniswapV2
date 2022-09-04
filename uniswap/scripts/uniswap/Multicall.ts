import { ethers } from "hardhat";
import { createContractInfo } from "../../utils/files/contractInfo";

const Multicall_NAME = "Multicall";
export const multicall = async () => {
    const Multicall = await ethers.getContractFactory(Multicall_NAME);
    const multicall = await Multicall.deploy();
    await multicall.deployed();
    await createContractInfo(multicall.address, Multicall_NAME);
    return multicall;
}