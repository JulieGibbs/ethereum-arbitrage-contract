require('dotenv').config();
const Aave3Flash = artifacts.require("Aave3Flash");
const dexes = require("../config/dex.json");
const network = process.env.NET_ENV.toLowerCase() || '';
module.exports = async (deployer) => {
  
    // UniswapV3 Factory addresses
    const provider = dexes[network].Aave.Provider3;
   
    await deployer.deploy(Aave3Flash, provider);
    const aave3Flash = await Aave3Flash.deployed();
    console.log("Contract is depoyed to: ", aave3Flash.address);
};
