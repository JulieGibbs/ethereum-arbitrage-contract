const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();
require('solidity-coverage');
require("ts-node").register({
  files: true,
});
const INFURA_API_KEY = process.env.INFURA_API_KEY || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "";
if (!INFURA_API_KEY) {
  throw new Error("Please set your INFURA_API_KEY in a .env file");
}
if (!PRIVATE_KEY) {
  throw new Error("Please set your PRIVATE_KEY in a .env file");
}
module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',     // Localhost (default: none)
      port: 8545,             // Standard Ethereum port (default: none)
      timeoutBlocks: 50000,            
      network_id: '*',       // Any network (default: none)
    },
    kovan: {
      provider: new HDWalletProvider(PRIVATE_KEY, "https://kovan.infura.io/v3/" + INFURA_API_KEY),
      network_id: 42,
      gas: 30000000,
      gasPrice: 20000000000, // 20 Gwei
      skipDryRun: true
    },
    mainnet: {
      provider: new HDWalletProvider(PRIVATE_KEY, "https://mainnet.infura.io/v3/" + INFURA_API_KEY),
      network_id: 1,
      gas: 2000000,
      timeoutBlocks: 50000,
      // gasPrice: 30000000000, // 20 Gwei
      skipDryRun: true
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.6",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: true,
         runs: 200
       },
      //  evmVersion: "byzantium"
      }
    }
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    etherscan: ETHERSCAN_API_KEY
  },

  // Truffle DB is currently disabled by default; to enable it, change enabled:
  // false to enabled: true. The default storage location can also be
  // overridden by specifying the adapter settings, as shown in the commented code below.
  //
  // NOTE: It is not possible to migrate your contracts to truffle DB and you should
  // make a backup of your artifacts to a safe location before enabling this feature.
  //
  // After you backed up your artifacts you can utilize db by running migrate as follows: 
  // $ truffle migrate --reset --compile-all
  //  
  // db: {
    // enabled: false,
    // host: "127.0.0.1",
    // adapter: {
    //   name: "sqlite",
    //   settings: {
    //     directory: ".db"
    //   }
    // }
  // }
};
