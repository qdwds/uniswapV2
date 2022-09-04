import { readFile, writeFile, writeFileSync } from "fs";
import { network } from "hardhat";
import { join, resolve } from "path";
import { uniswapV2Factory } from "./uniswap/UniswapV2Factory"
import { uniswapV2Router02 } from "./uniswap/UniswapV2Router02";
import { WETH9 } from "./uniswap/WETH9";
import { multicall } from "./uniswap/Multicall";
import { token0, token1, token2, token3, tokens } from "./erc20/tokens";

const uniswap = async () => {
    const factory = await uniswapV2Factory("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    const weth = await WETH9();
    const INIT_CODE_PAIR_HASH = await factory.INIT_CODE_PAIR_HASH();

    const hex = INIT_CODE_PAIR_HASH.slice(2);
    await editRouterHex(hex);
    const router2 = await uniswapV2Router02(factory.address, weth.address);

    const multi = await multicall();

    // 部署token
    const t0 = await token0();
    const t1 = await token1();
    const t2 = await token2();
    const t3 = await token3();
    // const ts =  await tokens()
    // interface IStable {
    //     [name:string]:string
    // }
    // const stable:IStable = {};
    // for (let i = 0; i < ts.length; i++) {
    //    stable[await ts[i].symbol()] = ts[i].address;
    // }
    // console.log(stable)
    const info = {
        network: network.name,
        WETH9: weth.address,
        UniswapV2Factory: factory.address,
        UniswapV2Router02: router2.address,
        Multicall:multi.address,
        hex: hex,
        token0: t0.address,
        token1: t1.address,
        token2: t2.address,
        token3: t3.address,
        // ...stable
    }
    console.log(info);
    // const infoPath = resolve(join(__dirname,"../abi/uniswapV2.json"));
    // await writeFileSync(infoPath, JSON.stringify(info));
}

// 修改 uniswapV2Router2 hex
const editRouterHex = async (hex:string) => {
    const ROUTER2_PATH = resolve(join(__dirname,"../contracts/UniswapV2Router02.sol"));
    readFile(ROUTER2_PATH,"utf-8",(err, data)=>{
        if(err != null) return console.error(err);
        const context = data.replace(/\hex\"(\S+)\" \/\/ init/, `hex"${hex}" // init`);
        writeFile(ROUTER2_PATH, context, err => {
            if(err != null) return console.error(err);
            console.log("UniswapV2ERC20 change hex success !")
        })
    })
}


uniswap()
    .catch(_=>{
        console.log(_);
        process.exit(1);
    })