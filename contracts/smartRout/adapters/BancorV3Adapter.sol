// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
import { IBancorNetworkInfo } from "../../interfaces/IBancorV3Router.sol";
contract BancorV3Adapter {
    function getPriceOnBancorV3(
        address bancorV3Quoter,
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) public view returns (uint256 amountOut) {
        try IBancorNetworkInfo(bancorV3Quoter).tradeOutputBySourceAmount(
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