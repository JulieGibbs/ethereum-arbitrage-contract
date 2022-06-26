// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
import { IMooniFactory } from "../../interfaces/IMoonirouter.sol";
contract MooniAdapter {
    // IMooniFactory public mooniQuoter;
    function getPriceOnMooniSwap(
        address mooniQuoter,
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) public view returns (uint256 amountOut) {
        try IMooniFactory(mooniQuoter).getReturn(
            tokenIn, 
            tokenOut, 
            amountIn
        ) returns (uint256 output)
        {
            amountOut = output;
        } catch {
            amountOut = 0;

        }
    }
}