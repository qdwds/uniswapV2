import { BigNumber, ethers } from "ethers";
import { formatUnits, parseUnits } from "ethers/lib/utils";
import { stringify } from "querystring";
import { createContract } from "./useContracts";
import { ElMessage } from "element-plus";



export const addLiquidity = async (
    token1: string,
    token2: string,
    token1Amount: BigNumber,
    token2Amount: BigNumber,
    amount1Min: BigNumber,
    amount2Min: BigNumber,
    to: string,
    deadline: number
): Promise<boolean> => {
    try {
        const { router2 } = await createContract();
        const tx = await router2.addLiquidity(
            token1,
            token2,
            token1Amount,
            token2Amount,
            amount1Min,
            amount2Min,
            to,
            deadline
        )
        await tx.wait();
        return true
    } catch (error) {
        console.error(error);
        return false;
    }
}

export const addLiquidityETH = async (
    token: string,
    amountTokenDesired: BigNumber,
    amountTokenMin: BigNumber,
    amountETHMin: BigNumber,
    to: string,
    deadline: number,
    eth: BigNumber,  //  eth 数量
): Promise<boolean> => {

    try {
        const { router2 } = await createContract();
        const tx = await router2.addLiquidityETH(
            token,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            to,
            deadline,
            {
                gasLimit: 5000000,
                value: eth
            }
        ).catch((err: any) => console.log(err))
        await tx.wait();
        return true;
    } catch (error) {
        return false;
    }
}

export const removeLiquidity = async (
    tokenA: string,
    tokenB: string,
    liquidity: BigNumber,
    amountAMin: BigNumber,
    amountBMin: BigNumber,
    to: string,
    deadline: number,
) => {
    try {
        const { router2 } = await createContract();
        const tx = await router2.removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        )
        console.log(tx);
        
        await tx.wait();
        return true;
    } catch (error) {
        console.log(error);
        return false
    }
}


export const removeLiquidityETH = async (
    tokenA:string,
    liquidity:BigNumber,
    amountTokenMin:BigNumber,
    amountETHMin:BigNumber,
    to:string,
    deadline:number
):Promise<boolean>=>{
    try {
        const { router2 } = await createContract();
        const tx = await router2.removeLiquidityETH(
            tokenA,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline,
        )
        await tx.wait();
        return true;
    } catch (error) {
        return false;
    }
}
// 输入求输出
export const getAmountsOut = async (
    amountIn:BigNumber,
    path:Array<string>
):Promise<BigNumber> => {

    try {
        const { router2 } = await createContract();
        const amountOut:Array<BigNumber> = await router2.getAmountsOut(amountIn, path);
        return amountOut[amountOut.length - 1];
    } catch (error) {
        return parseUnits("0");
    }
}

// 输出求输入
export const getAmountsIn = async (
    amountOut:BigNumber,
    path:Array<string>
):Promise<BigNumber> => {
    try {
        const { router2 } = await createContract();
        const amountIn:Array<BigNumber> = await router2.getAmountsIn(amountOut, path);
        return amountIn[0];
    } catch (error) {
        return parseUnits("0");
    }
}


export const swapExactTokensForTokens = async (
    amountIn:BigNumber,
    amountOutMin:BigNumber,
    path:Array<string>,
    to:string,
    deadline: number
):Promise<boolean> => {
    try {
        const { router2 } = await createContract();
        const tx = await router2.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            Date.now() + 1000 * 60 * deadline
        )
        await tx.wait();
        ElMessage.success("swap 交换成功！");
        return true
    } catch (error) {
        console.log(error);
        ElMessage.error(error!);
        return false;
    }    
}


export const swapTokensForExactTokens = async (
    amountOut:BigNumber,
    amountInMax:BigNumber,
    path:Array<string>,
    to:string,
    deadline:number
):Promise<boolean> => {
    try {
        const { router2 } = await createContract();
        const tx = await router2.swapTokensForExactTokens(
            amountOut,
            amountInMax,
            path,
            to,
            Date.now() + 1000 * 60 * deadline
        )
        await tx.wait();
        return true;
    } catch (error) {
        console.log(error);
        ElMessage.success("swap 交换成功！");
        ElMessage.error(error!);
        return false;
    }    
}


export const swapExactETHForTokens = async (
    amountOutMin:BigNumber,
    amountEth:BigNumber,
    path:Array<string>,
    to:string,
    deadline:number
) => {
    try {
        const { router2 } = await createContract();
        const tx = await router2.swapExactETHForTokens(
            amountOutMin,
            path,
            to,
            Date.now() + 1000 * 60 * deadline,
            {
                value:amountEth
            }
        )
        await tx.wait();
        ElMessage.success("swap 交换成功！");
        return true
    } catch (error) {
        console.log(error);
        ElMessage.error(error!);
        return false;
    }    
}

export const swapETHForExactTokens = async ( 
    amountOut:BigNumber,
    amountEth:BigNumber,
    path:Array<string>,
    to:string,
    deadline:number
) => {
    try {
        const { router2 } = await createContract();
        const tx = await router2.swapETHForExactTokens(
            amountOut,
            path,
            to,
            Date.now() + 1000 * 60 * deadline,
            {
                value:amountEth
            }
        )
        await tx.wait();
        ElMessage.success("swap 交换成功！");
        return true
    } catch (error) {
        console.log(error);
        ElMessage.error(error!);
        return false;
    } 
}

export const swapTokensForExactETH = async (
    amountOut:BigNumber,
    amountInMax:BigNumber,
    path:Array<string>,
    to:string,
    deadline:number
) => {
    try {
        const { router2 } = await createContract();
        const tx = await router2.swapTokensForExactETH(
            amountOut,
            amountInMax,
            path,
            to,
            Date.now() + 1000 * 60 * deadline
        )
     
        await tx.wait();
        ElMessage.success("swap 交换成功！");
        return true
    } catch (error) {
        console.log(error);
        ElMessage.error(error!);
        return false;
    }  
}


export const swapExactTokensForETH = async (
    amountIn:BigNumber,
    amountOutMin:BigNumber,
    path:Array<string>,
    to:string,
    deadline:number
) => {
    try {
        const { router2 } = await createContract();
        const tx = await router2.swapExactTokensForETH(
            amountIn, 
            amountOutMin,
            path,
            to,
            Date.now() + 1000 * 60 * deadline,
        )
        await tx.wait();
        ElMessage.success("swap 交换成功！");
        return true
    } catch (error) {
        console.log(error);
        ElMessage.error(error!);
        return false;
    }    
}




