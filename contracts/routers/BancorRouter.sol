// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IBancorNetwork } from "../interfaces/IBancorRouter.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract BancorRouter {
    function bancorV3Swap(
        address recipient,
        address router,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        // Approve the router to spend DAI.
        TransferHelper.safeApprove(path[0], router, amountIn);
        (
            bool success, 
            bytes memory data
        ) = router.call(
            abi.encodeWithSelector(
                IBancorNetwork.tradeBySourceAmount.selector,
                path[0],
                path[1],
                amountIn,
                amountOutMin,
                uint256(deadline),
                recipient
            )
        );
        require(success, "Swap failed on BancorV3!");
        amountOut = abi.decode(data, (uint256));
    }
}