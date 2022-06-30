require('dotenv').config();
const UniswapFlash = artifacts.require("UniswapFlash1Inch");
const dexes = require("../config/dex.json");
const tokens = require("../config/token.json");
const network = process.env.NET_ENV.toLowerCase() || '';
module.exports = async (deployer) => {
  
    // UniswapV3 Factory addresses
    const uniV3_factory = dexes[network].UniSwapV3.Factory;// '0x1F98431c8aD98523631AE4a59f267346ea31F984';
   
    // token addresses
    const WETH = tokens[network].WETH; // '0xd0A1E359811322d97991E03f863a0C30C2cF029C';
    const DAI = tokens[network].DAI; // '0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa';
  
    await deployer.deploy(UniswapFlash, uniV3_factory, WETH);
    const uniswapFlash = await UniswapFlash.deployed();
    // console.log("Contract address ---> ", uniswapFlash.address);
    // set pool fee
    await uniswapFlash.setFlashPoolFee(500);
   
};
