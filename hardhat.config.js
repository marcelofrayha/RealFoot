require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@chainlink/hardhat-chainlink");


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {},
    goerli: {
      url: process.env.GOERLI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY]
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.17",
      },
      {
        version: "0.6.7",
      }, 
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  tasks: {
    deploy: {
      contract: async function () {
        const { ethers, deployments } = require("hardhat");

        const [deployer] = await ethers.getSigners();

        console.log("Deploying contract with the account:", deployer.address);

        const RealFoot = await deployments.deploy("RealFoot", {
          from: deployer.address,
          args: [],
          log: true,
        });

        console.log("Contract deployed to address:", RealFoot.address);
      },
    },
  },
};
