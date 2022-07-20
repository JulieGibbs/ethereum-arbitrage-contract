require('dotenv').config();
const Uniswap2Flash = artifacts.require("Uniswap2Flash");
const dexes = require("../config/dex.json");
const tokens = require("../config/token.json");
const network = process.env.NET_ENV.toLowerCase() || '';
module.exports = async (deployer) => {
  
    // UniswapV3 Factory addresses
    const uniV2_factory = dexes[network].UniSwapV2.Factory;// '0x1F98431c8aD98523631AE4a59f267346ea31F984';
   
    // token addresses
    const WETH = tokens[network].WETH; // '0xd0A1E359811322d97991E03f863a0C30C2cF029C';
    await deployer.deploy(Uniswap2Flash, uniV2_factory, WETH);
    const uniswap2Flash = await Uniswap2Flash.deployed();
    console.log("Contract is depoyed to: ", uniswap2Flash.address);
};
