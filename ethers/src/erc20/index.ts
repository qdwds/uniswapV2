import { ethers } from "../../node_modules/ethers/dist/ethers.esm.min.js";
import { info, abi } from "../../../uniswap/abi/Token0.json";



const provider = new ethers.providers.Web3Provider(window.ethereum);
const account = provider.send("eth_requestAccounts",[]);
console.log(await account);

const contract = new ethers.Contract(info.address, abi, await provider.getSigner());
console.log(contract);


;(async ()=>{
    console.log((await contract.allowance("0xb16fef904f4505b525539626b88e3e61439ca31c", "0x4C65fD8a8f3A2f8896bCe8668C12d21d99587933")).toString());
    await contract.approve("0x4C65fD8a8f3A2f8896bCe8668C12d21d99587933","111111");
    console.log((await contract.allowance("0xb16fef904f4505b525539626b88e3e61439ca31c","0x4C65fD8a8f3A2f8896bCe8668C12d21d99587933")).toString());


})()