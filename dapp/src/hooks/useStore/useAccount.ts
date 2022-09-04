import { Signer } from "ethers";
import { toRaw } from "vue";
import { useAccount } from "../../store/account";

const store = useAccount();

export const useGetAccount = () :string => toRaw(store.getAccount)
export const useSetAccount = (account: string): void => store.setAccount(account);


export const useGetSigner = (): Signer | null => toRaw(store.signer);
export const useSetSigner = (signer: Signer): void =>  store.setSigner(signer)



