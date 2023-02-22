import fs from "fs";
import { join } from "path";
const pairsPath = join(__dirname, "../../abi/pairs.json");
export interface IPair {
    type: string,
    pair: string,
    tokenA: string,
    tokenB: string,
    tokenAName: string,
    tokenBName: string,
    reserveA: string,
    reserveB: string,
    totalSupply:string,
    createTime?: Date,
    updateTime: Date,
    fee: number,
    tokenAAmount?:string,
    tokenBAmount?:string,
    ethAmount?:string
}

//  save pairs info
export const createPairs = async (pair: IPair) => {
    fs.access(pairsPath, fs.constants.F_OK, (err: any) => {
        if (err) {
            fs.writeFileSync(pairsPath, JSON.stringify([pair]));
        } else {
            fs.readFile(pairsPath, "utf-8", (err: NodeJS.ErrnoException | null, data: any) => {
                if (err != null) return console.log("readFile fined !!");
                let fileData = JSON.parse(data);

                let is = fileData.find((f: IPair) => f.pair == pair.pair);
                if (is) {
                    fileData = fileData.map((f: IPair) => {
                        if (f.pair == pair.pair) {
                            return {
                                ...pair
                            }
                        } else {
                            return {
                                ...f
                            }
                        }
                    })
                } else {
                    fileData.push(pair);
                }
                fs.writeFileSync(pairsPath, JSON.stringify(fileData));
            })
        }
    })
}


