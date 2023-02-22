import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect, util } from "chai";
import { BigNumber, Contract, utils } from "ethers";
import { ethers } from "hardhat";
import { bigNum, deploy, minutes } from "./deploy/deploy";
    // 预计使用的gas
    const overrides = {
        gasLimit: 9999999
    }
describe("UniswapV2Library", () => {

    it("getAmountOut", async() => {
        const { router } = await loadFixture(deploy);
        // 为什么TM的 要等于19呢？因为以太坊不能处理小数
        
        // 计算正确价格
        expect(await router.getAmountOut(BigNumber.from(20), BigNumber.from(1000), BigNumber.from(1000))).to.eq(BigNumber.from(19));
        // await expect( router.getAmountOut(BigNumber.from(0), BigNumber.from(1000), BigNumber.from(1000))).to.be.revertedWith("UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT")
        // await expect( router.getAmountOut(BigNumber.from(20), BigNumber.from(0), BigNumber.from(1000))).to.be.revertedWith("UniswapV2Library: INSUFFICIENT_LIQUIDITY")
        // await expect( router.getAmountOut(BigNumber.from(20), BigNumber.from(1000), BigNumber.from(0))).to.be.revertedWith("UniswapV2Library: INSUFFICIENT_LIQUIDITY")
    })

    it("getAmountIn", async() => {
        const { router } = await loadFixture(deploy);
        expect(await router.getAmountIn(bigNum(200), bigNum(1000), bigNum(1000))).to.eq(bigNum(251));
    })

    // it("getAmountsOut", async() => {
    //     const { router, token0, token1, owner} = await loadFixture(deploy);
    //     // 授权
    //     await token0.approve(router.address, ethers.constants.MaxUint256);
    //     await token1.approve(router.address, ethers.constants.MaxUint256);
    //     // 添加流动性
    //     await router.addLiquidity(
    //         token0.address,
    //         token1.address,
    //         bigNum(10000),
    //         bigNum(10000),
    //         0,
    //         0,
    //         owner.address,
    //         minutes(15),
    //         overrides
    //     )
    //     const path = [token0.address, token1.address];
    //     expect(await router.getAmountsOut(bigNum(1000), path)).to.deep.eq([bigNum(1000), bigNum(906)]);
    // })
})