// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IBancorNetwork } from "../interfaces/IBancorNetwork.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract BancorV3Router {
    IBancorNetwork public bancorNetwork;
    event SwapedOnBancorV3(address indexed _sender, address indexed _assset, uint256 _amountOut);
    function bancorV3Swap(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        uint256 endIndex = path.length - 1;
        // Approve the router to spend DAI.
        TransferHelper.safeApprove(path[0], address(bancorNetwork), amountIn);
        amountOut = bancorNetwork.tradeBySourceAmount(
            path[0],
            path[1],
            amountIn,
            amountOutMin,
            uint256(deadline),
            recipient
        );
        require(amountOut > 0, "Swap failed on BancorV3!");
        emit SwapedOnBancorV3(recipient, path[endIndex], amountOut);
    }
}