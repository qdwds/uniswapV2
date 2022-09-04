import { ethers } from "../../node_modules/ethers/dist/ethers.esm.min.js";
const addNet = document.getElementById("addNet");
const chaNet = document.getElementById("chaNet");
const connect = document.getElementById("connect");
const close = document.getElementById("close");

;(async ()=>{
    const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545")
    const account:Array<string> = await window.ethereum.request({ method: 'eth_requestAccounts' });
    console.log(account);
    console.log(provider);
    
    
})()
console.log(ethereum.isConnected());

//  地址更改事件
window.ethereum.on("accountsChanged",(accounts:Array<string>)=>{
    console.log(accounts);
})
// 网络改变
window.ethereum.on("chainChanged",(chainId:any)=>{
    console.log(chainId);
    
})
// 连接网络

window.ethereum.on('connect', (connectInfo:any) => {
    console.log(connectInfo);
    
})
// 网路断开
window.ethereum.on('disconnect',  (error: any) => {
    console.log(error);
    
});

//  添加网络
addNet!.onclick = () => {
    window.ethereum.request({
        method:"wallet_addEthereumChain",
        params: [{ chainId: '0x100' }]
    })
}

//  切换网络
chaNet!.onclick = () =>{
    window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: 1 }],
      });
}