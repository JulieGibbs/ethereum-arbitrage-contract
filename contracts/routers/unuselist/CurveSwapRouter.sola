// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { ICurveFi } from "../interfaces/ICurveFi.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract CurveSwapRouter {

    ICurveFi public curveRouter;
    event SwapedOnCurve(address indexed _sender,  address indexed _assset, uint256 _amountOut);
    function curveSwap(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin
    ) internal returns (uint256 amountOut) {
        // Approve the router to spend token.
        TransferHelper.safeApprove(path[0], address(curveRouter), amountIn);
        // amountOut = curveRouter.exchange(path[0], path[1], amountIn, amountOutMin);
        emit SwapedOnCurve(recipient, path[1], amountOut);
    }

}