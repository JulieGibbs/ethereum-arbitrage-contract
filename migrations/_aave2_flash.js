require('dotenv').config();
const Aave2Flash = artifacts.require("Aave2Flash");
const dexes = require("../config/dex.json");
const network = process.env.NET_ENV.toLowerCase() || '';
module.exports = async (deployer) => {
  
    // UniswapV3 Factory addresses
    const provider = dexes[network].AaveV2.Provider;
   
    await deployer.deploy(Aave2Flash, provider);
    const aave2Flash = await Aave2Flash.deployed();
    console.log("Contract is depoyed to: ", aave2Flash.address);
};
