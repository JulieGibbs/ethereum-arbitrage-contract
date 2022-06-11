require('dotenv').config();
const Web3 = require('web3');
const uniswapFlashAbi = require("./build/contracts/UniswapFlash.json");
const IERC20 = require('@uniswap/v2-periphery/build/IERC20.json');
const INFURA_API_KEY = process.env.INFURA_API_KEY || '';
const PRIVATE_KEY = process.env.PRIVATE_KEY || '';
const web3 = new Web3(`https://kovan.infura.io/v3/${INFURA_API_KEY}`);
const wallet = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY).address;

const main = async () => {

    // uniswapV3 addresses
    const routerV3_addr = '0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45';
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

    console.log("init UniswapFlash instance....");
    // init UniswapFlash instance
    const uniswapFlash_addr = "0x5635eF7c3a1263EF3669Df02251d843FD2026383";
    const uniswapFlash = new web3.eth.Contract(uniswapFlashAbi.abi, uniswapFlash_addr);
    const ethBalance = await web3.eth.getBalance(wallet);
    console.log(uniswapFlash_addr);
    console.log("Eth Balance ---> ", web3.utils.fromWei(ethBalance));
   
    // check it out here: https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2#code
    const WETH_contract = new web3.eth.Contract(IERC20.abi, WETH_addr);
   
    const DAI_contract = new web3.eth.Contract(IERC20.abi, DAI_addr)
    const balance_before = web3.utils.fromWei(await DAI_contract.methods.balanceOf(wallet).call());
    console.log("DAI balance ---> ", balance_before);
  
    console.log("start flash swap");
    // FLASH SWAP 
    const loanAssets = [DAI_addr, WETH_addr];
    const loanAmounts = [web3.utils.toWei('2000'), web3.utils.toWei('0')];
    const tradeAssets = [WETH_addr, DAI_addr]
    const tradeDexes = [3, 2];
    const init = uniswapFlash.methods.initUniFlashSwap(
       loanAssets,
       loanAmounts,
       tradeAssets,
       tradeDexes
    );
    const tx = {
        from: wallet,
        to: uniswapFlash.options.address,
        gas: 1000000,
        data: init.encodeABI()
    };
    const signedTx = await web3.eth.accounts.signTransaction(tx, process.env.PRIVATE_KEY);

    try{
        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        console.log('Transaction hash:', receipt.transactionHash);
    }
    catch(err) {
        console.log(err);
    }
 
    const balance_after = web3.utils.fromWei(await DAI_contract.methods.balanceOf(wallet).call())
    console.log('Total Flash Change in Balance: %s DAI', Number(balance_after) - Number(balance_before));
}

main();