
import { ethers } from "ethers";
import { useSetAccount, useSetSigner } from "../useStore/useAccount";


// 连接metamask钱包
export const useConnectMetamask = async () => {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const account = await provider.send("eth_requestAccounts", []);
    const signer = await provider.getSigner();
    
    useSetAccount(account[0] || "");
    useSetSigner(signer);
}