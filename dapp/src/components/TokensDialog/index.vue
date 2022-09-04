<template>
	<el-dialog v-model="dialogShow" title="请选择代币" width="500px" center @close="handleDialogClose">
		<el-input v-model="token" clearable placeholder="请输入地址或者名字" @change="changeAddress" class="inp"/>
		<div class="box_card" v-for="token in  tokenList.tokens" @click="handleSelectAddress(token)">
			<div class="card_box">
				<img class="box_img" :src="token.logoURI" style="visibility:token.logoURI? 'inherit': 'hidden' ;" alt="">
				<div class="box_name">
					<span>{{token.symbol}}</span>
				</div>
			</div>
			<div class="card_balan">
				<span>{{token.balance}}</span>
			</div>
		</div>
	</el-dialog>
</template>
<script lang="ts" setup>
import { useConnectMetamask } from "@/hooks/uesMetamask";
import { useGetAccount, useGetSigner } from "@/hooks/useStore/useAccount";
import { formatEther, formatUnits } from "@ethersproject/units";
import { onMounted, reactive, ref } from "vue";
const token = ref<string>("");
import { useGetERC20Info, useGetBalance } from "@/hooks/useContract/useERC20";
import { tokens } from "@/assets/json/tokens";


const tokenList = reactive({
	tokens
})
const emit = defineEmits([
	"handleDialogShow",
	"handleSelectAddress"
])

const getBalanceOf = async (list:Array<any>) => {
	const signer = await useGetSigner();
	// if(Object.keys(signer).length < 1) useConnectMetamask();
	const account = await useGetAccount();
	for (let i = 0; i < list.length; i++) {
		// if(list[i].name == "ETH"){
		// 	tokenList.tokens[i].balance = formatEther(await signer!.getBalance());
		// }else{
			const balance = await useGetBalance(list[i].address, account, signer);
			tokenList.tokens[i].balance = formatUnits(balance);
		// }
		
	
	}
}
// 根据地址或者名字查找对应token
const changeAddress = async (t: string) => {
	const isAdd: boolean = /^0x\S+/.test(t);
	if (isAdd) {
		const signer = useGetSigner();
		if(signer){
			const info = await useGetERC20Info(t, signer);
			tokenList.tokens = [{...info}]
		}else{
			useConnectMetamask();
		}
	} else {
		if(t == ""){
			tokenList.tokens = tokens;
		}else{
			const token:any = tokenList.tokens.find((l:any) => l.name == t || l.symbol == t);
			tokenList.tokens = Array(token);
		}
		
	}
}

onMounted(()=>{
	getBalanceOf(tokenList.tokens);
})
defineProps({
	dialogShow: {
		type: Boolean
	}
})


const handleDialogShow = () => emit("handleDialogShow", false);
const handleSelectAddress = (token:any) => emit("handleSelectAddress",token);
const handleDialogClose = () => emit("handleDialogShow", false);
</script>
<style lang="scss" scoped>
.dialog-footer button:first-child {
	margin-right: 10px;
}
.inp{
	margin-bottom: 24px;
}
.box_card {
	width: 100%;
	height: 50px;
	display: flex;
	justify-content: space-between;
	height: 40px;
	line-height: 40px;
	.card_box{
		width: 50%;
		display: flex;
		align-items: center;
		.box_img{
			width: 20px;
			height: 20px;
			margin-right: 6px;
		}
	}
	.card_balan{
		width: auto;
		text-align: right;
	}
}
.box_card:hover{
	background: #cacaca;
}
</style>
