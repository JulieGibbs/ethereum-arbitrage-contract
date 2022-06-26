// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma experimental ABIEncoderV2;
import { IQuoterV2 } from "../../interfaces/IKyberRouter.sol";
import { Helpers } from "../../utils/Helpers.sol";
contract KyberAdapter {
    // IQuoterV2 public kyberQuoter;
    function getPriceOnKyberSwap(
        address kyberQuoter,
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) public returns (uint256 amountOut) {
        uint24 poolFee = 3000;
        try IQuoterV2(kyberQuoter).quoteExactInput(
            abi.encodePacked(tokenIn, poolFee, tokenOut),
            amountIn
        ) returns (uint256 output, uint160[] memory, uint32[] memory, uint256)
        {
            amountOut = output;
        } catch {
            amountOut = 0;
        }
    }
}
