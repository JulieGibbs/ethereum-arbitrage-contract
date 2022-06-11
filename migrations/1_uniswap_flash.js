const UniswapFlash = artifacts.require("UniswapFlash");
module.exports = async (deployer) => {
    const routerV3_addr = '0xE592427A0AEce92De3Edee1F18E0157C05861564';
    const factoryV3_addr = '0x1F98431c8aD98523631AE4a59f267346ea31F984';
    // uniswapV2 addresses
    const routerV2_addr = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
    const factoryV2_addr = '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f';
    // sushiswap address
    const sushi_router_addr = '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506';
    const sushi_factory_addr = '0xc35DADB65012eC5796536bD9864eD8773aBc74C4';
    // token addresses
    const WETH_addr = '0xd0A1E359811322d97991E03f863a0C30C2cF029C';
    const DAI_addr = '0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa';
  
    await deployer.deploy(UniswapFlash, factoryV3_addr, WETH_addr);
    const uniswapFlash = await UniswapFlash.deployed();
    // console.log("Contract address ---> ", uniswapFlash.address);
    // set pool fee
    await uniswapFlash.setFlashPoolFee(500);
    // set swap router infos for dexes
    console.log("seting router infos...");
    const swapV3RouterInfo = {
        router: routerV3_addr,
        factory: factoryV3_addr,
        poolFee: 3000,
        deadline: 300,
    };
    await uniswapFlash.setSwapRouterInfo(1, swapV3RouterInfo);
    const swapV2RouterInfo = {
        router: routerV2_addr,
        factory: factoryV2_addr,
        poolFee: 3000,
        deadline: 300,
    };
    await uniswapFlash.setSwapRouterInfo(2, swapV2RouterInfo);
    const sushiRouterInfo = {
        router: sushi_router_addr,
        factory: sushi_factory_addr,
        poolFee: 3000,
        deadline: 300,
    };
    await uniswapFlash.setSwapRouterInfo(3, sushiRouterInfo);

    // const info = await uniswapFlash.swapRouterInfos(1);
    // console.log("UniswapV3Router ---> ", info.router);
    console.log("finished setup router infos!");
};
