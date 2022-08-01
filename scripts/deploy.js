const { ethers } = require("hardhat");

async function main() {
  /*
  A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
  so whitelistContract here is a factory for instances of our Whitelist contract.
  */
  const docItContract = await ethers.getContractFactory("DocIt");

  // here we deploy the contract
  const deployedDocItContract = await docItContract.deploy();
  // 10 is the Maximum number of whitelisted addresses allowed
  
  // Wait for it to finish deploying
  await deployedDocItContract.deployed();

  // print the address of the deployed contract
  console.log(
    "DocIt Contract Address:",
    deployedDocItContract.address
  );
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });