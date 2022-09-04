import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { BigNumber, Contract } from "ethers"
import { ethers } from "hardhat"
import { dead, deploy , maxUint, minutes, overrides} from "./deploy/deploy"


describe("swapExactTokensForTokens",()=>{

    // 添加流动性
    async function addLiquidity(
        token0Amount:BigNumber,
        token1Amount: BigNumber,
        token0:Contract,
        token1:Contract,
        pair:Contract,
        owner:SignerWithAddress
    ) {
        await token0.transfer(pair.address, token0Amount)
        await token1.transfer(pair.address, token1Amount)
        await pair.mint(owner.address, overrides)
    }

    beforeEach(async ()=>{
        await addLiquidity
    })
    it("", async()=> {
        const token0Amount = ethers.utils.parseUnits("5");
        const token1mount = ethers.utils.parseUnits("10");
        const swapToken = ethers.utils.parseUnits("1");
        const expectedOutputAmount = ethers.BigNumber.from("1662497915624478906");


    })
})