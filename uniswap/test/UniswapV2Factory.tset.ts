// import type { Contract, ContractFactory, Signer } from "ethers"
// import { ethers } from "hardhat";
// import { constants } from 'ethers'
// import { FactoryOptions } from "hardhat/types";
// import uni from "../abi/UniswapV2Factory.json";
// import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
// import { Token } from "../typechain-types";
// import { expect } from "chai";
// import { parseUnits } from "ethers/lib/utils";
// describe("UniswapV2Pair", ()=> {
//     const MINIMUM_LIQUIDITY = "1000";
//     const DEAD = constants.AddressZero;
    
//     // 预计使用的gas
//     const overrides = {
//         gasLimit: 9999999
//     }
//     const deployContract = async () => {
//         const [ owner, account ] = await ethers.getSigners();
//         const Factry = await ethers.getContractFactory("UniswapV2Factory");
//         const factry = await Factry.deploy(owner.address);
        
//         const Pair = await ethers.getContractFactory("UniswapV2Pair");
//         const pair = await Pair.deploy();

//         // 10000
//         const Token0 = await ethers.getContractFactory("Token0");
//         const token0 = await Token0.deploy();
//         // 100000000
//         const Token1 = await ethers.getContractFactory("Token1");
//         const token1 = await Token1.deploy();
//         return {
//             factry,
//             pair,
//             token0,
//             token1,
//             owner: owner.address,
//             account
//         }
//     }

    

//     it("mint",async ()=>{

//         const { token0, token1 ,pair ,owner} = await loadFixture(deployContract);
//         // 转账到pair合约中
//         await token0.transfer(pair.address, await parseUnits("1000", 18));
//         await token1.transfer(pair.address, await parseUnits("100000", 18));
        
//         // 要添加的流动性额度
//         const amount0 = ethers.BigNumber.from(parseUnits("100", 18));
//         const amount1 = ethers.BigNumber.from(parseUnits("10000", 18));
//         const total = ethers.BigNumber.from(parseUnits("100", 18));

//        // 执行方法
//         // await expect(pair.mint(owner, overrides))
//         //     .to.emit(pair, "Transfer")
//             // .withArgs(DEAD, DEAD, MINIMUM_LIQUIDITY)
//             // .to.emit(pair, "Transfer").withArgs(DEAD, owner, total.sub(MINIMUM_LIQUIDITY))
//             // .to.emit(pair, "Sync").withArgs(amount0, amount1)
//             // .to.emit(pair, "Mint").withArgs(owner, amount0, amount1)

//     })


// })