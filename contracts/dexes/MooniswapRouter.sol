// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IMooniFactory } from "../interfaces/IMooniFactory.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract MooniswapRouter {
    IMooniFactory public mooniFactory;
    event SwapedOnMooniV1(address indexed _sender, address indexed _assset, uint256 _amountOut);
    function mooniV1Swap(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        uint256 endIndex = path.length - 1;
        // Approve the router to spend DAI.
        TransferHelper.safeApprove(path[0], address(mooniFactory), amountIn);
        amountOut = mooniFactory.swap(
            path[0],
            path[1],
            amountIn,
            amountOutMin,
            recipient
        );
        require(amountOut > 0, "Swap failed on MooniV1!");
        emit SwapedOnMooniV1(recipient, path[endIndex], amountOut);
    }
}