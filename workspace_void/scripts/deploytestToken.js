

// Use to deploy test token Contracts

const hre = require("hardhat");
require("dotenv").config();

const contractName = 'pVoid';

// Main
async function main() {
  [owner] = await ethers.getSigners();
  console.log(`Owner: ${owner.address}`);
  await hre.run("compile");
  const smartContract = await hre.ethers.getContractFactory(contractName);
  console.log('Contract Factory Built')

  const contract = await smartContract.deploy(
    ethers.BigNumber.from('1000000000000000000'), // 1e18
    '0x5e5873FadBFda8F98d7721F80A73F99b868b7388'
  );
  await contract.deployed();
  console.log(`${contractName} deployed to: ${contract.address}`); 
}


main()
