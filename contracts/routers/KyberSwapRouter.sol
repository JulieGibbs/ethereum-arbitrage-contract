// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma experimental ABIEncoderV2;
import { IKyberV3Router, IKyberV2Router } from "../interfaces/IKyberRouter.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract KyberSwapRouter {
 
    function kyberV3Swap(
        address recipient,
        address router,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 deadline,
        uint24 poolFee
    ) internal returns (uint256 amountOut) {
        TransferHelper.safeApprove(path[0], router, amountIn);
        (
            bool success, 
            bytes memory data
        ) = router.call(
            abi.encodeWithSelector(
                IKyberV3Router.swapExactInputSingle.selector, 
                IKyberV3Router.ExactInputSingleParams({
                    tokenIn: path[0],
                    tokenOut: path[1],
                    fee: poolFee,
                    recipient: recipient,
                    deadline: deadline,
                    amountIn: amountIn,
                    minAmountOut: amountOutMin,
                    limitSqrtP: 0
                })
            )
        );
        require(success, "Swap failed on KyberV3!");
        amountOut = abi.decode(data, (uint256));
    }
    
    function kyberV2Swap(
        address recipient,
        address router,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint24 poolFee
    ) internal returns (uint256 amountOut) {
        TransferHelper.safeApprove(path[0], router, amountIn);
        (
            bool success, 
            bytes memory data
        ) = router.call(
            abi.encodeWithSelector(
                IKyberV2Router.swap.selector,
                IKyberV2Router.SwapParams({
                    srcAmount: amountIn,
                    minDestAmount: amountOutMin,
                    tradePath: path,
                    recipient: recipient,
                    feeBps: poolFee,
                    feeReceiver: payable(address(0)),
                    extraArgs: ""
                })
            )
        );
        require(success, "Swap failed on KyberV2!");
        amountOut = abi.decode(data, (uint256));
    }
}