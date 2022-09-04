
<template>
    <div class="liquidity">
        <el-card  shadow="never"> 
            <CurrencyInput 
                @handleChangeAddress="selectTokenDialog1" 
                @handleSetValue="setTokenValue1"
                @setMaxBalnce="setMaxBalnce1"
                :token="token1"
            ></CurrencyInput>
            <div class="icon">
                <el-icon size="28">
                    <Sort  @click="exchangeTokenInof"/>
                </el-icon>
            </div>
           <CurrencyInput 
                @handleChangeAddress="selectTokenDialog2" 
                @handleSetValue="setTokenValue2"
                @setMaxBalnce="setMaxBalnce2"
                :token="token2"
            ></CurrencyInput>

            <el-row :gutter="20">
                <el-col :span="12">
                    <el-button type="danger" v-if="approve.approve1 && token1.address" class="liquidty_btn" @click="token1Approve">{{token1.symbol}} approve</el-button>
                </el-col>
                <el-col :span="12">
                    <el-button type="danger"  v-if="approve.approve2 && token2.address" class="liquidty_btn" @click="token2Approve">{{token2.symbol}} approve</el-button>
                </el-col>
            </el-row>
        
             <el-button type="success" v-if="!approve.approve1 && !approve.approve2" class="liquidty_btn" @click="liquidityStart">添加流动性</el-button>
        </el-card>

        <button></button>

        <TokensDialog 
            v-if="dialogShow"
            :dialogShow="dialogShow"
            @handleDialogShow="handleDialogShow"
            @handleSelectAddress="handleSelectAddress"
        ></TokensDialog>

       
    </div>
</template>

<script lang="ts" setup>
import { Sort } from '@element-plus/icons-vue';
import CurrencyInput from "@/components/CurrencyInput/index.vue"
import TokensDialog from "@/components/TokensDialog/index.vue";
import { onMounted, reactive, ref } from 'vue';
import { formatEther, formatUnits, parseEther, parseUnits } from '@ethersproject/units';
import { IToken } from "@/interfaces/erc20/token";
import { useGetSigner, useGetAccount } from '@/hooks/useStore/useAccount';
import { useGetBalance, useERC20Allowance, useERC20Approve } from '@/hooks/useContract/useERC20';
import { ethers } from 'ethers';
import { ElBadge, ElMessage } from 'element-plus'
import { addLiquidity, addLiquidityETH} from '@/hooks/useContract/useRouter2';
const dialogShow = ref<boolean>(false);
const tokenType = ref<string>("0");
const approve = reactive({
    approve1:true,
    approve2:true,
    isApprove:false,
})  
const token1 = reactive<IToken>({
    address: "",
    value:"0",
    name:"ETH",
    symbol:"ETH",
    balance:formatEther("0"),
    logoURI:"https://p3.toutiaoimg.com/mosaic-legacy/40430000aa579cc71546~tplv-tt-large.image?x-expires=1971962868&x-signature=kWJwa69YxMlyOAaPhL%2Bm89Yn4yg%3D",
})
const token2 = reactive<IToken>({
    address: "",
    value:"0",
    name:"",
    symbol:"请选择",
    balance:formatEther("0"),
    logoURI:"https://p3.toutiaoimg.com/mosaic-legacy/40430000aa579cc71546~tplv-tt-large.image?x-expires=1971962868&x-signature=kWJwa69YxMlyOAaPhL%2Bm89Yn4yg%3D",
})

const selectTokenDialog1 = () =>{
    tokenType.value = "1";
    handleChangeAddress()
}
const selectTokenDialog2 = () =>{
    tokenType.value = "2";
    handleChangeAddress();
}
// 对换两个tokne数量
const exchangeTokenInof = () => {
    let token = reactive({
        ...token1
    });

    token1.address = token2.address;
    token1.value = token2.value;
    token1.name = token2.name;
    token1.symbol = token2.symbol;
    token1.balance = token2.balance;

    token2.address = token.address;
    token2.value = token.value;
    token2.name = token.name;
    token2.symbol = token.symbol;
    token2.balance = token.balance;
    
}
// 弹框 切换地址
const handleChangeAddress = () =>  {
    dialogShow.value = true;
};

const handleDialogShow  = (show:boolean) => {
    dialogShow.value = show;
}

// 设置token额度
const setTokenValue1 = async (v:string) => {
    const value = await useGetBalance(token1.address);
    if(Number(v) > Number(value)){
        token1.value = value
    } else {
        token1.value = v;
    }

} 
const setTokenValue2 = async (v:string) => {
    const value = await useGetBalance(token2.address);
    if(Number(v) > Number(value)){
        token2.value = value 
    } else {
        token2.value = v;
    }
} 
// 设置token最大值
const setMaxBalnce1 = async()=>{
    const signer = useGetSigner()
    if(token1.name == "ETH"){
        token1.value = formatUnits(await signer!.getBalance());
    }else{
        token1.value = formatUnits(await useGetBalance(token1.address));
    }
}
const setMaxBalnce2 = async()=>{
    const signer = useGetSigner()
    if(token2.name == "ETH"){
        token2.value = formatUnits(await signer!.getBalance());
    }else{
        token2.value = formatUnits(await useGetBalance(token2.address));
    }
}


const ethBalance =async () =>{
    const signer = await useGetSigner();
    if(signer != null){
         if(Object.keys(signer).length > 0)
        token1.balance = formatEther(await signer!.getBalance());
    }
   
}

const handleSelectAddress = async (token:IToken) => {
    if(tokenType.value === "1"){
        token1.address = token.address;
        token1.name = token.name;
        token1.symbol = token.symbol;
        token1.balance = token.balance;
        token1.logoURI = token.logoURI;
        token1.value = "0";
        const isAllowance = await useERC20Allowance(token1.address);
        if(!isAllowance) approve.approve1 = true;
        else approve.approve1 = false;
    }else if (tokenType.value === "2"){
        token2.address = token.address;
        token2.name = token.name;
        token2.symbol = token.symbol;
        token2.balance = token.balance;
        token2.logoURI = token.logoURI;
        token2.value = "0";
        const isAllowance = await useERC20Allowance(token2.address);
        if(!isAllowance) approve.approve2 = true;
        else approve.approve2 = false;
    }
   dialogShow.value = false;

}

// 授权
const token1Approve = async () => {
    if(token1.value < "1") return ElMessage.success('请输入授权额度');
    const res = await useERC20Approve(token1.address, token1.value);
    if(res) {
        approve.approve1 = false;
        ElMessage.success('授权成功！')
    }
    else {
        ElMessage.error('用户取消授权！')
    }
}

const token2Approve = async () => {
    if(token2.value < "1") return ElMessage.success('请输入授权额度');
    const res = await useERC20Approve(token2.address, token2.value);
    if(res) {
        approve.approve2 = false;
        ElMessage.success('授权成功！')
    }
    else {
        ElMessage.error('用户取消授权！')
    }
}
const liquidityStart = async () => {
    let success: boolean = false;
    const to:string = useGetAccount();
    
    if(token1.name == "ETH" || token2.name == "ETH"){
        const token = token1.name == "ETH" ? token2: token1;
        const eth = token1.name != "ETH" ? token2: token1;
        success = await addLiquidityETH(
            token.address,
            parseUnits(token.value),
            parseUnits("0"),
            parseUnits("0"),
            to,
            Date.now() + 1000 * 60 * 10,
            parseEther(eth.value),
        )
        const signer = await useGetSigner();
        if(token1.name =="ETH"){
            token1.balance = formatEther(await signer!.getBalance());
            token2.balance = formatEther(await useGetBalance(token.address));
        }else{
            token2.balance = formatEther(await signer!.getBalance());
            token1.balance = formatEther(await useGetBalance(token.address));
        }
        token1.value = "0"
        token2.value = "0"
        

    }else{
        success = await addLiquidity(
            token1.address,
            token2.address,
            parseUnits(token1.value),
            parseUnits(token2.value),
            parseUnits("0"),
            parseUnits("0"),
            to,
            Date.now() + 1000 * 60 * 10
        )
        token1.balance = formatEther(await useGetBalance(token1.address));
        token2.balance = formatEther(await useGetBalance(token2.address));
        token1.value = "0";
        token2.value = "0";
    }
    
    if(success){
        ElMessage.success('流动性添加成功');
       
        
    }else{
        ElMessage.error('流动性添加失败')
    }
}

onMounted(() => {
    ethBalance();
})
</script>

<style scoped>
.liquidity{
    width: 100vw;
    height: 90vh;
    
}
.icon{
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
}
:deep(.el-card){
    width: 50%;
    height: auto;
    margin: 0 auto;
}
.liquidty_btn{
    width:100%;
}
</style>