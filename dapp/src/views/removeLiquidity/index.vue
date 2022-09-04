<template>
    <div class="liquidity">
        <el-card  shadow="never">
            <div v-if="!tokenList.isLiquidity">
                <div class="remove_box">
                    <el-select v-model="tokenList.token1" clearable class="m-2" placeholder="Select" size="large">
                        <el-option v-for="item in tokenList.tokens" :key="item.address" :label="item.symbol" :value="item.address"/>
                    </el-select>
                    <el-select v-model="tokenList.token2" clearable class="m-2" placeholder="Select" size="large">
                        <el-option v-for="item in tokens" :key="item.address" :label="item.symbol" :value="item.address"/>
                    </el-select>
                </div>
                <el-button type="primary" @click="searchLiquidity">查找流动性</el-button>
            </div>
           
            <div v-else>
                {{tokenList.isAppowance}}
                <el-button type="primary" v-if="!tokenList.isAppowance" @click="handlePairApprove">授权</el-button>
                <div v-else>
                    <div>总量</div>
                    <div>pari总量{{reserve.pairTotal}}</div>
                    <div>{{reserve.address0}}: {{reserve.token0}}</div>
                    <div>{{reserve.address1}}: {{reserve.token1}}</div>
                    <div>预计可以提出</div>
                    <div>{{reserve.address0}}: {{reserve.removeToken0}}</div>
                    <div>{{reserve.address1}}: {{reserve.removeToken1}}</div>
                    <el-slider v-model="removeVal" @change="changeRemove"/>
                    <el-button type="primary" @click="handleRemoveLiquidity">移除流动性</el-button>
                </div>
            </div>
        </el-card>
    </div>
</template>

<script lang="ts" setup>
import { reactive, ref } from "vue";
import { tokens } from "../../assets/json/tokens.json";
import { useGetPair, useGerPairReserve, IReserve, pairApprove,pairAllowance } from "@/hooks/useContract/usePair";
import { ElMessage } from "element-plus";
import { ethers } from "ethers";
import { useGetAccount } from "@/hooks/useStore/useAccount";
import { removeLiquidity, removeLiquidityETH } from "@/hooks/useContract/useRouter2";
import { parseUnits } from "@ethersproject/units";
import { createContract } from "@/hooks/useContract/useContracts";
import address from "../../../../uniswap/abi/uniswapV2.json";
const tokenList = reactive({
    tokens,
    token1:"",
    token2:"",
    isLiquidity: false,
    isAppowance: false,
})
const reserve = reactive<IReserve>({
    pairTotal:"0",
    address0:"",
    address1:"",
    token0:"0",
    token1:"0",
    removeToken0:0,
    removeToken1:0,
    removePair:0,//    展示用不传
})
// 查找流动性
const searchLiquidity = async () =>{
    if(!tokenList.token1 || !tokenList.token1 ) return ElMessage.error("token不能为空！")
    const pair = await useGetPair(tokenList.token1, tokenList.token2);
    if(pair == ethers.constants.AddressZero) return ElMessage.error('没有找到对应的流动性');
    const reserves = await useGerPairReserve(pair);
    const address = tokenList.token1 < tokenList.token2 ? [tokenList.token1, tokenList.token2]:[tokenList.token2, tokenList.token1]; 

    reserve.address0 = address[0];
    reserve.address1 = address[1];
    reserve.pairTotal = reserves.pairTotal;
    reserve.token0 = reserves.token0;
    reserve.token1 = reserves.token1;
    await isAppowance();
    tokenList.isLiquidity = true;
}
const removeVal = ref<number>(0)

// 检查是否授权
const isAppowance = async() => {
    const isApp = await pairAllowance(tokenList.token1, tokenList.token2);
    console.log(isApp);
    
    tokenList.isAppowance = isApp;
}
// 授权
const handlePairApprove = async () =>{
    const approve = await pairApprove(tokenList.token1, tokenList.token2);
    if(approve){
        ElMessage.success("添加授权成功!")
    }else{
        ElMessage.error("pair给router授权失败!");        
    }
    await isAppowance();
    
}

const changeRemove = (v:number) =>{
    reserve.removeToken0 = Number(reserve.token0) * v / 100;
    reserve.removeToken1 = Number(reserve.token1) * v / 100;
    reserve.removePair = Number(reserve.pairTotal) * v / 100;
}

const handleRemoveLiquidity = async () => {
    const to:string = useGetAccount();
    let success:boolean =false;
    if(tokenList.token1 ==  address.WETH9 || tokenList.token2 == address.WETH9){
        // const eth = tokenList.token1 == address.WETH9 ? tokenList.token1 : tokenList.token2
        const token = tokenList.token1 != address.WETH9 ? tokenList.token1 : tokenList.token2
        success = await removeLiquidityETH(
            token,
            parseUnits(String(reserve.removePair)),
            parseUnits("0"),
            parseUnits("0"),
            to,
            Date.now() + 1000 * 60 * 10
        )

    }else{
        success = await removeLiquidity(
            tokenList.token1,
            tokenList.token2,
            parseUnits(String(reserve.removePair)),
            parseUnits("0"),
            parseUnits("0"),
            to,
            Date.now() + 1000 * 60 * 10
        )
    }
    
   
    

    if(success){
        ElMessage.success("移除流动性成功");
        searchLiquidity(); 
    }else{
        ElMessage.error("移除流动性失败")
    }
}
</script>

<style  scoped>
.liquidity{
    width: 100vw;
    height: 90vh;
    
}

:deep(.el-card){
    width: 50%;
    height: auto;
    margin: 0 auto;
}
.el-button{
    margin-top: 24px;
    width: 100%;
}
.remove_box{
    display: flex;
    justify-content: space-between;
}
</style>