// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma experimental ABIEncoderV2;
import { IQuoter } from "../../interfaces/IUniswapV3Router.sol";
import { Helpers } from "../../utils/Helpers.sol";

contract UniV3Adapter {
    // IQuoter public uniV3Quoter;
    function getPriceOnUniV3(
        address uniV3Quoter,
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) public returns (uint256 amountOut) {
        uint24 poolFee = 3000;
        try IQuoter(uniV3Quoter).quoteExactInput(
            abi.encodePacked(tokenIn, poolFee, tokenOut),
            amountIn
        ) returns (uint256 output)
        {
            amountOut = output;
        } catch {
            amountOut = 0;
        }
    }
}
