import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity:{
    compilers:[
      {version:"0.5.0"},
      {version:"0.5.16"},
    ]
  }
};

export default config;
