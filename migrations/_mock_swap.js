const MockSwap = artifacts.require("MockSwap");
module.exports = async function(deployer) {

    await deployer.deploy(MockSwap);
    await MockSwap.deployed();
  // Use deployer to state migration tasks.
};
