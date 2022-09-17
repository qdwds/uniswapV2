import { ethers } from "hardhat";
import { overrides } from "../utils/gas";
import { connectNetwork, createContracts } from "../utils/contracts/createContract";
import address from "../abi/uniswapV2.json";
const MINIMUM_LIQUIDITY = ethers.utils.parseUnits("1", 3);

const removeLiquidity = async () => {
    const { signer } = connectNetwork();
    const { token0, token1, router2, factory } = await createContracts(signer);

    const pairAddress = await factory.getPair(token0.address, token1.address);
    if(pairAddress == ethers.constants.AddressZero) return console.log(pairAddress);

    const pair = await ethers.getContractAt("UniswapV2Pair", pairAddress, signer);
    await pair.approve(router2.address, ethers.constants.MaxUint256);

    // liquidity total
    const pair_total = await pair.totalSupply();
    // liquidity == 1000; fee  
    if(pair_total.eq(MINIMUM_LIQUIDITY)) return console.log("liquidity is empty !");

    const tx = await router2.removeLiquidity(
        token0.address,
        token1.address,
        pair_total.sub(MINIMUM_LIQUIDITY), //  移除 => 按照比例来移除 1%-100%
        0,
        0,
        signer.address,
        Date.now() + 1000 * 60 * 10,
        overrides
    )
    await tx.wait();
    console.log("removeLiquidity success ok !");
    console.log(await pair.totalSupply());
}


const removeLiquidityETH = async()=>{
    const { signer } = connectNetwork();
    const { token1, router2, factory } = await createContracts(signer);

    const pairAddress = await factory.getPair(token1.address, address.WETH9);    
    if(pairAddress == ethers.constants.AddressZero) return console.log(pairAddress);

    const pair = await ethers.getContractAt("UniswapV2Pair", pairAddress, signer);
    await pair.approve(router2.address, ethers.constants.MaxUint256);

    const pair_total = await pair.totalSupply();
    if(pair_total.eq(MINIMUM_LIQUIDITY)) return console.log("liquidity is empty !");

    const tx = await router2.removeLiquidityETH(
        token1.address,
        pair_total.sub(MINIMUM_LIQUIDITY),
        0,
        0,
        signer.address,
        Date.now() + 1000 * 60 * 10,
        overrides
    )
    await tx.wait();
    console.log("removeLiquidityETH success ok !");
    console.log(await pair.totalSupply());
    
}

const main = async ()=> {
    await removeLiquidity();
    await removeLiquidityETH();
}

main()
    .catch((err:any)=>{
        console.log(err);
        process.exit(1);
    })