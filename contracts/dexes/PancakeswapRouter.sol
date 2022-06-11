// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IPancakeRouter02 } from "@bundle-dao/pancakeswap-peripheral/contracts/interfaces/IPancakeRouter02.sol";
import { TransferHelper } from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract PancakeswapRouter {
    IPancakeRouter02 public pancakeswapRouter;
    event SwapedOnPancake(address indexed _sender, uint256 _amountIn, uint256 _amountOut);
    function pancakeSwap(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        // Approve the router to spend token.
        TransferHelper.safeApprove(path[0], address(pancakeswapRouter), amountIn);
        amountOut = pancakeswapRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            recipient,
            deadline
        )[1];
        require(amountOut > 0, "Swap failed on Pancakeswap!");
        emit SwapedOnPancake(recipient, amountIn, amountOut);
    } 
}