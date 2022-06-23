// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IParaswap, ITokenTransferProxy } from "../interfaces/IParaswap.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract PancakeswapRouter {
    IParaswap public paraswap;
    event SwapedOnParaswap(address indexed _sender, address indexed _assset, uint256 _amountOut);
    function paraSwap(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        ITokenTransferProxy tokenTransferProxy = ITokenTransferProxy(paraswap.getTokenTransferProxy());
        // Approve the router to spend token.
        uint256 endIndex = path.length - 1;
        TransferHelper.safeApprove(path[0], address(tokenTransferProxy), amountIn);
        amountOut = amountOutMin;
        // amountOut = paraswap.simpleSwap(
        //     Utils.SimpleData({
        //         fromToken: path[0],
        //         toToken: path[1],
        //         fromAmount: amountIn,
        //         toAmount: amountOutMin,
        //         expectedAmount: amountOutMin,
        //         callees: 
        //         exchangeData: 
        //         startIndexes:
        //         values:
        //         beneficiary: payable(recipient),
        //         partner:
        //         feePercent:
        //         permit:
        //         deadline: deadline,
        //         uuid:
        //     })
        //     amountIn,
        //     amountOutMin,
        //     path,
        //     recipient,
        //     deadline
        // );
        require(amountOut > 0, "Swap failed on Paraswap!");
        emit SwapedOnParaswap(recipient, path[endIndex], amountOut);
    } 
}