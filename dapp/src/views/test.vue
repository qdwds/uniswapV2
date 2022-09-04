<template>
  <div>
    <button @click="allowance"> allowance</button>
    <button v-if="isApp" @click="approve">approve</button>
    <button v-else>transform</button>
  </div>
</template>

<script setup>
import { ethers } from 'ethers';
import { ref } from 'vue';
import address from "../../../uniswap/abi/uniswapV2.json";
import { info, abi } from "../../../uniswap/abi/Token0.json";
import { formatUnits } from '@ethersproject/units';
const isApp = ref(!false)
let token;
let account;
// metamask
const connect = async () => {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  account = await provider.send("eth_requestAccounts", [0]);
  const signer = await provider.getSigner();
  token = new ethers.Contract(info.address, abi, signer);
}
connect()
const approve = async () => {
  const tx = await token.approve("0x40A62fB8Cf1085ef7C06313A77874311363a9a9d", ethers.constants.MaxUint256);
  await tx.wait();
  const b = await allowance();
  console.log(b);
  isApp.value = b;
}

const allowance = async () => {
  const val = await token.allowance(account[0], "0x40A62fB8Cf1085ef7C06313A77874311363a9a9d");
  return formatUnits(val) == "0.0"
}
</script>



