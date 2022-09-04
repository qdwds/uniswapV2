import { ethers } from "./node_modules/ethers/dist/ethers.esm";
import { abi as router2Abi,info as router2Info} from "./UniswapV2Router02.json";
import { abi as factoryAbi, info as factoryInfo } from "./UniswapV2Factory.json";
import address from "./uniswapV2.json";

const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545/");
const wallet = new ethers.Wallet("0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80");
const signer = wallet.connect(provider);
const router2:any = new ethers.Contract(router2Info.address, router2Abi, signer);
const factory:any = new ethers.Contract(factoryInfo.address, factoryAbi, signer);

let reserve0;
let reserve1;
const t0 = document.getElementById("t0")!;
const t1 = document.getElementById("t1")!;
const v0 = document.getElementById("v0")!;
const v1 = document.getElementById("v1")!;

console.log(t0);


const getInfo = async()=>{
    const pair_addr = await factory.getPair(address.token0, address.token1);
    const pair = new ethers.Contract(pair_addr,["function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast)","function totalSupply() external view returns (uint)"], signer);
    let [ _reserve0, _reserve1, ] = await pair.getReserves();
    reserve0 = _reserve0;
    reserve1 = _reserve1;
    v0.innerHTML = ethers.utils.formatUnits(reserve0);
    v1.innerHTML = ethers.utils.formatUnits(reserve1);
    console.log(reserve0.toString(), reserve1.toString(), (await pair.totalSupply()).toString());
}


getInfo();
t0.onchange = async (value)=>{
    const v = value.target.value;
    // 输入一个token josua
    const amountOut = await router2.getAmountOut(ethers.utils.parseUnits(v), reserve0, reserve1);
    // const amountOut = await router2.quote(ethers.utils.parseUnits(v), reserve0, reserve1);
    console.log(amountOut.toString());
    console.log(ethers.utils.formatUnits(amountOut));
    t1.value = ethers.utils.formatUnits(amountOut)
    
}