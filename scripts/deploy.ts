const fs = require('fs');
import { ethers } from "hardhat";
import { NFTMarketplace__factory } from "../typechain-types";

async function main() {

  const signers = await ethers.getSigners();
  const marketplace = await new NFTMarketplace__factory(signers[0]).deploy()

  await marketplace.deployed();
  
  fs.writeFileSync('./config.js', `
  export const marketplaceAddress = "${marketplace.address}"
  `)
  console.log("Marketplace deployed to:", marketplace.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
