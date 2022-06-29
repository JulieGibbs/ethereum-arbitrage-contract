// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IMooniFactory, IMooniSwap, IERC20 } from "../interfaces/IMooniRouter.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract MooniSwapRouter {
    function mooniV1Swap(
        address recipient,
        address router,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin
    ) internal returns (uint256 amountOut) {
        // Approve the router to spend DAI.
        IMooniSwap pool = IMooniFactory(router).pools(IERC20(path[0]), IERC20(path[1]));
        TransferHelper.safeApprove(path[0], address(pool), amountIn);
        amountOut = pool.swap(
            IERC20(path[0]),
            IERC20(path[1]),
            amountIn,
            amountOutMin,
            recipient
        );
        require(amountOut > 0, "Swap failed on MooniV1!");
    }
}