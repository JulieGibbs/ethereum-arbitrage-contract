// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
import { IDODOFactory, IDCPFactory, IDODOV2 } from "../../interfaces/IDODO.sol";
contract DodoV2Adapter {
    // IDODOFactory public dodoDVMQuoter;
    // IDODOFactory public dodoDPPQuoter;
    // IDODOFactory public dodoDSPQuoter;
    // IDCPFactory public dodoDCPQuoter;
    function getPriceOnDodoV2(
        address dodoV2Quoter,
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) external view returns (uint256 amountOut) {
        address[] memory dodoV2Pool = IDODOFactory(dodoV2Quoter).getDODOPool(tokenIn, tokenOut);
        for (uint i; i < dodoV2Pool.length; i++) {
            uint quoteAmount = tokenIn == IDODOV2(dodoV2Pool)._BASE_TOKEN_()
                ? IDODOV2(dodoV2Pool).querySellBase(tokenIn, amountIn)
                : IDODOV2(dodoV2Pool).querySellQuote(tokenIn, amountIn);
            if (quoteAmount >= amountOut) amountOut = quoteAmount;
        }
    }
    function getPriceOnDodoV2DCP(
        address dodoDCPQuoter,
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) external view returns (uint256 amountOut) {
        address[] memory dodoV2Pool = IDCPFactory(dodoDCPQuoter).getCrowdPooling(tokenIn, tokenOut);
        for (uint i; i < dodoV2Pool.length; i++) {
            uint quoteAmount = tokenIn == IDODOV2(dodoV2Pool)._BASE_TOKEN_()
                ? IDODOV2(dodoV2Pool).querySellBase(tokenIn, amountIn)
                : IDODOV2(dodoV2Pool).querySellQuote(tokenIn, amountIn);
            if (quoteAmount >= amountOut) amountOut = quoteAmount;
        }
    }
}