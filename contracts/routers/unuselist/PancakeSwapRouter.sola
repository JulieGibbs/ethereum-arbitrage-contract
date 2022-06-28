// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IPancakeRouter02 } from "../interfaces/IPancakeRouter02.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract PancakeSwapRouter {
    IPancakeRouter02 public pancakeswapRouter;
    event SwapedOnPancake(address indexed _sender, address indexed _assset, uint256 _amountOut);
    function pancakeSwap(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        // Approve the router to spend token.
        uint256 endIndex = path.length - 1;
        TransferHelper.safeApprove(path[0], address(pancakeswapRouter), amountIn);
        amountOut = pancakeswapRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            recipient,
            deadline
        )[endIndex];
        require(amountOut > 0, "Swap failed on Pancakeswap!");
        emit SwapedOnPancake(recipient, path[endIndex], amountOut);
    } 
}