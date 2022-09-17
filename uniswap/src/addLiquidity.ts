import { formatUnits, parseEther, parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat"
import uniswapV2 from "../abi/uniswapV2.json";
import { createPairs, IPair } from "../utils/files/pairs";
import { connectNetwork, createContracts } from "../utils/contracts/createContract";
import type { Contract, Signer, Wallet } from "ethers";

//  token|token
export const addLiquidity = async(factory:any, router2:any ,signer:Wallet, tokenA:Contract, tokenB:Contract, amountA:string, amountB:string) => {
    
    // pair is Dead 
    const isDead = (await factory.getPair(tokenA.address, tokenB.address)) == ethers.constants.AddressZero;
    
    // approve
    await tokenA.approve(router2.address, ethers.constants.MaxUint256);
    await tokenB.approve(router2.address, ethers.constants.MaxUint256);
    const tokenAAmount = parseUnits(amountA);
    const tokenBAmount = parseUnits(amountB);

    // addLiquidity
    const add_tx = await router2.addLiquidity(
        tokenA.address,
        tokenB.address,
        tokenAAmount,
        tokenBAmount,
        0,
        0,
        signer.address,
        Date.now() + 1000 * 60 * 10
    )
    await add_tx.wait();

    //  create tokenA tokenB pair info
    const tokenPair = await factory.getPair(tokenA.address, tokenB.address);
    const pair = await ethers.getContractAt("UniswapV2Pair", tokenPair, signer);
    const tokenAname = await tokenA.name();
    const tokenBname = await tokenB.name();
 

    const reserveA = await tokenA.balanceOf(pair.address);
    const reserveB = await tokenB.balanceOf(pair.address);
    const totalSupply = await pair.totalSupply();

    // pari info
    const pairInfo: IPair = {
        type:"token|token",
        pair: pair.address,
        tokenA: tokenA.address,
        tokenAName: tokenAname,
        reserveA: formatUnits(reserveA),
        tokenB: tokenB.address,
        tokenBName: tokenBname,
        reserveB: formatUnits(reserveB),
        totalSupply: formatUnits(totalSupply),
        updateTime: new Date(),
        tokenAAmount:formatUnits(tokenAAmount),
        tokenBAmount:formatUnits(tokenBAmount),
        fee:1
    }
    if(isDead) pairInfo.createTime = new Date();
    // save paris info
    await createPairs(pairInfo);
    console.log(pairInfo);
    console.log("addLiquidity success ok !");
}

// WETH|token
const addLiquidityETH = async(factory:any, router2:any ,signer:Wallet, token:Contract, amountWETH:string, amountToken:string)=>{
    // const { signer } = connectNetwork();
    // const { token1, router2, factory} = await createContracts(signer);
    //  pair exists
    const isDead = (await factory.getPair(uniswapV2.WETH9, token.address)) == ethers.constants.AddressZero;
    
    await token.approve(router2.address, ethers.constants.MaxUint256);
    const tokenAmount = parseUnits(amountToken);
    const ethAmount = parseEther(amountWETH);

    const tx = await router2.addLiquidityETH(
        token.address,
        tokenAmount,
        0,
        0,
        signer.address,
        Date.now() + 1000 * 60 * 10,
        {
            gasLimit: 5000000,
            value: ethAmount
        }
    )
    await tx.wait();
    const token1name = await token.name();
    const tokenPair = await factory.getPair(uniswapV2.WETH9, token.address);
    const pair = await ethers.getContractAt("UniswapV2Pair", tokenPair, signer); 
    const [ reserve0, reserve1, updateTime ] = await pair.getReserves();
    const totalSupply = await pair.totalSupply();
    // pari info
    const pairInfo: IPair = {
        type:"weth|token",
        pair: pair.address,
        tokenA: uniswapV2.WETH9,
        tokenB: token.address,
        tokenAName: "WETH9",
        tokenBName: token1name,
        reserveA: reserve0.toString(),
        reserveB: reserve1.toString(),
        totalSupply: totalSupply.toString(),
        updateTime: new Date(updateTime * 1000),
        tokenAAmount:formatUnits(tokenAmount),
        ethAmount:formatUnits(ethAmount),
        fee:1
    }
    if(isDead)  pairInfo.createTime = new Date();
    console.log(pairInfo);
    // save paris info
    await createPairs(pairInfo);
    console.log("addLiquidityETH success ok!");
    
}

const main = async() => {
    const { signer } = connectNetwork();
    const { token0, token1, token2, token3,router2, factory} = await createContracts(signer);
    await addLiquidity(factory, router2 ,signer, token0, token1, "10", "100");
    await addLiquidity(factory, router2 ,signer, token1, token2, "100", "1000");
    await addLiquidity(factory, router2 ,signer, token2, token3, "1000", "10000");
    
    await addLiquidityETH(factory, router2 ,signer, token3, "10", "1000000");
}


main()
.catch((err:any)=>{
    console.log(err);
    process.exit(1);
})

