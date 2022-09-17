import { JsonRpcProvider } from "@ethersproject/providers";
import type { Contract, Signer, Wallet } from "ethers";
import { ethers } from "hardhat"
import address from "../../abi/uniswapV2.json";

interface IConNet {
    provider: JsonRpcProvider,
    signer: Wallet
}
interface IContracts {
    token0: Contract,
    token1: Contract,
    factory: Contract,
    router2: Contract,
}
// connect network !!
export const connectNetwork = (net?: string): IConNet => {
    const provider: JsonRpcProvider = new ethers.providers.JsonRpcProvider(net ? net : process.env.HARDHAT_NET);
    const wallet: Wallet = new ethers.Wallet(process.env.HARDHAT_PRIVATE_KEY!);
    const signer: Wallet = wallet.connect(provider);
    return {
        provider,
        signer
    }
}

// create Contracts
export const createContracts = async (signer: Signer) => {
    const token0: Contract = await ethers.getContractAt("Token0", address.token0, signer);
    const token1: Contract = await ethers.getContractAt("Token1", address.token1, signer);
    const token2: Contract = await ethers.getContractAt("Token2", address.token2, signer);
    const token3: Contract = await ethers.getContractAt("Token3", address.token3, signer);
    const uni: Contract = await ethers.getContractAt("Uni", address.uni, signer);
    const factory: Contract = await ethers.getContractAt("UniswapV2Factory", address.UniswapV2Factory, signer);
    const router2: Contract = await ethers.getContractAt("UniswapV2Router02", address.UniswapV2Router02, signer);
    const weth: Contract = await ethers.getContractAt("WETH9", address.WETH9, signer);
    
    return {
        token0,
        token1,
        token2,
        token3,
        uni,
        factory,
        router2,
        weth,
    }
}

