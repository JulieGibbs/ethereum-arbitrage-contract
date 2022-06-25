// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IUniswapV2Router02 } from "../../interfaces/IUniswapV2Router02.sol";
import { Helpers } from "../../utils/Helpers.sol";
contract UniV2Adapter {
    // IUniswapV2Router02 public uniV2Quoter;
    // IUniswapV2Router02 public sushiQuoter;
    // IUniswapV2Router02 public shibaQuoter;
    // IUniswapV2Router02 public defiQuoter;
    function getPriceOnUniV2(
        address uniV2quoter,
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) external view returns (uint256 amountOut) {
        address[] memory path = Helpers.getPaths(tokenIn, tokenOut);
        amountOut = IUniswapV2Router02(uniV2quoter).getAmountsOut(
            amountIn, 
            path
        )[path.length - 1];
    }
}