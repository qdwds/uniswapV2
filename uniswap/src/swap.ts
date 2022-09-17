
// token0 input1    token1 input2
// 注意：前面的需要提前授权，不管是输入框1输入还是输入框2输入，最总都是输入1内容的token兑换输入框2内的token
// 那个输入框输入 输入框就是精准的
// WMATIC:输入 => SHIB   swapExactTokensForTokens
// WMATIC => SHIB:输入   swapTokensForExactTokens
// MATIC:输入 => SHIB   swapExactETHForTokens
// MATIC => SHIB:输入   swapETHForExactTokens
// SHIB:输入 => MATIC   swapExactTokensForETH
// SHIB => MATIC:输入   swapTokensForExactETH

import { BigNumber, Contract, Wallet } from "ethers";
import { formatEther, formatUnits, parseEther, parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { connectNetwork, createContracts } from "../utils/contracts/createContract"
import { ILog, createLogs } from "../utils/files/logs";

// 精准 == 输入
// 精准token0 => token1
const swapExactTokensForTokens = async (signer: any, router2: any, factory: any, tokens: Array<Contract>, amount: string) => {
    if (tokens.length < 2) return console.log("token leng lt 2");
    const tokenA: Contract = tokens[0];
    const tokenB: Contract = tokens[tokens.length - 1];
    const path:Array<string> = [];
    const amountIn:BigNumber = parseUnits(amount);
    const slip:number = 10;
    const name:Array<string> = [];

    for (let i = 0; i < tokens.length; i++) {
       path.push(tokens[i].address);
       const n = await tokens[i].name();
       name.push(n)
    }

    await tokenA.approve(router2.address, ethers.constants.MaxUint256);
    
    // 计算最优价格
    const amountOutList:Array<BigNumber> = await router2.getAmountsOut(amountIn, path);
    const amountOut = amountOutList[amountOutList.length - 1];
    const amountOutMin = amountOut.mul(100 - slip).div(100);

    const tx = await router2.swapExactTokensForTokens(
        amountIn,
        amountOutMin,
        path,
        signer.address,
        Date.now() + 1000 * 60 * 10
    )
    await tx.wait();
    
    const log:ILog = {
        method:"swapExactTokensForTokens",
        slip,
        name,
        path,
        amountList:amountOutList,
        amountIn:formatUnits(amountIn),
        amountOutMin:formatUnits(amountOutMin),
    }
    console.log(log);
    await createLogs(log);
    
}

// tokenA => 精准token1
const swapTokensForExactTokens = async (signer: any, router2: any, factory: any, tokens: Array<Contract>, amount: string) => {
    if(tokens.length < 2) return console.log("token leng lt 2");
    const tokenA: Contract = tokens[0];
    const tokenB: Contract = tokens[tokens.length - 1];
    const path:Array<string> = [];
    const amountOut:BigNumber = parseUnits(amount);
    const slip:number = 10;
    const name:Array<string> = [];

    for (let i = 0; i < tokens.length; i++) {
        path.push(tokens[i].address);
        const n = await tokens[i].name();
        name.push(n);
    }

    await tokenA.approve(router2.address, ethers.constants.MaxUint256);

    // 计算最优价格
    const amountInList:Array<BigNumber> = await router2.getAmountsIn(amountOut, path);
    const amountIn = amountInList[0];
    const amountInMax = amountIn.mul(100 - (100 * slip)).div(10000);
    // const amountInMax = amountIn.mul(100 + slip).div(100);
    const tx = await router2.swapTokensForExactTokens(
        amountOut,
        amountInMax,
        path,
        signer.address,
        Date.now() + 1000 * 60 * 10
    )
    await tx.wait();
    
    const log:ILog = {
        method:"swapTokensForExactTokens",
        slip,
        name,
        path,
        amountList:amountInList,
        amountIn:formatUnits(amountInMax),
        amountOutMin:formatUnits(amountOut),
    }
    console.log(log);
    await createLogs(log);

}

//  精准ETH => token  WTH为输入框1
const swapExactETHForTokens = async (signer: any, router2: any, factory: any, weth:Contract, tokens: Array<Contract>, amount: string) => {
    if(tokens.length < 1) return console.log("最少需要输入个地址");
    const tokenA: Contract = tokens[0];
    const tokenB: Contract = tokens[tokens.length - 1];
    const path:Array<string> = [weth.address];  //  第一个地址必须是weth地址
    const amountIn:BigNumber = parseEther(amount);
    const slip:number = 10;
    const name:Array<string> = ["weth"];

    for (let i = 0; i < tokens.length; i++) {
        path.push(tokens[i].address);
        const n = await tokens[i].name();
        name.push(n);
    }
    
    await weth.approve(router2.address, ethers.constants.MaxUint256).catch((err:any)=>console.log(err))
    
    // 计算最优价格
    const amountOutList:Array<BigNumber> = await router2.getAmountsOut(amountIn, path);
    const amountOut = amountOutList[amountOutList.length - 1];
    const amountOutMin = amountOut.mul(100 - slip).div(100);

    const tx = await router2.swapExactETHForTokens( 
        amountOutMin,
        path,
        signer.address,
        Date.now() + 1000 * 10 * 60,
        {
            value: amountIn
        }
    )
    await tx.wait();

    const log:ILog = {
        method:"swapExactTokensForTokens",
        slip,
        name,
        path,
        amountList:amountOutList,
        amountIn:formatUnits(amountIn),
        amountOutMin:formatUnits(amountOutMin),
    }
    console.log(log);
    await createLogs(log);
}

//  ETH => 精准token  WTH为输入框1
const swapETHForExactTokens = async (signer: any, router2: any, factory: any, weth:Contract, tokens: Array<Contract>, amount: string) => {
    if(tokens.length < 1) return console.log("最少需要输入个地址");
    const tokenA: Contract = tokens[0];
    const tokenB: Contract = tokens[tokens.length - 1];
    const path:Array<string> = [weth.address];  //  第一个地址必须是weth地址
    const amountOut:BigNumber = parseUnits(amount);
    const slip:number = 10;
    const name:Array<string> = ["weth"];

    for (let i = 0; i < tokens.length; i++) {
        path.push(tokens[i].address);
        const n = await tokens[i].name();
        name.push(n);
    }

    await weth.approve(router2.address, ethers.constants.MaxUint256).catch((err:any)=>console.log(err))
    
    const amountInList:Array<BigNumber> = await router2.getAmountsIn(amountOut, path);
    const amountIn = amountInList[0];
    const amountInMax = amountIn.mul(100 - (100 * slip)).div(10000);
 
    const tx = await router2.swapETHForExactTokens(
        amountOut,
        path,
        signer.address,
        Date.now() + 1000 * 60 * 10,
        {
            value: amountInMax
        }
    )
    await tx.wait();

    const log:ILog = {
        method:"swapExactTokensForTokens",
        slip,
        name,
        path,
        amountList: amountInList,
        amountOut: formatUnits(amountOut),
        amountInMax: formatUnits(amountInMax),
    }
    console.log(log);
    await createLogs(log);

}

//  精准token => ETH  token为输入框1
const swapExactTokensForETH = async (signer: any, router2: any, factory: any, weth:Contract, tokens: Array<Contract>, amount: string) => {
    if(tokens.length < 1) return console.log("最少需要输入个地址");
    const tokenA: Contract = tokens[0];
    const tokenB: Contract = tokens[tokens.length - 1];
    const path:Array<string> = [];  //  第一个地址必须是weth地址
    const amountIn:BigNumber = parseUnits(amount);
    const slip:number = 10;
    const name:Array<string> = [];

    for (let i = 0; i < tokens.length; i++) {
        path.push(tokens[i].address);
        const n = await tokens[i].name();
        name.push(n);
    }
    path.push(weth.address);
    name.push("weth");    

    await tokenA.approve(router2.address, ethers.constants.MaxUint256);
    const amountOutList = await router2.getAmountsOut(amountIn, path);
    const amountOut = amountOutList[amountOutList.length - 1];
    const amountOutMin = amountOut.mul(100 - slip).div(100);

    const tx = await router2.swapExactTokensForETH(
        amountIn,
        amountOutMin,
        path,
        signer.address,
        Date.now() + 1000 * 60 * 10
    )
    await tx.wait();
    const log:ILog = {
        method:"swapExactTokensForETH",
        slip,
        name,
        path,
        amountList: amountOutList,
        amountIn: formatUnits(amountIn),
        amountOutMin: formatUnits(amountOutMin),
    }
    console.log(log);
    await createLogs(log);
}

//  token => 精准ETH  token为输入框1
const swapTokensForExactETH = async (signer: any, router2: any, factory: any, weth:Contract, tokens: Array<Contract>, amount: string) => {
    if(tokens.length < 1) return console.log("最少需要输入个地址");
    const tokenA: Contract = tokens[0];
    const tokenB: Contract = tokens[tokens.length - 1];
    const path:Array<string> = [];  //  第一个地址必须是weth地址
    const amountOut:BigNumber = parseUnits(amount);
    const slip:number = 10;
    const name:Array<string> = [];

    for (let i = 0; i < tokens.length; i++) {
        path.push(tokens[i].address);
        const n = await tokens[i].name();
        name.push(n);
    }
    path.push(weth.address);
    name.push("weth");   

    await tokenA.approve(router2.address, ethers.constants.MaxUint256);

    const amountInList = await router2.getAmountsIn(amountOut, path);
    const amountIn = amountInList[0];
    const amountInMax = amountIn.mul(100 - (100 * slip)).div(10000);

    const tx = await router2.swapTokensForExactETH(
        amountOut,
        amountInMax,
        path,
        signer.address,
        Date.now() + 1000 * 60 * 10
    )
    await tx.wait();
    const log:ILog = {
        method:"swapExactTokensForETH",
        slip,
        name,
        path,
        amountList: amountInList,
        amountOut: formatUnits(amountOut),
        amountInMax: formatUnits(amountInMax),
    }
    console.log(log);
    await createLogs(log);
}




const main = async () => {
    const { signer } = connectNetwork();
    const { token0, token1, token2, router2, factory, weth } = await createContracts(signer);
    // 注意：流动性 [weth <-> token0 <-> token1 <-> token2 <-> token3]


    await swapExactTokensForTokens(signer, router2, factory, [token0, token1], "10");
    await swapExactTokensForTokens(signer, router2, factory, [token0, token1, token2], "10");

    await swapTokensForExactTokens(signer, router2, factory, [token1, token0],"10");
    await swapTokensForExactTokens(signer, router2, factory, [token2, token1, token0],"10");
 
    await swapExactETHForTokens(signer, router2, factory, weth ,[token0],"0.1")
    await swapExactETHForTokens(signer, router2, factory, weth ,[token0, token1, token2],"0.1")

    await swapETHForExactTokens(signer, router2, factory, weth ,[token0], "0.001")
    await swapETHForExactTokens(signer, router2, factory, weth ,[token0, token1, token2],"0.02")

    await swapExactTokensForETH(signer, router2, factory, weth ,[token0],"10");
    await swapExactTokensForETH(signer, router2, factory, weth ,[token2, token1, token0],"100");

    await swapTokensForExactETH(signer, router2, factory, weth ,[token0],"0.01");
    await swapTokensForExactETH(signer, router2, factory, weth ,[token2, token1, token0],"0.00001");
}

main().catch(_ => {
    console.log(_);
})