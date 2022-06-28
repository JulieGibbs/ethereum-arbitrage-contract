// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

import { IKyberV3Router, IKyberV2Router } from "../interfaces/IKyberRouter.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract KyberSwapRouter {
 
    function kyberV3Swap(
        address recipient,
        address router,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint24 poolFee,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        TransferHelper.safeApprove(path[0], router, amountIn);

        // The call to `exactInputSingle` executes the swap given the route.
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

        // The call to `exactInputSingle` executes the swap given the route.
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
    /// @notice uniswapV3ExactInputTriangular swaps a fixed amount of token1 for a maximum possible amount of token3 through an intermediary pool.
    /// For this example, we will swap token1 to token2, then token2 to token3 to achieve our desired output.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its token1 for this function to succeed.
    /// @param amountIn The amount of token1 to be swapped.
    /// @return amountOut The amount of token3 received after the swap.
    // function kyberSwapTriangular(
    //     address recipient,
    //     address[] memory path,
    //     uint256 amountIn,
    //     uint256 amountOutMin,
    //     uint24[] memory poolFee,
    //     uint64 deadline
    // ) internal returns (uint256 amountOut) {
      
    //     require(path.length == 3, "Invaild triangular trade");
    //     require(poolFee.length == 2, "Invaild pool fee");
    //     // Approve the router to spend token1.
    //     TransferHelper.safeApprove(path[0], address(kyberSwapRouter), amountIn);
    //     bytes memory datas = abi.encodePacked(path[0], poolFee[0], path[1], poolFee[1], path[2]);
    //     // Multiple pool swaps are encoded through bytes called a `path`. A path is a sequence of token addresses and poolFees that define the pools used in the swaps.
    //     // The format for pool encoding is (tokenIn, fee, tokenOut/tokenIn, fee, tokenOut) where tokenIn/tokenOut parameter is the shared token across the pools.
    //     // Since we are swapping token1 to token2 and then token2 to token3 the path encoding is (token1, 0.3%, token2, 0.3%, token3).
    //     amountOut = kyberSwapRouter.swapExactInput(
    //         IKyberRouter.ExactInputParams({
    //             path: datas,
    //             recipient: recipient,
    //             deadline: deadline,
    //             amountIn: amountIn,
    //             minAmountOut: amountOutMin
    //         })
    //     );
    //     require(amountOut > 0, "Swap failed on Kyber!");
    //     emit SwapedOnKyber(recipient, path[1], amountOut);
    // }
}