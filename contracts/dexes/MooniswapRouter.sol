// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IMooniFactory } from "../interfaces/IMooniFactory.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract MooniswapRouter {
    IMooniFactory public mooniFactory;
    event SwapedOnUniswapV2(address indexed _sender, address indexed _assset, uint256 _amountOut);
    function mooniV1Swap(
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