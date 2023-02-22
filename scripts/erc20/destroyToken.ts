import { formatUnits, parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";

const main = async () => {
	const DestroyToken = await ethers.getContractFactory("DestroyToken");
	const dt = await DestroyToken.deploy(10000);
	await dt.deployed();

	const signers = await ethers.getSigners();
	const signer = signers[0];
	const account1 = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";
	const dead = "0x000000000000000000000000000000000000dEaD"
	console.log("signer", formatUnits(await dt.balanceOf(signer.address)));
	const tx = await dt.transfer(account1 , parseUnits("100"));
	console.log(tx);
	
	console.log("signer", formatUnits(await dt.balanceOf(signer.address)))
	console.log("signer", formatUnits(await dt.balanceOf(account1)))
	console.log("signer", formatUnits(await dt.balanceOf(dead)))

	
}

main()
	.catch(err => {
		console.log(err);
		process.exit(1);
	})