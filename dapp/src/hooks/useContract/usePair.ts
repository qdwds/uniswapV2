import { BigNumber, Contract, ethers } from "ethers";
import { createContract } from "./useContracts"
import { abi } from "../../../../uniswap/abi/IUniswapV2Pair.json";
import { useGetAccount, useGetSigner } from "../useStore/useAccount";
import { formatUnits } from "@ethersproject/units"


export interface IReserve{
    pairTotal: string,
    address0?:string,
    address1?:string,
    token0: string,
    token1: string,
    removeToken0?:number,
    removeToken1?:number,
    removePair?:number,
}
// 返回 pair address
export const useGetPair = async (token0:string, token1:string):Promise<string> =>{
    const { factory } = await createContract();
    return await factory.getPair(token0, token1);
}

// pair 给路由授权
export const pairApprove = async(token0:string, token1:string):Promise<boolean>=>{

    const pairAddress = await useGetPair(token0, token1);
    const { router2 } = await createContract();
    const signer = useGetSigner()
    const pair = new ethers.Contract(pairAddress, ["function approve(address spender, uint value) external returns (bool)"], signer!);
    try {
        await pair.approve(router2.address, ethers.constants.MaxUint256);
        return true;
    } catch (error) {
        return false;
    }

}

// 查看授权额度
export const pairAllowance = async (token0:string, token1:string):Promise<boolean> => {
    const pairAddress = await useGetPair(token0, token1);
    console.log(pairAddress);
    
    const account = useGetAccount();
    const { router2 } = await createContract();
    const signer = useGetSigner()
    const pair = new ethers.Contract(pairAddress, abi, signer!);
    const isAll = await pair.allowance(account, router2.address);
    console.log(formatUnits(isAll));
    
    return formatUnits(isAll) != "0.0"
}




// 获取pair 储备量
export const useGerPairReserve = async (pairAddress:string):Promise<IReserve> => {
    const signer = useGetSigner();
    const pair = new ethers.Contract(pairAddress, abi, signer!);
    const pairTotal = await pair.totalSupply();
    const [token0, token1, ] = await pair.getReserves();
    return{
        pairTotal: formatUnits(pairTotal),
        token0:formatUnits(token0),
        token1:formatUnits(token1),
    }
    
}
