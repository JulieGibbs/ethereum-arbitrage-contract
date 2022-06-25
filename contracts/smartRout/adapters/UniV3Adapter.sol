// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
import { IQuoter } from "../../interfaces/IUniswapV3Router.sol";
import { Helpers } from "../../utils/Helpers.sol";

contract UniV3Adapter {
    // IQuoter public uniV3Quoter;
    function getPriceOnUniV3(
        address uniV3Quoter,
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) external view returns (uint256 amountOut) {
        amountOut = IQuoter(uniV3Quoter).quoteExactInput(
            Helpers.getPaths(tokenIn, tokenOut),
            amountIn
        );
    }
}
