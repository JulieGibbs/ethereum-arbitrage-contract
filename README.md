# Flashloan Trading Smart Contract

## Usage

1. Rename `.env.example` file to `.env` inside the contracts directory
 
2. Config `.env` file. 

    Here, you need three things. 
    * Insert your INFURA Project ID. You can create a infura Project ID [here](https://infura.io). 
    * Insert your MetaMask (Kovan Testnet) 32byte wallet private key.
    * Insert your [etherscan](https://etherscan.io) account's API KEY.

3. Install yarn modules. Open terminal window and run:

```
npm install
npm i @truffle/hdwallet-provider@next
yarn install
```

4. Deploy Smart Contract on Kovan Testnet
```
yarn build-deploy-kovan
```

```
yarn verify UniswapFlash1Inch --network  kovan
```
5. Deploy Smart Contract on Mainnet Fork
```
yarn add global ganache-cli
```
```
yarn mainnet-fork https://mainnet.infura.io/v3/<YOUR_INFURA_API_KEY>
```
Note: Don't close current terminal window and start with new terminal window.
```
yarn build-deploy
```

## Modifying UniswapFlash1Inch.sol


## Integrating 1Inch V4 Router 
## Kovan Testnet Past Examples
* Ensure to have your .env configuration setup with your etherscan API key, and your INFURA API keys as well. 

* Successful profiting $99.9995 DAI 
Smart Contract Transaction: https://kovan.etherscan.io/tx/0xf1c4037914460161b3f63779707c1f42fd7c6f6726b4193a38666dc87348ec4f



# Developer Instruction Manual (ETH MAINNET): 

## COMING SOON (THINGS REQUIRED)
* AAVE, EQUALIZER, DODO Flashloan contracts activated for Mainnet
* bot.js needs to be modified to lookup mainnet opportunities
