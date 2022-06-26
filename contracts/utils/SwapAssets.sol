// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;
import { UniswapV3Router, IUniswapV3Router } from "../routers/UniswapV3Router.sol";
import { UniswapV2Router, IUniswapV2Router02 } from "../routers/UniswapV2Router.sol";
import { DodoSwapRouter, IDODOProxy, IDODOFactory } from "../routers/DodoSwapRouter.sol";
import { BalancerRouter, IBalancerVault } from "../routers/BalancerRouter.sol";
import { BancorV3Router, IBancorNetwork } from "../routers/BancorV3Router.sol";
import { KyberSwapRouter, IKyberRouter } from "../routers/KyberSwapRouter.sol";
import { RouterRegistry } from "./RouterRegistry.sol";
import { Helpers } from "./Helpers.sol";

contract SwapAssets is 
    UniswapV3Router,
    UniswapV2Router,
    DodoSwapRouter,
    BalancerRouter,
    BancorV3Router,
    KyberSwapRouter,
    RouterRegistry {

    function tradeExecute(
        address recipient,
        address loanedAssest,
        uint256 loanedAmount,
        address[] memory tradeAssets,
        uint16[] memory tradeDexes
    ) internal returns (uint256 amountOut){
        require(loanedAmount > 0, "loaned amount is 0");
        require(tradeDexes.length == tradeAssets.length, "Invalid trade params");
        require(
            tradeAssets[tradeAssets.length - 1] == loanedAssest,
            "end trade assest must be equal to loaned assest"
        );
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
        if (routerInfos[dexId].series == DexSeries.UniswapV3) {
            if (address(uniswapV3Router) == address(0) 
                || address(uniswapV3Router) !=  routerInfos[dexId].router
            ) {
                uniswapV3Router = IUniswapV3Router(routerInfos[dexId].router);
            }
            amountOut = uniV3SwapSingle(
                recipient,
                path,
                amountIn,
                0,
                routerInfos[dexId].poolFee,
                uint64(block.timestamp) + routerInfos[dexId].deadline
            );
        } else if (routerInfos[dexId].series == DexSeries.UniswapV2) {
            if (address(uniswapV2Router) == address(0) 
                || address(uniswapV2Router) !=  routerInfos[dexId].router
            ) {
                uniswapV3Router = IUniswapV3Router(routerInfos[dexId].router);
            }
            amountOut = uniV2Swap(
                recipient,
                path,
                amountIn,
                0,
                uint64(block.timestamp) + routerInfos[dexId].deadline
            );
        }
        else if (dexId == KYBERSWAP_ROUTER_ID) {
            if (address(kyberSwapRouter) == address(0) 
                || address(kyberSwapRouter) !=  routerInfos[dexId].router
            ) {
                kyberSwapRouter = IKyberRouter(routerInfos[dexId].router);
            }
            amountOut = kyberSwapSingle(
                recipient,
                path,
                amountIn,
                0,
                routerInfos[dexId].poolFee,
                uint64(block.timestamp) + routerInfos[dexId].deadline
            );
        }
        // else if (dexId == DODODVM_ROUTER_ID) {
        //     if (address(dodoProxy) == address(0) 
        //         || address(dodoProxy) !=  routerInfos[dexId].router
        //     ) {
        //         dodoProxy = IDODOProxy(routerInfos[dexId].router);
        //     }
            
        //     dodoFactory = IDODOFactory(routerInfos[dexId].factory);
        //     amountOut = dodoSwapV2(
        //         recipient,
        //         path,
        //         amountIn,
        //         0,
        //         uint64(block.timestamp) + routerInfos[dexId].deadline
        //     );
        // }
        // else if (dexId == BALANCERSWAP_ROUTER_ID) {
        //     balancerVault = IBalancerVault(routerInfos[dexId].router);
        //     amountOut = balancerSingleSwap(
        //         recipient,
        //         path,
        //         amountIn,
        //         0,
        //         uint64(block.timestamp) + routerInfos[dexId].deadline
        //     );
        // }
        else if (dexId == BANCOR_V3_ROUTER_ID) {
            if (address(bancorNetwork) == address(0) 
                || address(bancorNetwork) !=  routerInfos[dexId].router
            ) {
                bancorNetwork = IBancorNetwork(routerInfos[dexId].router);
            }
            amountOut = bancorV3Swap(
                recipient,
                path,
                amountIn,
                0,
                uint64(block.timestamp) + routerInfos[dexId].deadline
            );
        }
    }
}