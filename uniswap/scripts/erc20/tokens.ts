import { Contract } from "ethers";
import { ethers } from "hardhat"
import { createContractInfo } from "../../utils/files/contractInfo";

export const token0 = async ():Promise<Contract> => {
    const TOKEN_NAME = "Token0";
    const Token = await ethers.getContractFactory(TOKEN_NAME);
    const token = await Token.deploy();
    await token.deployed();
    createContractInfo(token.address, TOKEN_NAME);
    return token;
}

export const token1 = async ():Promise<Contract> => {
    const TOKEN_NAME = "Token1"
    const Token = await ethers.getContractFactory(TOKEN_NAME);
    const token = await Token.deploy();
    await token.deployed();
    createContractInfo(token.address, TOKEN_NAME);
    return token;
}
export const token2 = async ():Promise<Contract> => {
    const TOKEN_NAME = "Token2"
    const Token = await ethers.getContractFactory(TOKEN_NAME);
    const token = await Token.deploy();
    await token.deployed();
    createContractInfo(token.address, TOKEN_NAME);
    return token;
}
export const token3 = async ():Promise<Contract> => {
    const TOKEN_NAME = "Token3"
    const Token = await ethers.getContractFactory(TOKEN_NAME);
    const token = await Token.deploy();
    await token.deployed();
    createContractInfo(token.address, TOKEN_NAME);
    return token;
}


const token = [
    {
        name:"USDT",
        symbol:"usdt",
        amount: 10000
    },
    {
        name:"BUSD",
        symbol:"bsdt",
        amount: 10000
    },
    {
        name:"DAI",
        symbol:"dai",
        amount: 1000000
    }
]
export const tokens = async():Promise<Array<Contract>> => {
    const contracts:Array<Contract> = [];
    for (const t of token) {
        const Token = await ethers.getContractFactory("Token");
        const token = await Token.deploy(t.symbol, t.name, t.amount);
        await token.deployed();
        await createContractInfo(token.address, t.symbol);
        contracts.push(token);
    }
    return contracts;
}