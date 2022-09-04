<template>
    <div class="top">
        <div class="top_tokenName" @click="handleChangeAddress">
            <img :src="token.logoURI" alt="">
            <span>{{token.symbol}}</span>
        </div>
        <div class="top_banlance">
            <span>余额：{{token.balance || 0}}</span>
        </div>
    </div>
    <div class="bot">
        <el-input v-model="token.value" placeholder="Please input" @change="handleSetValue"/>
        <el-button type="success" @click="setMaxBalnce">最大</el-button>
    </div>
</template>

<script lang="ts" setup>
import { defineComponent, ref } from 'vue'
import { IToken } from "@/interfaces/erc20/token";
import { BigNumber } from 'ethers';
import { formatUnits, parseUnits } from '@ethersproject/units';
interface IProps {
    token: IToken
}
const {token }= defineProps<IProps>()
const input = ref<BigNumber|string>(parseUnits("0"));



const emit = defineEmits([
    "handleSetValue",
    "handleChangeAddress",
    "setMaxBalnce"
])
// 
const handleChangeAddress = () => emit("handleChangeAddress")
// 设置最大值
const setMaxBalnce = () => emit("setMaxBalnce")
// 设置token传入的数量
const handleSetValue = (v:string) => {
    emit("handleSetValue",v);
}
</script>

<style lang="scss" scoped>
.top{
    width: 100%;
    height: 40px;
    display: flex;
    justify-content: center;
    align-items: center;
    .top_tokenName{
        width: 50%;
        height: 20px;
        display: flex;
        cursor: pointer;
        img{
            width: 20px;
            height: 20px;
            margin-right: 4px;
        }
        span{
            line-height: 20px;
        }
    }
    .top_banlance{
        width: 50%;
        line-height: 20px;
        text-align: right;
    }
}
.bot{
    width: 100%;
    display: flex;
    margin-bottom: 14px;
}
</style>