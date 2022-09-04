import { ethers, Signer, Wallet } from "ethers"
import { abi as factoryAbi } from "../../../../uniswap/abi/UniswapV2Factory.json";
import { abi as router2Abi } from "../../../../uniswap/abi/UniswapV2Router02.json";
import { abi as wethAbi } from "../../../../uniswap/abi/WETH9.json";
import address from "../../../../uniswap/abi/uniswapV2.json";
import { abi as tokenAbi } from "../../../../uniswap/abi/Token.json";
import { useGetSigner } from "../useStore/useAccount";

// create coantracts 
export const createContract = async (signer?: Signer | Wallet) => {
    const innerSigner = useGetSigner();
    const factory = new ethers.Contract(address.UniswapV2Factory, factoryAbi, signer? signer : innerSigner!);
    const router2 = new ethers.Contract(address.UniswapV2Router02, router2Abi, signer? signer : innerSigner!);
    const weth = new ethers.Contract(address.WETH9, wethAbi, signer? signer : innerSigner!);
    const token0 = new ethers.Contract(address.token0, tokenAbi, signer? signer : innerSigner!);
    const token1 = new ethers.Contract(address.token1, tokenAbi, signer? signer : innerSigner!);
    const token2 = new ethers.Contract(address.token2, tokenAbi, signer? signer : innerSigner!);
    const token3 = new ethers.Contract(address.token3, tokenAbi, signer? signer : innerSigner!);

    return {
        factory,
        router2,
        weth,
        token0,
        token1,
        token2,
        token3
    }

}

