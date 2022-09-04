import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { expect } from "chai"
import { BigNumber, Contract } from "ethers"
import { ethers } from "hardhat"
import { token } from "../typechain-types/@openzeppelin/contracts"
import { dead, deploy , maxUint, minutes, overrides} from "./deploy/deploy"

describe("UniswapV2Router02", ()=> {
    const MINIMUM_LIQUIDITY = ethers.utils.parseUnits("1", 3);
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
    it("addLiquidity",async()=>{
        const { router, token0, token1, owner, pair } = await loadFixture(deploy);
        
        const expectedLiquidity = ethers.utils.parseUnits("2", 18);
        const token0Amount = ethers.utils.parseUnits("1", 18);
        const token1Amount = ethers.utils.parseUnits("4", 18);
       
        await token0.approve(router.address, maxUint);
        await token1.approve(router.address, maxUint);

        const addLiquidity = await expect( await router.addLiquidity(
            token0.address, 
            token1.address, 
            token0Amount, 
            token1Amount, 
            0, 
            0, 
            owner.address, 
            minutes(15), 
            overrides
        ))
        addLiquidity.to.emit(token0, "Transfer").withArgs(owner.address, pair.address, token0Amount)
            .to.emit(token1, "Transfer").withArgs(owner.address, pair.address, token1Amount)
            .to.emit(pair, "Transfer").withArgs(dead, dead, MINIMUM_LIQUIDITY)
            .to.emit(pair, "Transfer").withArgs(dead, owner.address, expectedLiquidity.sub(MINIMUM_LIQUIDITY))
            .to.emit(pair, "Sync").withArgs(token0Amount, token1Amount)
            .to.emit(pair, "Mint").withArgs(router.address, token0Amount, token1Amount)

            console.log(
                await pair.balanceOf(owner.address),
                expectedLiquidity.sub(MINIMUM_LIQUIDITY)
            )   
        expect(await pair.balanceOf(owner.address)).to.eq(expectedLiquidity.sub(MINIMUM_LIQUIDITY)); 
    })

    it("addLiquidityETH",async () => {
        // 期望数量
        const partnerAmount = ethers.utils.parseUnits("1", 18);
        const WETHAmount = ethers.utils.parseEther("4");
        // 预期流动性
        const expectedLiquidity= ethers.utils.parseUnits("2", 18);
        // WETHPair 带有ETH的pair => pair
        const { WETHPair  , token0, router , owner } = await loadFixture(deploy);
        // console.log(
        //     await WETHPair.token0(),
        //     token0.address
        // );
        const ETHPairToken0 = await WETHPair.token0();
        // token0 授权
        await token0.approve(router.address, maxUint);
        await expect(router.addLiquidityETH(
            token0.address, 
            partnerAmount, 
            partnerAmount,
            WETHAmount,
            owner.address,
            minutes(15),
            { 
                ...overrides,   // 交易gas
                value: WETHAmount   //  交易ETH 数量
            }
        ))
        .to.emit(WETHPair, "Transfer").withArgs(dead, dead, MINIMUM_LIQUIDITY)
        .to.emit(WETHPair, "Transfer").withArgs(dead, owner.address, expectedLiquidity.sub(MINIMUM_LIQUIDITY))
        .to.emit(WETHPair, "Sync").withArgs(
            // 这里是判断的pair中的第一个token是不是token0的地址  如：[0,1]的0 项 = 0;
            ETHPairToken0 == token0.address ? partnerAmount : WETHAmount,
            ETHPairToken0 == token0.address ? WETHAmount : partnerAmount,
        )
        .to.emit(WETHPair, "Mint").withArgs(
            router.address,
            ETHPairToken0 == token0.address ? partnerAmount : WETHAmount,
            ETHPairToken0 == token0.address ? WETHAmount : partnerAmount,
        )
        console.log(await WETHPair.balanceOf(owner.address), expectedLiquidity.sub(MINIMUM_LIQUIDITY));
        expect(await WETHPair.balanceOf(owner.address)).to.eq(expectedLiquidity.sub(MINIMUM_LIQUIDITY))
    })

    
    it("removeLiquidity",async () => {
        const token0Amount = ethers.utils.parseUnits("1", 18);
        const token1Amount = ethers.utils.parseUnits("4", 18);
        const expectedLiquidity = ethers.utils.parseUnits("2", 18);
        const { pair, token0, token1, router , owner } = await loadFixture(deploy);
        await addLiquidity(token0Amount, token1Amount, token0, token1, pair, owner);
        await pair.approve(router.address, maxUint);

        const removeLiquidity = await expect(await router.removeLiquidity(
           token0.address,
           token1.address,
           expectedLiquidity.sub(MINIMUM_LIQUIDITY),
           0,
           0,
           owner.address,
           minutes(15),
           overrides
        ))
        removeLiquidity.to.emit(pair, "Transfer").withArgs(owner.address, pair.address, expectedLiquidity.sub(MINIMUM_LIQUIDITY))
            .to.emit(pair, "Transfer").withArgs(pair.address, dead, expectedLiquidity.sub(MINIMUM_LIQUIDITY))
            .to.emit(token0, "Transfer").withArgs(pair.address, owner.address, token0Amount.sub(500))
            .to.emit(token1, "Transfer").withArgs(pair.address, owner.address, token0Amount.sub(2000))
            .to.emit(pair, "Sync").withArgs(500, 2000)
            .to.emit(pair, "Burn").withArgs(router.address, token0Amount.sub(500), token1Amount.sub(2000),owner.address)

        // 移除完货 pair值应该是 0
        expect(await pair.balanceOf(owner.address)).to.eq(0);
        const totalSupplyToken0 = await token0.totalSupply();
        const totalSupplyToken1 = await token1.totalSupply();
        console.log("totalSupplyToken0", totalSupplyToken0);
        console.log("totalSupplyToken1", totalSupplyToken1);
        expect(await token0.balanceOf(owner.address)).to.eq(totalSupplyToken0.sub(500));
        expect(await token1.balanceOf(owner.address)).to.eq(totalSupplyToken1.sub(2000));
    })
})