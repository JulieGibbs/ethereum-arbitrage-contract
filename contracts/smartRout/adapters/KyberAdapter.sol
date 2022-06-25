// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
import { IQuoterV2 } from "../../interfaces/IKyberRouter.sol";
import { Helpers } from "../../utils/Helpers.sol";
contract KyberAdapter {
    // IQuoterV2 public kyberQuoter;
    function getPriceOnKyberSwap(
        address kyberQuoter,
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) external view returns (uint256 amountOut) {
        (amountOut,,,) = IQuoterV2(kyberQuoter).quoteExactInput(path, amountIn);(
            Helpers.getPaths(tokenIn, tokenOut),
            amountIn
        );
    }
}
