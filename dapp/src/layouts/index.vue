<template>
    <div class="common-layout">
        <el-container>
            <el-alert title="警告：本项目仅供学习交流研究技术使用，严禁用于商业用途！！！" type="warning" center show-icon />
            <el-header class="header">
               <div class="menu_box">
                    <el-menu
                        :default-active="active"
                        class="el-menu"
                        mode="horizontal"
                        :ellipsis="false"
                        @select="handleSelect"
                        router
                    >
                        <el-menu-item index="/liquidity">添加流动性</el-menu-item>
                        <el-menu-item index="/removeLiquidity">移除流动性</el-menu-item>
                        <el-menu-item index="/swap">swap交换</el-menu-item>
                        <el-menu-item index="/t">t</el-menu-item>
                    </el-menu>
               </div>
               <div class="metamask">
                    <div v-if="info.account">{{info.account}}</div>
                    <div v-else>
                        <el-button type="warning" plain @click="connectMetamask">连接钱包</el-button>
                    </div>
               </div>
            </el-header>
            <el-main>
                <RouterView></RouterView>
            </el-main>
        </el-container>
    </div>
</template>
<script  lang="ts" setup>
import { onMounted, reactive, ref } from 'vue'
import { useRoute } from 'vue-router';
import { useConnectMetamask } from "@/hooks/uesMetamask/index";
import { useGetAccount , useGetSigner} from "@/hooks/useStore/useAccount";
import type { Signer } from "ethers";
const route = useRoute();


interface IInfo{
    account: string,
    signer: Signer | null
}


const info = reactive<IInfo>({
    account:"",
    signer: null
})
const active = ref(route.path);
const handleSelect = (key: string, keyPath: string[]) => {
  active.value = key;
}
// 连接钱包
const connectMetamask = async() => {
   await useConnectMetamask()
   const account = useGetAccount();
   console.log(account);
   
   if(account){
        let l = account.slice(0, 4);
        let r = account.slice(account.length - 5, account.length - 1);
        info.account = `${l}...${r}`;
   }
   
}

connectMetamask()
</script>

<style lang="scss" scoped>
:deep(.el-menu--horizontal){
    border-bottom: none;
}
.header{
    display: flex;
    justify-content: center;
    .menu_box{
        width: 80%;
    }
    .metamask{
        height: 59px;
        line-height: 59px;
        width: 20%;
        text-align: right;
    }
}

</style>