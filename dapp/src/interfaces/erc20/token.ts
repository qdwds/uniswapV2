import { BigNumber } from 'ethers';


export interface IToken {
    address: string,
    value: string,
    name?: string,
    symbol: string,
    balance:BigNumber|string,
    logoURI?:string,
}