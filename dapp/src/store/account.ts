import type { Signer } from 'ethers';
import { defineStore } from 'pinia'

interface IAccount {
    account:string,
    signer: any
}
export const useAccount = defineStore('account', {
    state: ():IAccount => ({
        account: "",
        signer:null
    }),
    getters: {
        getAccount():string{
            return this.account;
        },
        getSigner():Signer{
            return this.signer;
        }
    },
    actions: {
        setAccount(account: string):void {
            this.account = account;
        },
        setSigner(signer: Signer): void{
            this.signer = signer;
        }
    },
    // persist: {
    //     enabled: true
    // }
})