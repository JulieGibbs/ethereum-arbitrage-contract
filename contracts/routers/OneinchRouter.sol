// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;
import { IOneinchV4Router, IAggregationExecutor } from "../interfaces/IOneinchRouter.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract OneinchRouter {
    function oneinchV4Swap(
        address recipient,
        address router,
        address executor,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin
    ) internal returns (uint256 amountOut) {
        TransferHelper.safeApprove(path[0], router, amountIn);
        (
            bool success, 
            bytes memory data
        ) = router.call(
            abi.encodeWithSelector(
                IOneinchV4Router.swap.selector,
                IAggregationExecutor(executor),
                IOneinchV4Router.SwapDescription({
                    srcToken: path[0],
                    dstToken: path[1],
                    srcReceiver: payable(recipient),
                    dstReceiver: payable(recipient),
                    amount: amountIn,
                    minReturnAmount: amountOutMin,
                    flags: 4,
                    permit:""
                }),
                ""
            )
        );
        require(success, "Swap failed on 1inchV4!");
        (uint256 returnAmount,,) = abi.decode(data, (uint256, uint256, uint256));
        amountOut = returnAmount;
    }
}