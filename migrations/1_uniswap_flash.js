const UniswapFlash = artifacts.require("UniswapFlash");
const dexes = require("../config/dex.json");
const tokens = require("../config/token.json");
const network = 'kovan';
module.exports = async (deployer) => {
    // uniswapV3 addresses
    const uniV3_router = dexes[network].UniSwapV3.Router; // '0xE592427A0AEce92De3Edee1F18E0157C05861564';
    const uniV3_factory = dexes[network].UniSwapV3.Factory; // '0x1F98431c8aD98523631AE4a59f267346ea31F984';
    // uniswapV2 addresses
    const uniV2_router = dexes[network].UniSwapV2.Router; // '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
    const uniV2_factory = dexes[network].UniSwapV2.Factory; // '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f';
    // sushiswap address
    const sushiV2_router = dexes[network].SushiSwap.Router; // '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506';
    const sushiV2_factory = dexes[network].SushiSwap.Factory; // '0xc35DADB65012eC5796536bD9864eD8773aBc74C4';
    // token addresses
    const WETH = tokens[network].WETH; // '0xd0A1E359811322d97991E03f863a0C30C2cF029C';
    const DAI = tokens[network].DAI; // '0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa';
  
    await deployer.deploy(UniswapFlash, uniV3_factory, WETH);
    const uniswapFlash = await UniswapFlash.deployed();
    // console.log("Contract address ---> ", uniswapFlash.address);
    // set pool fee
    await uniswapFlash.setFlashPoolFee(500);
    // set swap router infos for dexes
    console.log("seting router infos...");
    const uniV3RouterInfo = {
        router: uniV3_router,
        factory: uniV3_factory,
        poolFee: 3000,
        deadline: 300,
        series: 0
    };
    await uniswapFlash.setSwapRouterInfo(1, uniV3RouterInfo);
    const uniV2RouterInfo = {
        router: uniV2_router,
        factory: uniV2_factory,
        poolFee: 3000,
        deadline: 300,
        series: 1
    };
    await uniswapFlash.setSwapRouterInfo(2, uniV2RouterInfo);
    const sushiRouterInfo = {
        router: sushiV2_router,
        factory: sushiV2_factory,
        poolFee: 3000,
        deadline: 300,
        series: 1
    };
    await uniswapFlash.setSwapRouterInfo(3, sushiRouterInfo);
    console.log("finished setup router infos!");
};
