// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { ISynapseSwap } from "../interfaces/ISynapseSwap.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract SynapseSwapRouter {
    ISynapseSwap public synapseSwapRouter;
    event SwapedOnSynapse(address indexed _sender, address indexed _assset, uint256 _amountOut);
    function synapseSwap(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        uint256 endIndex = path.length - 1;
        // Approve the router to spend DAI.
        TransferHelper.safeApprove(path[0], address(synapseSwapRouter), amountIn);
        amountOut = synapseSwapRouter.swap(
            synapseSwapRouter.getTokenIndex(path[0]),
            synapseSwapRouter.getTokenIndex(path[1]),
            amountIn,
            amountOutMin,
            deadline
        );
        require(amountOut > 0, "Swap failed on SynapseSwap!");
        emit SwapedOnSynapse(recipient, path[endIndex], amountOut);
    }
}