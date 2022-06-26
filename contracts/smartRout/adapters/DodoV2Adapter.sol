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
    ) public view returns (uint256 amountOut) {
        try IDODOFactory(dodoV2Quoter).getDODOPool(
            tokenIn, 
            tokenOut
        ) returns (address[] memory dodoV2Pools)
        {
            for (uint i; i < dodoV2Pools.length; i++) {
                (uint256 quoteAmount,) = tokenIn == IDODOV2(dodoV2Pools[i])._BASE_TOKEN_()
                    ? IDODOV2(dodoV2Pools[i]).querySellBase(tokenIn, amountIn)
                    : IDODOV2(dodoV2Pools[i]).querySellQuote(tokenIn, amountIn);
                if (quoteAmount >= amountOut) amountOut = quoteAmount;
            }
        } catch {
            amountOut = 0;
        }
        
    }
    function getPriceOnDodoV2DCP(
        address dodoDCPQuoter,
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) public view returns (uint256 amountOut) {
        try IDCPFactory(dodoDCPQuoter).getCrowdPooling(
            tokenIn, 
            tokenOut
        ) returns (address[] memory dodoV2Pools)
        {
            for (uint i; i < dodoV2Pools.length; i++) {
                (uint256 quoteAmount,) = tokenIn == IDODOV2(dodoV2Pools[i])._BASE_TOKEN_()
                    ? IDODOV2(dodoV2Pools[i]).querySellBase(tokenIn, amountIn)
                    : IDODOV2(dodoV2Pools[i]).querySellQuote(tokenIn, amountIn);
                if (quoteAmount >= amountOut) amountOut = quoteAmount;
            }
        } catch {
            amountOut = 0;
        }
    }
}