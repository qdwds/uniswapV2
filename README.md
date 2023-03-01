# uniswapV2完整系列
前段时间整理学习的`uniswapV2`版本，整理了一套完整的包括 [一条命令快速部署uniswapV2到任何网络](https://www.bilibili.com/video/BV1GS4y1x7DH/?spm_id_from=333.999.0.0)、[uniswapV2源码分析](https://space.bilibili.com/449244768/channel/seriesdetail?sid=2602082)、[uniswapV2模拟调用](https://github.com/qdwds/vue3_uniswapV2_dex/tree/master/uniswap/src)、[uniswapV2前端实现](https://space.bilibili.com/449244768/channel/seriesdetail?sid=2542511) 点击可以跳转到对应的视频文件中。

## 启动UniswapV2
### 下载依赖
```js
yarn | npm i 
```
### 创建.env文件
```js
//  uniswapV2/uniswap/.env
# 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
HARDHAT_NET = "http://127.0.0.1:8545/"
HARDHAT_PRIVATE_KEY = 
# 
GANACHE_PRIVATE_KEY = 
# account
ACCOUNT_PRIVATE_KEY = 
# key
INFURA_KEY = 
```
### 启动节点
```
npx node
```
### 快速部署uniswapV2
```
cd ./uniswap 
npx hardhat run scripts/uniswap.deploy.ts
```

## 启动前端项目
### 下载依赖
```
cd ./dapp
yarn | npm i
```
### 启动项目
```
yarn dev
```

笔记文档：[区块链笔记](https://www.yuque.com/qdwds)\
哔哩哔哩：[视频合集](https://space.bilibili.com/449244768?spm_id_from=333.1007.0.0)\
支持一下：0x0168996F9355fDf6Ba4b7E25Cc4f16Fd6AB9361c