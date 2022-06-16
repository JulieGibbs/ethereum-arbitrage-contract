// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IUniswapV2Router02 } from "../interfaces/IUniswapV2Router02.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract UniswapV2Router {
    IUniswapV2Router02 public uniswapV2Router;
    event SwapedOnUniswapV2(address indexed _sender, address indexed _assset, uint256 _amountOut);
    function uniV2Swap(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        uint256 endIndex = path.length - 1;
        // Approve the router to spend DAI.
        TransferHelper.safeApprove(path[0], address(uniswapV2Router), amountIn);
        amountOut = uniswapV2Router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            recipient,
            deadline
        )[endIndex];
        require(amountOut > 0, "Swap failed on UniswapV2!");
        emit SwapedOnUniswapV2(recipient, path[endIndex], amountOut);
    }
}