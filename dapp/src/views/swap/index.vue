<template>
    <div class="swap">
        <el-card  shadow="never">
            <CurrencyInput 
                :token="token1"
                @handleChangeAddress="selectTokenDialog1" 
                @handleSetValue="changeToken1"
                @setMaxBalnce="setMaxToken1"
            ></CurrencyInput>
            <div class="icon">
                <el-icon size="28">
                    <Sort  @click="exchangeTokenInof"/>
                </el-icon>
            </div>
            <CurrencyInput 
                :token="token2"
                @handleChangeAddress="selectTokenDialog2" 
                @handleSetValue="changeToken2"
                @setMaxBalnce="setMaxToken2"
            ></CurrencyInput>
            <el-row>
                <el-col :span="12">
                    <span>滑点</span>
                    <el-input v-model="swap.slip" placeholder="Please input" />
                </el-col>
                <el-col :span="12">
                    <span>交易时间：</span>
                    <el-input v-model="swap.time" placeholder="Please input" />
                </el-col>
            </el-row>
            <div>
                <span>{{swap.symbol}}最少可以兑换：{{swap.min}}</span>
            </div>
            <div class="btn">
                <el-button v-if="!token1.isApprove" type="primary" @click="swapArrpveo">授权</el-button>
                <el-button v-else type="success" @click="swapExchange">交换</el-button>
            </div>
        </el-card>

        <TokensDialog 
            v-if="dialogShow"
            :dialogShow="dialogShow"
            @handleDialogShow="handleDialogShow"
            @handleSelectAddress="handleSelectAddress"
        ></TokensDialog>
    </div>
</template>

<script lang="ts" setup>
import { useERC20Allowance, useGetBalance, useERC20Approve } from '@/hooks/useContract/useERC20';
import { reactive, ref } from 'vue';
import { Sort } from '@element-plus/icons-vue';
import { formatUnits, parseUnits } from "ethers/lib/utils";
import {ethers} from "ethers";
import CurrencyInput from "@/components/CurrencyInput/index.vue"
import TokensDialog from "@/components/TokensDialog/index.vue";
import { IToken } from "@/interfaces/erc20/token";
import { getAmountsOut, getAmountsIn,swapExactTokensForTokens,swapTokensForExactTokens,swapExactETHForTokens,swapTokensForExactETH,swapExactTokensForETH,swapETHForExactTokens } from "@/hooks/useContract/useRouter2"
import { ElMessage } from "element-plus";
import address from "../../../../uniswap/abi/uniswapV2.json";
import { useGetAccount } from "@/hooks/useStore/useAccount"


const dialogShow = ref<boolean>(false);
const tokenType = ref<string>("0");
const swap = reactive({
    slip:0.1,
    time:10,
    symbol:"",
    min:"0",
    exactToken:""
})
const token1 = reactive({
    address:"",
    value:formatUnits("0"),
    symbol:"请选择代币",
    balance:formatUnits("0"),
    isApprove:false,
    logoURI:"https://p3.toutiaoimg.com/mosaic-legacy/40430000aa579cc71546~tplv-tt-large.image?x-expires=1971962868&x-signature=kWJwa69YxMlyOAaPhL%2Bm89Yn4yg%3D",
})
const token2 = reactive({
    address:"",
    value:formatUnits("0"),
    symbol:"请选择代币",
    balance:formatUnits("0"),
    ifApprove:false,
    logoURI:"https://p3.toutiaoimg.com/mosaic-legacy/40430000aa579cc71546~tplv-tt-large.image?x-expires=1971962868&x-signature=kWJwa69YxMlyOAaPhL%2Bm89Yn4yg%3D",
})
// 交换两个token数据 => 切换位置
const exchangeTokenInof = async() => {
    let token = reactive({
        ...token1
    });
    token1.address = token2.address;
    token1.value = token2.value;
    token1.symbol = token2.symbol;
    token1.balance = token2.balance;
    token1.logoURI = token2.logoURI;

    token2.address = token.address;
    token2.value = token.value;
    token2.symbol = token.symbol;
    token2.balance = token.balance;
    token2.logoURI = token.logoURI;

    // <!-- 交换token后检查token1是否授权 -->
    const isAllowance = await useERC20Allowance(token1.address);
    if(isAllowance) token1.isApprove = true;
    else token1.isApprove = false;
}
// 授权
const swapArrpveo = async ()=> {
   token1.isApprove = await useERC20Approve(token1.address);
}


const selectTokenDialog1 = () =>{
    tokenType.value = "1";
    handleChangeAddress()
}
const selectTokenDialog2 = () =>{
    tokenType.value = "2";
    handleChangeAddress();
}
const handleChangeAddress = () =>  {
    dialogShow.value = true;
};
const handleDialogShow  = (show:boolean) => {
    dialogShow.value = show;
}
const handleSelectAddress = async (token:any) => {
    if(tokenType.value === "1"){
        token1.address = token.address;
        token1.symbol = token.symbol;
        token1.balance = token.balance;
        token1.logoURI = token.logoURI;
        token1.value = "0";
        const isAllowance = await useERC20Allowance(token1.address);
        if(isAllowance) token1.isApprove = true;
        else token1.isApprove = false;
    }else if (tokenType.value === "2"){
        token2.address = token.address;
        token2.symbol = token.symbol;
        token2.balance = token.balance;
        token2.logoURI = token.logoURI;
        token2.value = "0";
        // const isAllowance = await useERC20Allowance(token2.address);
        // if(!isAllowance) approve.approve2 = true;
        // else approve.approve2 = false;
    }
   dialogShow.value = false;

}
const setMaxToken1 = async () => {
    token1.value = formatUnits(await useGetBalance(token1.address));
    changeToken1();
}
const setMaxToken2 = async () => {
    token2.value = formatUnits(await useGetBalance(token2.address));
    changeToken2();
}
const changeToken1 = async () => {
    if(token2.value == "0.0") return ElMessage.error("请选择token2");;

    const amountOut = await getAmountsOut(
        parseUnits(String(token1.value)),
        [token1.address, token2.address]);
    if(formatUnits(amountOut) == "0.0") return ElMessage.error("没有对应交易对");
    token2.value = formatUnits(amountOut);
    swap.min = formatUnits(amountOut.mul(10000 - (100 * swap.slip)).div(10000));
    swap.symbol = token2.symbol;
    swap.exactToken = token1.address;
}
const changeToken2 = async () => {
    if(token1.value == "0.0") return ElMessage.error("请选择token1");;
    const amountIn = await getAmountsIn(
        parseUnits(String(token2.value)),
        [token1.address, token2.address]
    )
    if(formatUnits(amountIn) == "0.0") return ElMessage.error("没有对应交易对");
    token1.value = formatUnits(amountIn);
    swap.min = formatUnits(amountIn.mul(10000 + (100 * swap.slip)).div(10000));
    swap.symbol = token1.symbol;
    swap.exactToken = token2.address;
}

// swap 交换
const swapExchange = async () => {
    if(
        !token1.address || 
        !token2.address || 
        (token1.value == "0.0" || token1.value == "0") ||
        (token2.value == "0.0" || token2.value == "0")
    ) return ElMessage.error("请输入要兑换的数量！");

    // const token1Address = token1.address;
    // const token2Address = token2.address;
    // const token1Amount = token1.value;
    // const token2Amount = token2.value;
    const to = useGetAccount();
    const deadline = swap.time;
    const slip = swap.slip;
    const path = [token1.address, token2.address]
    if(token1.address == address.WETH9 || token2.address == address.WETH9){
        if(token1.address == address.WETH9){
            // eth <-> token
            
            if(token1.address == swap.exactToken){
                const amountOut = await getAmountsOut(parseUnits(token1.value), path);
                const amountOutMin = amountOut.mul(10000 - (100 * slip)).div(10000);
                const result = await swapExactETHForTokens(
                    amountOutMin,
                    parseUnits(token1.value),
                    path,
                    to,
                    deadline
                )
                if(result) tokenBlance();
            }else{
                console.log("swapETHForExactTokens")
                const amountIn = await getAmountsIn(parseUnits(token2.value), path);
                const amountInMax = amountIn.mul(10000 + (100 * slip)).div(10000);
                const result = await swapETHForExactTokens(
                    parseUnits(token2.value),
                    amountInMax,
                    path,
                    to,
                    deadline
                )
                if(result) tokenBlance();
            }
        }else{
            // token <-> eth
            if(token2.address == swap.exactToken){
                console.log("swapTokensForExactETH")
                const amountIn = await getAmountsIn(parseUnits(token2.value), path);
                const amountInMax = amountIn.mul(10000 + (100 * slip)).div(10000);
                const result = await swapTokensForExactETH(
                    parseUnits(token2.value),
                    amountInMax,
                    path,
                    to,
                    deadline
                )
                if(result) tokenBlance();
            }else{
                const amountOut = await getAmountsOut(parseUnits(token1.value), path);
                const amountOutMin = amountOut.mul(10000 - (100 * slip)).div(10000);
                const result = await swapExactTokensForETH(
                    parseUnits(token1.value),
                    amountOutMin,
                    path,
                    to,
                    deadline
                )
                if(result) tokenBlance();
            }
        }
    }else{
        // const path = [token1.address, token2.address]
        // token <-> token
        if(token1.address == swap.exactToken){
            const amountOut = await getAmountsOut(parseUnits(token1.value), path);
            const amountOutMin = amountOut.mul(10000 - (100 * slip)).div(10000);
            const result = await swapExactTokensForTokens(
                parseUnits(token1.value),
                amountOutMin,
                path,
                to,
                deadline
            )
            if(result) tokenBlance();
        }else{
            const amountIn = await getAmountsIn(parseUnits(token2.value), path);
            const amountInMax = amountIn.mul(10000 + (100 * slip)).div(10000);
            console.log(amountIn.toString())
            console.log(amountInMax.toString())
            const result = await swapTokensForExactTokens(
                parseUnits(token2.value),
                amountInMax,
                path,
                to,
                deadline
            );
            if(result) tokenBlance();
        }
    }
}

const tokenBlance = async ()=>{
    token1.balance = formatUnits(await useGetBalance(token1.address));
    token1.value = formatUnits("0");
    token2.balance = formatUnits(await useGetBalance(token2.address));
    token2.value = formatUnits("0");
}
</script>

<style scoped>

.swap{
    width: 100vw;
    height: 90vh;
    
}
:deep(.el-card){
    width: 500px;
    height: auto;
    margin: 0 auto;
}
.el-button{
    width:100%;
}
.icon{
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
}
.btn{
    margin-top:20px;
}
</style>