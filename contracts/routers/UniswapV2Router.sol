// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IUniswapV2Router02 } from "../interfaces/IUniswapV2Router02.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract UniswapV2Router {
    bytes4 uniV2Selector;
    function uniV2Swap(
        address recipient,
        address router,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 deadline
    ) internal returns (uint256 amountOut) {
        uniV2Selector = IUniswapV2Router02.swapExactTokensForTokens.selector;
        uint256 endIndex = path.length - 1;
        TransferHelper.safeApprove(path[0], router, amountIn);
        (
            bool success, 
            bytes memory data
        ) = router.call(
            abi.encodeWithSelector(
                IUniswapV2Router02.swapExactTokensForTokens.selector,
                amountIn,
                amountOutMin,
                path,
                recipient,
                deadline
            )
        );
        require(success, "Swap failed on UniswapV2!");
        uint[] memory amountOuts = abi.decode(data, (uint[]));
        amountOut = amountOuts[endIndex];
    }
}