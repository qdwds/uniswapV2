import { connectNetwork, createContracts } from "../utils/contracts/createContract";
import address from "../abi/uniswapV2.json";
import { Contract } from "ethers";

/**
 * 根据传入的路由查找最优路径
 */

//  根据固定输入数量，计算最优输出数量的路径
export const bestTradeExactIn = async (paths:Array<string>, factory:Contract) => {
    if(paths.length !==  2 ) return console.log("path length !== 2");
    // 只处理大于三个的
   
    
    
}
// 根据固定输出数量，计算最优输入数量的路径
export const bestTradeExactOut = async() => {

}

const getPair = async (tokenA:string, tokenB:string):Promise<string> =>{
    const { signer } = connectNetwork();
    const { factory } = await createContracts(signer);
    return await factory.getPair(tokenA, tokenB);
}

const main = async() => {
    const { signer } = connectNetwork();
    const { factory} = await createContracts(signer);
    // [token0 > token1 > token2 > token3];
    await bestTradeExactIn([address.token0, address.token1], factory);
    await bestTradeExactIn([address.token0, address.token3], factory);
}


main()
    .catch(_=>{
        console.log(_);
        process.exit();
    })