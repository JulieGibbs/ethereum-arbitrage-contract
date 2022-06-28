// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma experimental ABIEncoderV2;
import { UniswapV3Router } from "../routers/UniswapV3Router.sol";
import { UniswapV2Router } from "../routers/UniswapV2Router.sol";
import { DodoSwapRouter, IDODOProxy, IDODOFactory } from "../routers/DodoSwapRouter.sol";
// import { BalancerRouter } from "../routers/BalancerRouter.sol";
import { BancorRouter } from "../routers/BancorRouter.sol";
import { KyberSwapRouter } from "../routers/KyberSwapRouter.sol";
import { MooniSwapRouter } from "../routers/MooniSwapRouter.sol";
import { OneinchRouter } from "../routers/OneinchRouter.sol";
import { RouterConstant } from "./RouterConstant.sol";
import { RouterRegistry } from "./RouterRegistry.sol";
import { Helpers } from "./Helpers.sol";

contract SwapAssets is 
    UniswapV3Router,
    UniswapV2Router,
    DodoSwapRouter,
    // BalancerRouter,
    BancorRouter,
    OneinchRouter,
    KyberSwapRouter,
    MooniSwapRouter,
    RouterRegistry,
    RouterConstant {
   
    function tradeExecute(
        address recipient,
        address loanedAssest,
        uint256 loanedAmount,
        address[] memory tradeAssets,
        uint16[] memory tradeDexes
    ) internal returns (uint256 amountOut){
        
        amountOut = swapAsset(
            recipient,
            Helpers.getPaths(loanedAssest, tradeAssets[0]),
            loanedAmount,
            tradeDexes[0]
        );
        for (uint i = 1; i < tradeAssets.length; i++) {
            amountOut = swapAsset(
                recipient,
                Helpers.getPaths(tradeAssets[i - 1], tradeAssets[i]),
                amountOut,
                tradeDexes[i]
            );
        }
    }

    function swapAsset(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint16 dexId
    ) internal returns (uint256 amountOut){
        RouterInfo memory routerInfo = routerInfos[dexId];
        if (routerInfo.series == DexSeries.UniswapV3) {
            
            amountOut = uniV3SwapSingle(
                recipient,
                routerInfo.router,
                path,
                amountIn,
                0,
                routerInfo.poolFee,
                uint64(block.timestamp) + routerInfo.deadline
            );
            
            
        } else if (routerInfo.series == DexSeries.UniswapV2) {
           
            amountOut = uniV2Swap(
                recipient,
                routerInfo.router,
                path,
                amountIn,
                0,
                uint64(block.timestamp) + routerInfo.deadline
            );
        }
        else if (dexId == KYBERSWAP_V3_ROUTER_ID) {
            
            amountOut = kyberV3Swap(
                recipient,
                routerInfo.router,
                path,
                amountIn,
                0,
                routerInfo.poolFee,
                uint64(block.timestamp) + routerInfo.deadline
            );
        }
        else if (dexId == KYBERSWAP_V2_ROUTER_ID) {
            
            amountOut = kyberV2Swap(
                recipient,
                routerInfo.router,
                path,
                amountIn,
                0,
                routerInfo.poolFee
            );
        }
        else if (dexId == ONEINCHI_V4_ROUTER_ID) {
            
            amountOut = oneinchV4Swap(
                recipient,
                routerInfo.router,
                routerInfo.quoter,
                path,
                amountIn,
                0
            );
        }
        else if (dexId == MOONISWAP_ROUTER_ID) {
            amountOut = mooniV1Swap(
                recipient,
                routerInfo.router,
                path,
                amountIn,
                0
            );
        }
        else if (dexId == BANCOR_V3_ROUTER_ID) {
           
            amountOut = bancorV3Swap(
                recipient,
                routerInfo.router,
                path,
                amountIn,
                0,
                uint64(block.timestamp) + routerInfo.deadline
            );
        }
    }

    
}