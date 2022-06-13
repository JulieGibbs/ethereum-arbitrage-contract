require('dotenv').config();
const Web3 = require('web3');
const uniswapFlashAbi = require("./build/contracts/UniswapFlash.json");
const IERC20 = require('@uniswap/v2-periphery/build/IERC20.json');
const INFURA_API_KEY = process.env.INFURA_API_KEY || '';
const PRIVATE_KEY = process.env.PRIVATE_KEY || '';
const network = 'kovan';
const web3 = new Web3(`https://${network}.infura.io/v3/${INFURA_API_KEY}`);
const wallet = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY).address;

const main = async () => {

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