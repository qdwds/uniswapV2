import { ethers } from "ethers";
import { formatEther, formatUnits, parseUnits } from "ethers/lib/utils";
const provider = new ethers.providers.JsonRpcProvider("https://eth-mainnet.g.alchemy.com/v2/lkxGAuyXM0k6BgpTVmne15PetcKkFTo3");

const abi = [
    "function balanceOf(address) public returns (uint)"
];

const erc721 = new ethers.Contract("0xB8c77482e45F1F44dE1745F52C74426C631bDD52", abi, provider);
const inter = erc721.interface;
const main = async()=>{
    // 获取选择器，参数：函数名或者函数签名
    // const a = inter.getSighash("balanceOf");
    // console.log(a)

    //  编码
    const balanceCallData = inter.encodeFunctionData("balanceOf",["0xbe0eb53f46cd790cd13851d5eff43d12404d33e8"]);
    console.log(balanceCallData);
    // 使用编码来调用函数
    // 创建交易
    const tx = {
        to: "0xB8c77482e45F1F44dE1745F52C74426C631bDD52",
        data: balanceCallData
    }

    // 通过call 调用
    const res = await provider.call(tx);
    console.log(formatUnits(res));
    

}



main();