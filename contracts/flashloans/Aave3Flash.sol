// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.0;
pragma abicoder v2;

import { FlashLoanSimpleReceiverBase } from "../utils/FlashLoanSimpleReceiverBase.sol";
import { IPoolAddressesProvider } from "../interfaces/aave/IPoolAddressesProvider.sol";
import { IPool } from "../interfaces/aave/IPool.sol";
import { SafeMath } from "../utils/SafeMath.sol";
import { TransferHelper, IERC20 } from "../utils/TransferHelper.sol";
contract Aave3Flash is FlashLoanSimpleReceiverBase {
    using SafeMath for uint256;
    struct Call {
        address to;
        bytes data;
    }
    constructor(
        IPoolAddressesProvider _lendingPool
    ) FlashLoanSimpleReceiverBase(_lendingPool) {}
   
    function initFlashloan(
        address loanAsset,
        uint256 loanAmount,
        Call[] calldata calls
    ) public {
        // 0 = no debt, 1 = stable, 2 = variable
        // 0 = pay all loaned
        POOL.flashLoanSimple(
            address(this),
            loanAsset,
            loanAmount,
            abi.encode(calls),
            0
        );

    }
    /**
        Mid-flashloan logic i.e. what you do with the temporarily acquired flash liquidity
     */
     function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool)
    {
        require(msg.sender == address(POOL), "Only Pool can call!");
        Call[] memory calls = abi.decode(params, (Call[]));

        // start trade
        for (uint i = 0; i < calls.length; i++) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = calls[i].to.call(calls[i].data);
            require(success, "Trading Failure!");
        }
        uint256 amountOut = IERC20(asset).balanceOf(address(this));
        uint256 amountOwed = amount.add(premium);
        if (amountOut > amountOwed) {
            TransferHelper.safeApprove(asset, address(POOL), amountOwed);
        }
        uint256 profit = amountOut.sub(amountOwed);
        if (profit > 0) {
            TransferHelper.safeTransfer(asset, initiator, profit);
        }
        
        return true;
    }

    receive() external payable {}
    fallback() external payable {}
}
