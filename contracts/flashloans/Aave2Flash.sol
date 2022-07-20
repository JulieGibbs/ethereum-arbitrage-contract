// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
pragma abicoder v2;

import { FlashLoanReceiverBase, SafeERC20, SafeMath, IERC20 } from "../utils/FlashLoanReceiverBase.sol";
import { ILendingPoolAddressesProvider } from "../interfaces/aave/ILendingPoolAddressesProvider.sol";
import { ILendingPool } from "../interfaces/aave/ILendingPool.sol";
contract Aave2Flash is FlashLoanReceiverBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
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
            abi.encode(calls),
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
        Call[] memory calls = abi.decode(params, (Call[]));

        // start trade
        for (uint i = 0; i < calls.length; i++) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = calls[i].to.call(calls[i].data);
            require(success, "Trading Failure!");
        }
        address loanToken = assets[0];
        uint256 loanAmount = amounts[0];
        uint256 amountOut = IERC20(loanToken).balanceOf(address(this));
        uint256 amountOwed = loanAmount.add(premiums[0]);
        if (amountOut > amountOwed) {
            IERC20(loanToken).safeApprove(address(LENDING_POOL), amountOwed);
        }
        uint256 profit = amountOut.sub(amountOwed);
        if (profit > 0) {
            IERC20(loanToken).safeTransfer(initiator, profit);
        }
        
        return true;
    }

    receive() external payable {}
    fallback() external payable {}
}
