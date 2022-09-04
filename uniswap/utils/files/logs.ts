import { BigNumber } from "ethers";
import { appendFile } from "fs";
import { resolve } from "path";


export interface ILog {
    method: string,
    name: Array<string>,
    slip: number,
    path: Array<string>,
    amountList:Array<BigNumber>
    amountIn?: string,
    amountInMax?: string,
    amountInMin?: string,
    amountOut?: string,
    amountOutMax?: string,
    amountOutMin?: string,
}

const logs_path = resolve(__dirname, "../../logs");
export const createLogs = async (log: ILog) => {
    appendFile(resolve(logs_path, `${log.method}.json`), `${JSON.stringify(log)}\n`, (err: any) => {
        if (err) return console.log(err);
        console.log(`${log.method} appendFile success !`);
    })
}