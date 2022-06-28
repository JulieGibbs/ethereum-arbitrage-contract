require('dotenv').config();
const UniswapFlash = artifacts.require("UniswapFlash");
const dexes = require("../config/dex.json");
const tokens = require("../config/token.json");
const funcName = require("../config/routerFunc");
const network = process.env.NET_ENV.toLowerCase() || '';
module.exports = async (deployer) => {
  
    // uniswapV3 addresses
    const uniV3_router = dexes[network].UniSwapV3.Router; // '0xE592427A0AEce92De3Edee1F18E0157C05861564';
    const uniV3_factory = dexes[network].UniSwapV3.Factory;// '0x1F98431c8aD98523631AE4a59f267346ea31F984';
    // uniswapV2 addresses
    const uniV2_router = dexes[network].UniSwapV2.Router; // '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
    // sushiswap address
    const sushi_router = dexes[network].SushiSwap.Router; // '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506';
    // shibaswap address
    let shiba_router, defi_router;
    if (network == 'mainnet') {
        shiba_router = dexes[network].ShibaSwap.Router; // '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506';
        defi_router = dexes[network].DefiSwap.Router; // '0xc35DADB65012eC5796536bD9864eD8773aBc74C4';
    }
    // token addresses
    const WETH = tokens[network].WETH; // '0xd0A1E359811322d97991E03f863a0C30C2cF029C';
    const DAI = tokens[network].DAI; // '0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa';
  
    await deployer.deploy(UniswapFlash, uniV3_factory, WETH);
    const uniswapFlash = await UniswapFlash.deployed();
    // console.log("Contract address ---> ", uniswapFlash.address);
    // set pool fee
    await uniswapFlash.setFlashPoolFee(500);
    // set swap router infos for dexes
    console.log("adding router infos...");
    const swapV3RouterInfo = {
        router: uniV3_router,
        poolFee: 3000,
        deadline: 300,
        series: 1
    };
    await uniswapFlash.addRouter(dexes[network].UniSwapV3.id, swapV3RouterInfo);

    const swapV2RouterInfo = {
        router: uniV2_router,
        poolFee: 3000,
        deadline: 300,
        series: 2
    };
    await uniswapFlash.addRouter(dexes[network].UniSwapV2.id, swapV2RouterInfo);

    const sushiRouterInfo = {
        router: sushi_router,
        poolFee: 3000,
        deadline: 300,
        series: 2
    };
    await uniswapFlash.addRouter(dexes[network].SushiSwap.id, sushiRouterInfo);

    if (network == 'mainnet') {
        const shibaRouterInfo = {
            router: shiba_router,
            poolFee: 3000,
            deadline: 300,
            series: 2
        };
        await uniswapFlash.addRouter(dexes[network].ShibaSwap.id, shibaRouterInfo);

        const defiRouterInfo = {
            router: defi_router,
            poolFee: 3000,
            deadline: 300,
            series: 2
        };
        await uniswapFlash.addRouter(dexes[network].DefiSwap.id, defiRouterInfo);
    }
    // const info = await uniswapFlash.swapRouterInfos(1);
    // console.log("UniswapV3Router ---> ", info.router);
    console.log("finished adding router infos!");
};
