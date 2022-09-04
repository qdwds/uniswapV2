import { BigNumber, Contract, ethers, Signer, Wallet } from "ethers"
import { formatUnits, parseUnits } from "ethers/lib/utils";
import { abi} from "../../../../uniswap/abi/Token.json";
import { useGetAccount, useGetSigner } from "../useStore/useAccount";
import { info as router2} from "../../../../uniswap/abi/UniswapV2Router02.json";
import { info as weth9 } from "../../../../uniswap/abi/WETH9.json";
interface IERC20 {
    name:string,
    symbol:string,
    balance:string
}


// get erc20 info
export const useGetERC20Info = async(address:string, signer:Wallet):Promise<IERC20> =>{
    const accmount = await  useGetAccount();
    const token = new ethers.Contract(address, abi, signer);
    const name = await token.name();
    const symbol = await token.symbol();
    const balance = formatUnits(await token.balanceOf(accmount));
    return {
        name,
        symbol,
        balance
    }
}

const getContract = async (address:string, signer?:Signer|Wallet):Promise<Contract> =>{
    const innerSigner = useGetSigner();
    return new ethers.Contract(address, abi, signer ? signer: innerSigner!);
}


export const useGetBalance =  async(address:string, account?:string, signer?:Signer)=>{
    const innerAccount = useGetAccount();
    const innerSigner = useGetSigner();
    if(address == weth9.address){
        return innerSigner!.getBalance();
    }else{
        const token = new ethers.Contract(address, abi, signer ?signer : innerSigner!);
        return await token.balanceOf(account ? account : innerAccount!).catch((err:any) =>{err});
    }
   
}

// 授权
export const useERC20Approve = async (address:string, amount?:string, signer?:Signer|Wallet) =>{
    let token:Contract;
    if(address == weth9.address){
        token = await getContract(address);
        try {
            const success = await token.approve(router2.address,  amount? parseUnits(amount): ethers.constants.MaxUint256).catch((err:any) =>{err});
            await success.wait();
            return true;
        } catch (error) {
            return false;
        }
    }else{
        try {
            token = await getContract(address);
            const success = await token.approve(router2.address, amount? parseUnits(amount): ethers.constants.MaxUint256).catch((err:any) =>{err});
            await success.wait();
            return true;
        } catch (error) {
            return false;
        }
    }
    
}


// 检测是否授权
export const useERC20Allowance = async(address:string, signer?:Signer|Wallet):Promise<boolean> =>{
    const account = useGetAccount();
    const token = await getContract(address, signer);
    const isAll = await token.allowance(account, router2.address).catch((err:any) =>{err});;
    console.log(formatUnits(isAll));
    return formatUnits(isAll) != "0.0"
}