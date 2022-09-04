
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
import { overrides } from "../utils/gas";
import { isArray } from "../utils/isType";
// 精准 == 输入
// 精准token0 => token1
const swapExactTokensForTokens = async (signer:any, router2:any,factory:any,tokens:Array<Contract>,amount:string) => {
    if(tokens.length < 2)return console.log("tokens length min 2 !");
    
    const amountIn:BigNumber = parseUnits(amount);
    const path:Array<string> = [];
    const tokenA:Contract = tokens[0];
    const tokenB:Contract = tokens[tokens.length - 1];
    let amountOut:BigNumber;
    const slip:number = 10;    //  滑点
    let befTokenA:BigNumber;
    let befTokenB:BigNumber;
    let pair:Contract;
    let amountOutList:Array<BigNumber>
    // if(tokens.length == 2){
    //     pair = factory.getPair(tokens[0].address, tokens[1].address);
    //     befTokenA = await tokenA.balanceOf(pair);
    //     befTokenB = await tokenB.balanceOf(pair);
    //     path.push(tokenA.address);
    //     path.push(tokenB.address);
    //     await tokenA.approve(router2.address, ethers.constants.MaxUint256);
    //     amountOut = await router2.getAmountOut(amountIn, befTokenA, befTokenB);
    // }else{
        for (let i = 0; i < tokens.length; i++) {
            path.push(tokens[i].address);
        }
        await tokenA.approve(router2.address, ethers.constants.MaxUint256);
        amountOutList = await router2.getAmountsOut(amountIn, path);
        amountOut = amountOutList[amountOutList.length - 1];

        console.log(amountOutList);
    // }
    
    //  根据滑点计算最小输出量
    const amountSlipMinOut = amountOut.mul(100 - slip).div(100);

    const tx = await router2.swapExactTokensForTokens(
        amountIn,
        amountSlipMinOut,  //  计算滑点后的值
        path,
        signer.address,
        Date.now() + 1000 * 60 * 10
    );
    await tx.wait();
    if(tokens.length == 2){
        const tokenAname = await tokenA.name();
        const tokenBname = await tokenB.name();
        const aftTokenA = await tokenA.balanceOf(pair!);
        const aftTokenB = await tokenB.balanceOf(pair!);
        const log:ILog = {
            method:"swapExactTokensForTokens",
            name:`${tokenAname}->${tokenBname}`,
            tokenA:tokenA.address,
            tokenB: tokenB.address,
            befTokenA: formatUnits(befTokenA!),
            aftTokenA: formatUnits(befTokenB!),
            tokenADiff: formatUnits(aftTokenA.sub(befTokenA!)),
            befTokenB: formatUnits(befTokenB!),
            aftTokenB: formatUnits(aftTokenB),
            tokenBDiff: formatUnits(aftTokenB.sub(befTokenB!)),
            slip: slip,
            minAmountOut: formatUnits(amountSlipMinOut),
            input1: formatUnits(amountIn),
            input2: formatUnits(befTokenA!.sub(befTokenA!))
        }
        console.log(log)
        createLogs(log);
    }else{
        const name = [];
        for (let i = 0; i < tokens.length; i++) {
            name.push(await tokens[i].name())
            
        }
        const log:ILog = {
            method:"swapExactTokensForTokens",
            name,
            slip:slip,
            paths:path,
            amountIn:formatUnits(amountIn),
            amountOut:formatUnits(amountOut),
            amountOutList:amountOutList!
        }
        console.log(log);
        
    }
}

// tokenA => 精准token1
const swapTokensForExactTokens = async (signer:any, router2:any,factory:any,tokens:Array<Contract>,amount:string) => {
 
    if(tokens.length < 2)return console.log("tokens length min 2 !");
    
    const amountOut:BigNumber = parseUnits(amount);
    const path:Array<string> = [];
    const tokenA:Contract = tokens[0];
    const tokenB:Contract = tokens[tokens.length - 1];
    let amountIn:BigNumber;
    const slip:number = 10;    //  滑点
    let befTokenA:BigNumber;
    let befTokenB:BigNumber;
    let pair:Contract;
    let amountOutList:Array<BigNumber>
    // if(tokens.length == 2){
    //     pair = factory.getPair(tokens[0].address, tokens[1].address);
    //     befTokenA = await tokenA.balanceOf(pair);
    //     befTokenB = await tokenB.balanceOf(pair);
    //     path.push(tokenA.address);
    //     path.push(tokenB.address);
    //     await tokenA.approve(router2.address, ethers.constants.MaxUint256);
    //     amountIn = await router2.getAmountOut(amountOut, befTokenA, befTokenB);
    // }else{
        for (let i = 0; i < tokens.length; i++) {
            path.push(tokens[i].address);
        }
        await tokenA.approve(router2.address, ethers.constants.MaxUint256);
        amountOutList = await router2.getAmountsOut(amountOut, path);
        amountIn = amountOutList[amountOutList.length - 1];
    // }
    const amountMaxIn = amountIn.mul(100 + slip).div(100);

    const tx = await router2.swapTokensForExactTokens(
        amountOut,
        amountMaxIn,
        path,
        signer.address,
        Date.now() + 1000 * 60 * 10,
        overrides
    )
    await tx.wait();

    
    // // save swap info
    // const [ aftTokenA, aftToken1, ] = await getPair(factory, signer, tokenA.address, token1.address);
    // const tokenAname = await tokenA.name();
    // const token1name = await token1.name();
    // const log:ILog = {
    //     method:"swapTokensForExactTokens",
    //     name:`${token1name}->${tokenAname}`,
    //     tokenA:tokenA.address,
    //     token1: token1.address,
    //     befTokenA: befTokenA,
    //     aftTokenA: aftTokenA,
    //     tokenADiff: JSON.stringify(Number(aftTokenA) - Number(befTokenA)),
    //     befToken1: befToken1,
    //     aftToken1: aftToken1,
    //     token1Diff: JSON.stringify(Number(aftToken1) - Number(befToken1)),
    //     slip: slip,
    //     maxAmountIn: formatUnits(amountMaxIn),
    //     input1: JSON.stringify(Number(aftTokenA) - Number(befTokenA)),
    //     input2: formatUnits(amountOut),
    // }
    // console.log(log)
    // createLogs(log);
}

// //  精准ETH => token  WTH为输入框1
// const swapExactETHForTokens = async() => {
//     const { signer } = connectNetwork();
//     const { token1, router2, factory, weth } = await createContracts(signer);

    
//     await weth.approve(router2.address, ethers.constants.MaxUint256);
//     // 这里为了省事，应该在当前地址中查查pair 会准备 参考 swapExactTokensForETH
//     const [ befWETH, befToken, ] = await getPair(factory, signer, weth.address, token1.address);
    
//     const amountWETHIn = parseEther("0.001");
    
//     //  计算能得到多少token
//     const amountOut = await router2.getAmountOut(amountWETHIn, parseUnits(befWETH), parseUnits(befToken));
//     const slip = 10;
//     const amountSlipOutMin = amountOut.mul(100 - slip).div(100);

//     const path = [weth.address, token1.address];
//     const tx = await router2.swapExactETHForTokens(
//         amountSlipOutMin,
//         path,
//         signer.address,
//         Date.now() + 1000 * 60 * 10,
//         {
//             value: amountWETHIn
//         }
//     )
//     await tx.wait();

//     // save tranaction info
//     const [ aftToken0, aftToken1 ] = await getPair(factory, signer, weth.address, token1.address);
//     const [ aftWETH, aftToken ] = weth.address < token1.address ? [aftToken0, aftToken1] :[aftToken1, aftToken0]
//     const token1name = await token1.name();
//     const log:ILog = {
//         method:"swapExactETHForTokens",
//         name:`WETH->${token1name}`,
//         token0:weth.address,
//         token1: token1.address,
//         befETH: befWETH,
//         aftETH: aftWETH,
//         ETHDiff: JSON.stringify(Number(aftWETH) - Number(befWETH)),
//         befToken1: befToken,
//         aftToken1: aftToken,
//         token1Diff: JSON.stringify(Number(aftToken) - Number(befToken)),
//         slip: slip,
//         minAmountOut: formatUnits(amountSlipOutMin),
//         input1: formatUnits(amountWETHIn),
//         input2: JSON.stringify(Number(aftToken) - Number(befToken))
//     }
//     console.log(log);
//     createLogs(log);
// }

// //  ETH => 精准token  WTH为输入框1
// const swapETHForExactTokens = async() => {
//     const { signer } = connectNetwork();
//     const { token1, router2, factory, weth } = await createContracts(signer);

//     await weth.approve(router2.address, ethers.constants.MaxUint256);
//     // 这里为了省事，应该在当前地址中查查pair 会准备 参考 swapExactTokensForETH
//     const [ befToken0, befToken1, ] = await getPair(factory, signer, weth.address, token1.address);
//     const [ befWETH, befToken ] = weth.address < token1.address ? [befToken0, befToken1] :[befToken1, befToken0]
    
//     const amountOut = ethers.utils.parseUnits("5");
//     const path = [weth.address, token1.address];

//     const slip = 10;
    
//     const amountInETH = await router2.getAmountIn(amountOut, parseEther(befWETH), parseUnits(befToken))

//     const tx = await router2.swapETHForExactTokens(
//         amountOut,
//         path,
//         signer.address,
//         Date.now() + 1000 * 60 * 10,
//         {
//             value: amountInETH,
//             ...overrides
//         }
//     )
//     await tx.wait();

//     // save tranaction info
//     const [ aftToken0, aftToken1 ] = await getPair(factory, signer, weth.address, token1.address);
//     const [ aftWETH, aftToken ] = weth.address < token1.address ? [aftToken0, aftToken1] :[aftToken1, aftToken0]
//     const token1name = await token1.name();
//     const log:ILog = {
//         method:"swapETHForExactTokens",
//         name:`WETH->${token1name}`,
//         token0:weth.address,
//         token1: token1.address,
//         befETH: befWETH,
//         aftETH: aftWETH,
//         ETHDiff: JSON.stringify(Number(aftWETH) - Number(befWETH)),
//         befToken1: befToken,
//         aftToken1: aftToken,
//         token1Diff: JSON.stringify(Number(aftToken) - Number(befToken)),
//         slip: slip,
//         minAmountOut: formatUnits(amountInETH),
//         input1: formatUnits(amountInETH),
//         input2: JSON.stringify(Number(befToken) - Number(aftToken))
//     }
//     createLogs(log);
//     console.log(log);
// }

// //  精准token => ETH  token为输入框1
// const swapExactTokensForETH = async() => {
//     const { signer } = connectNetwork();
//     const { token1, router2, factory, weth } = await createContracts(signer);

//     await token1.approve(router2.address, ethers.constants.MaxUint256);
//     const slip = 10;
    
//     // 获取储备量 
//     const pairAdd = await factory.getPair(weth.address, token1.address);
//     const befToken  = await token1.balanceOf(pairAdd);
//     const befETH  = await weth.balanceOf(pairAdd);

//     // 计算输入
//     const amountIn = parseUnits("10");
   
//     const amountOut = await router2.getAmountOut(amountIn, befToken, befETH);
//     const amountOutMin = amountOut.mul(100 - slip).div(100);
    
//     const path = [token1.address, weth.address];
//     const tx = await router2.swapExactTokensForETH(
//         amountIn,
//         amountOutMin,   //  最少输出的ETH数量
//         path,
//         signer.address,
//         Date.now() + 1000 * 60 * 10,
//     )
//     await tx.wait();
    
//     const aftToken  = await token1.balanceOf(pairAdd);
//     const aftETH  = await weth.balanceOf(pairAdd);
//     const token1name = await token1.name();
//     // token0 = weth  token1 = token1
//     const log:ILog = {
//         method:"swapExactTokensForETH",
//         name:`${token1name}->ETH`,
//         token0:weth.address,
//         token1: token1.address,
//         // token1
//         befToken1: formatUnits(befToken),
//         aftToken1: formatUnits(aftToken),
//         token1Diff: formatEther(aftToken.sub(befToken)),
//         // eth
//         befToken0: formatEther(befETH),
//         aftToken0: formatEther(aftETH),
//         token0Diff: formatEther(aftETH.sub(befETH)),
//         slip: slip,
//         amountOutMin: formatUnits(amountOutMin),
//         input1: formatUnits(amountIn),
//         input2: formatEther(befETH.sub(aftETH))
        
//     }
//     console.log(log)
//     createLogs(log);
 
// }

// //  token => 精准ETH  token为输入框1
// const swapTokensForExactETH = async() => {
//     const { signer } = connectNetwork();
//     const { token1, router2, factory, weth } = await createContracts(signer);

//     await token1.approve(router2.address, ethers.constants.MaxUint256);
//     const slip = 10;
//     // 获取储备量 
//     const pairAdd = await factory.getPair(weth.address, token1.address);
//     const befToken  = await token1.balanceOf(pairAdd);
//     const befETH  = await weth.balanceOf(pairAdd);

//     const amountOut = parseEther("0.01");

//     const amountInMax = await router2.getAmountIn(amountOut, befToken, befETH);
//     // const amountInMax = amountIn.mul(100 - slip).div(100);
//     const path = [token1.address, weth.address];
//     const tx = await router2.swapTokensForExactETH(
//         amountOut,
//         amountInMax,
//         path,
//         signer.address,
//         Date.now() + 1000 * 60 * 10
//     )
//     await tx.wait();

//     //  save tranaction info
//     const aftToken  = await token1.balanceOf(pairAdd);
//     const aftETH  = await weth.balanceOf(pairAdd);
//     const token1name = await token1.name();
//     // token0 = weth  token1 = token1
//     const log:ILog = {
//         method:"swapTokensForExactETH",
//         name:`${token1name}->ETH`,
//         token0:weth.address,
//         token1: token1.address,
//         // token1
//         befToken1: formatUnits(befToken),
//         aftToken1: formatUnits(aftToken),
//         token1Diff: formatEther(aftToken.sub(befToken)),
//         // eth
//         befToken0: formatEther(befETH),
//         aftToken0: formatEther(aftETH),
//         token0Diff: formatEther(aftETH.sub(befETH)),
//         slip: slip,
//         amountInMax: formatUnits(amountInMax),
//         input1: formatUnits(amountInMax),
//         input2: formatEther(amountOut)
        
//     }
//     console.log(log)
//     // createLogs(log);
// }


// 
const getPair = async (factory:Contract, signer:Wallet, token0:string, token1:string):Promise<Array<string>> => {
    const pair_addr: string = await factory.getPair(token0, token1);
    const pair: Contract = new ethers.Contract(pair_addr,["function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast)","function totalSupply() external view returns (uint)"], signer);
    let [ reserve0, reserve1, ] = await pair.getReserves();
    // const [reserve00, reserve11] = token0 < token1 ? [reserve0, reserve1] : [reserve1,reserve0 ]
    const totalSupply: BigNumber = await pair.totalSupply();
    return [formatUnits(reserve0), formatUnits(reserve1), formatUnits(totalSupply)]
}

const sortTokens = (t0:Contract,t1:Contract):Array<Contract> => {
    return  t0.address < t1.address ? [t0,t1]:[t1,t0];
}

const main = async () => {
    const { signer } = connectNetwork();
    const { token0, token1, token2, router2, factory, weth } = await createContracts(signer);
    await swapExactTokensForTokens(signer, router2, factory, [token0, token1], "10");
    await swapExactTokensForTokens(signer, router2, factory, [token0, token1, token2], "10");
    
    // await swapTokensForExactTokens(signer, router2, factory, [token2, token1], "10");
    // await swapTokensForExactTokens(signer, router2, factory, [token1, token0], "48");
    // await swapTokensForExactTokens(signer, router2, factory, [token2, token1, token0], "10");
    // await swapExactETHForTokens();
    // await swapETHForExactTokens();
    // await swapExactTokensForETH();
    // await swapTokensForExactETH();
}

main().catch(_=>{console.log(_);
})