import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { execArgv } from "process";
import IUniswapV2Pair from "../../abi/IUniswapV2Pair.json";
export const deploy = async () => {
    const [owner] = await ethers.getSigners();
    // factory
    const Factory = await ethers.getContractFactory("UniswapV2Factory");
    const factory = await Factory.deploy(owner.address);
    // const factory = await ethers.getContractAt("UniswapV2Factory", uni.UniswapV2Factory, owner);
    // console.log(factory)

   
  
    // weth
    const WETH9 = await ethers.getContractFactory("WETH9");
    const weth = await WETH9.deploy();

    // router
    const Router = await ethers.getContractFactory("UniswapV2Router02");
    const router = await Router.deploy(factory.address, weth.address);

    // 10000
    const Token0 = await ethers.getContractFactory("Token0");
    const token0 = await Token0.deploy();

    // 100000000
    const Token1 = await ethers.getContractFactory("Token1");
    const token1 = await Token1.deploy();

     // pair
    await factory.createPair(token0.address, token1.address);
    const pairAddress = await factory.getPair(token0.address, token1.address);
    const pair = new ethers.Contract(pairAddress ,JSON.stringify(IUniswapV2Pair.abi), owner);

    // WEtHPair
    // console.log("weth.address", weth.address);
    // console.log("token0.address", token0.address);
    await factory.createPair(weth.address, token0.address)
    const WETHPairAddress = await factory.getPair(weth.address, token0.address);
    // console.log("WETHPairAddress", WETHPairAddress);
    const WETHPair = new ethers.Contract(WETHPairAddress, JSON.stringify(IUniswapV2Pair.abi), owner);
    // console.log("WETHPair", WETHPair.address);

    
    return {
        owner,
        factory: factory,
        router: router,
        token0: token0,
        token1: token1,
        pair: pair,
        weth: weth,
        WETHPair: WETHPair,
    }
}

export const bigNum = (v:number):BigNumber => {
    return BigNumber.from(v);
}

export const minutes = (m:number):number => {
    return new Date().setMinutes(new Date().getMinutes() + m);
}

export const id = (code:string):string => {
    return ethers.utils.id(code);
}

export const overrides = { gasLimit: 30000000 };
export const maxUint = ethers.constants.MaxUint256;
export const dead = ethers.constants.AddressZero;