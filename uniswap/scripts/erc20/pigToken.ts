import { formatUnits, parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat"
import { account1, account2, account3, account4, DEAD } from "../../utils/constant";

const main = async ()=>{
    const PigToken = await ethers.getContractFactory("PigToken");
    const pig = await PigToken.deploy();
    await pig.deployed();

    console.log("totalSupply", await pig.totalSupply());
    console.log("account1", await pig.balanceOf(account1));
    await pig.transfer(account2, parseUnits("10"));
    await pig.transfer(account3, parseUnits("100"));

    pig.transfer(account4, parseUnits("100"));

    console.log("account1", await pig.balanceOf(account1));
    console.log("account2", await pig.balanceOf(account2));
    console.log("account3", await pig.balanceOf(account3));


}

main()
    .catch(err =>{
        console.log(err);
        process.exit(1);
    })