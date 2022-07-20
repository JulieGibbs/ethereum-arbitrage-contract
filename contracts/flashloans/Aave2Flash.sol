// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

import { FlashLoanReceiverBase, SafeERC20 } from "../aave-v2/FlashLoanReceiverBase.sol";
import { ILendingPoolAddressesProvider } from "../aave-v2/interfaces/ILendingPoolAddressesProvider.sol";
import { ILendingPool } from "../aave-v2/interfaces/ILendingPool.sol";
contract Aave2Flash is FlashLoanReceiverBase {
    struct Call {
        address to;
        bytes data;
    }
    constructor(
        ILendingPoolAddressesProvider _lendingPool
    ) FlashLoanReceiverBase(_lendingPool) {}
   
    function initFlashloan(
        address loanAsset,
        uint256 loanAmount,
        Call[] calldata calls
    ) public {
      
        address[] memory loanAssets = new address[](1);
        loanAssets[0] = loanAsset;
        uint256[] memory loanAmounts = new uint256[](1);
        loanAmounts[0] = loanAmount;
        // 0 = no debt, 1 = stable, 2 = variable
        // 0 = pay all loaned
        uint[] memory modes = new uint[](1);
        modes[0] = 0;

        LENDING_POOL.flashLoan(
            address(this),
            loanAssets,
            loanAmounts,
            modes,
            address(this),
            abi.encodePacked(calls),
            0
        );

    }
    /**
        Mid-flashloan logic i.e. what you do with the temporarily acquired flash liquidity
     */
     function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool)
    {
        require(msg.sender == address(LENDING_POOL), "Only Pool can call!");
        (
            Call[] memory calls
        ) = abi.decode(params, Call[]);

        // start trade
        for (uint i = 0; i < calls.length; i++) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = calls[i].to.call(calls[i].data);
            require(success, "Trading Failure!");
        }
        uint256 amountOut = IERC20(assets[0]).balanceOf(address(this));
        uint256 amountOwed = amounts[0].add(premiums[0]);
        if (amountOut > amountOwed) {
            IERC20(assets[0]).safeApprove(msg.sender, amountOwed);
        }
        uint256 profit = amountOut.sub(amountOwed);
        if (profit > 0) {
            pay(assets[0], address(this), initiator, profit);
        }
        
        return true;
    }

    receive() external payable {}
    fallback() external payable {}
}
