# Trading Bot Demo

## Technology Stack & Tools

- Solidity (Writing Smart Contract)
- Javascript (React & Testing)
- [Web3](https://web3js.readthedocs.io/en/v1.5.2/) (Blockchain Interaction)
- [Truffle](https://trufflesuite.com/docs/truffle/) (Development Framework)
- [Ganache-CLI](https://github.com/trufflesuite/ganache) (For Local Blockchain)
- [Infura](https://www.infura.com/) (For forking the Ethereum mainnet)

## Requirements For Initial Setup
- Install [NodeJS](https://nodejs.org/en/), I recommend using node version 16.14.2 to avoid any potential dependency issues
- Install [Truffle](https://github.com/trufflesuite/truffle), In your terminal, you can check to see if you have truffle by running `truffle --version`. To install truffle run `npm i -g truffle`.
- Install [Ganache-CLI](https://github.com/trufflesuite/ganache). To see if you have ganache-cli installed, in your command line type `ganache --version`. To install, in your command line type `npm install ganache --global`

## Setting Up
### 1. Clone/Download the Repository

### 2. Install Dependencies:
`$ npm install`

### 3. Start Ganache CLI
In your terminal run:

```
ganache -f -m <Your-Mnemonic-Phrase> -u 0xdEAD000000000000000042069420694206942069 -p 7545
```

Alternatively you can start ganache with your own RPC URL such as the one provided from Alchemy:

```
ganache -f wss://eth-mainnet.alchemyapi.io/v2/<Your-App-Key> -m <Your-Mnemonic-Phrase> -u 0xdEAD000000000000000042069420694206942069 -p 7545
```

For the -m parameter you can get away by using a 1 word mnemonic, remember these are only development accounts and are not to be used in production.

For the -u parameter in the command, we are unlocking an address with SHIB tokens to manipulate price of SHIB/WETH in our scripts. If you 
plan to use a different ERC20 token, you'll need to unlock an account holding that specific ERC20 token.

Once you've started ganache-cli, copy the address of the first account as you'll need to paste it in your .env file in the next step.

### 4. Create and Setup .env
Before running any scripts, you'll want to create a .env file with the following values (see .env.example):

- **INFURA_API_KEY=""**
- **PRIVATE_KEY=""** (By default we are using WETH)
- **ETHERSCAN_API_KEY=""** (By default we are using SHIB)
- **ACCOUNT=""** (Account to recieve profit/execute arbitrage contract)
- **PRICE_DIFFERENCE=0.50** (Difference in price between Uniswap & Sushiswap, default is 0.50%)
- **UNITS=0** (Only used for price reporting)
- **GAS_LIMIT=600000** (Currently a hardcoded value, may need to adjust during testing)
- **GAS_PRICE=0.0093** (Currently a hardcoded value, may need to adjust during testing)

### 5. Migrate Smart Contracts
In a seperate terminal run:
`$ yarn migrate-mainnet`

### 6. Start the Bot
`$ node ./bot/bot.js`

## Testing Bot on Mainnet
For monitoring prices and detecting potential arbitrage opportunities, you do not need to deploy the contract. 

### 1. Edit config.json
Inside the *config.json* file, set **isDeployed** to **false**.

### 2. Create and Setup .env
See step #4 in **Setting Up**

### 3. Run the bot
`$ node ./bot/bot.js`

Keep in mind you'll need to wait for an actual swap event to be triggered before it checks the price.

## Anatomy of bot.js
The bot is essentially composed of 5 functions.
- *main()*
- *checkPrice()*
- *determineDirection()*
- *determineProfitability()*
- *executeTrade()*

The *main()* function monitors swap events from both Uniswap & Sushiswap. 

When a swap event occurs, it calls *checkPrice()*, this function will log the current price of the assets on both Uniswap & Sushiswap, and return the **priceDifference**

Then *determineDirection()* is called, this will determine where we would need to buy first, then sell. This function will return an array called **routerPath** in *main()*. The array contains Uniswap & Sushiswap's router contracts. If no array is returned, this means the **priceDifference** returned earlier is not higher than **difference**

If **routerPath** is not null, then we move into *determineProfitability()*. This is where we set our conditions on whether there is a potential arbitrage or not. This function returns either true or false.

If true is returned from *determineProfitability()*, then we call *executeTrade()* where we make our call to our arbitrage contract to perform the trade. Afterwards a report is logged, and the bot resumes to monitoring for swap events.

### Modifying & Testing the Scripts
Both the *manipulatePrice.js* and *bot.js* has been setup to easily make some modifications easy. Before the main() function in *manipulatePrice.js*, there will be a comment: **// -- CONFIGURE VALUES HERE -- //**. Below that will be some constants you'll be able to modify such as the unlocked account, and the amount of tokens you'll want that account to spent in order to manipulate price (You'll need to adjust this if you are looking to test different pairs).

For *bot.js*, you'd want to take a look at the function near line 132 called *determineProfitability()*. Inside this function we can set our conditions and do our calculations to determine whether we may have a potential profitable trade on our hands. This function is to return **true** if a profitable trade is possible, and **false** if not.

Note if you are doing an arbitrage for a different ERC20 token than the one in the provided example (WETH), then you may also need to adjust profitability reporting in the *executeTrade()* function.

Keep in mind, after running the scripts, specifically *manipulatePrice.js*, you may need to restart your ganache cli, and re-migrate contracts to properly retest.

### Additional Information
The *bot.js* script uses helper functions for fetching token pair addresses, calculating price of assets, and calculating estimated returns. These functions can be found in the *helper.js* file inside of the helper folder.

The helper folder also has *server.js* which is responsible for spinning up our local server, and *initialization.js* which is responsible for setting up our web3 connection, configuring Uniswap/Sushiswap contracts, etc. 

As you customize parts of the script it's best to refer to [Uniswap documentation](https://docs.uniswap.org/protocol/V2/introduction) for a more detail rundown on the protocol and interacting with the V2 exchange.

### Strategy Overview and Potential Errors
The current strategy implemented is only shown as an example alongside with the *manipulatePrice.js* script. Essentially, after we manipulate price on Uniswap, we look at the reserves on Sushiswap and determine how much SHIB we need to buy on Uniswap to 'clear' out reserves on Sushiswap. Therefore the arbitrage direction is Uniswap -> Sushiswap. 

This works because Sushiswap has lower reserves than Uniswap. However, if the arbitrage direction was swapped: Sushiswap -> Uniswap, this will sometimes error out if monitoring swaps on mainnet.

This error occurs in the *determineProfitability()* function inside of *bot.js*. Currently a try/catch is implemented, so if it errors out, the bot will just resume monitoring price. Other solutions to this may be to implement a different strategy, use different ERC20 tokens, or reversing the order.

## Using other EVM chains
If you are looking to test on an EVM compatible chain, you can follow these steps:

### 1. Update .env

- **ARB_FOR=""** 
- **ARB_AGAINST=""**

Token addresses will be different on different chains, you'll want to reference blockchain explorers such as [Polyscan](https://polygonscan.com/) for Polygon for token addresses you want to test.

### 2. Update config.json

- **V2_ROUTER_02_ADDRESS=""** 
- **FACTORY_ADDRESS=""**

You'll want to update the router and factory addresses inside of the *config.json* file with the V2 exchanges you want to use. Based on the exchange you want to use, refer to the documentation for it's address.

### 3. Change RPC URL

Inside of *initialization.js* and *helpers.js*, you'll want to update the Web3 provider RPC URL. Example of Polygon:
```
web3 = new Web3(`wss://polygon-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`)
```

### 4. Changing Arbitrage.sol
You may also need to change the flashloan provider used in the contract to one that is available on your chain of choice.

### Additional Notes

- When starting ganache CLI, you'll want to fork using your chain's RPC URL and perhaps update the address of the account you want to unlock.
- If testing out the *manipulatePrice.js* script, you'll also want to update the **UNLOCKED_ACCOUNT** variable and adjust **AMOUNT** as needed.