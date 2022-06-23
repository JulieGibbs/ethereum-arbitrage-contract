// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;
import { UniswapV3Router, ISwapRouter } from "../dexes/UniswapV3Router.sol";
import { UniswapV2Router, IUniswapV2Router02 } from "../dexes/UniswapV2Router.sol";
import { DodoswapRouter, IDODOV2Proxy, IDVMFactory } from "../dexes/DodoswapRouter.sol";
import { BalancerswapRouter, IBalancerVault } from "../dexes/BalancerswapRouter.sol";
import { BancorswapRouter, IBancorNetwork } from "../dexes/BancorswapRouter.sol";
import { SwapInforRegistry } from "./SwapInforRegistry.sol";
import { Helpers } from "./Helpers.sol";

contract SwapAssets is 
    UniswapV3Router,
    UniswapV2Router,
    SwapInforRegistry {

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
        if (dexId == UNISWAP_V3_ROUTER_ID) {
            uniswapV3Router = ISwapRouter(swapRouterInfos[dexId].router);
            amountOut = uniV3SwapSingle(
                recipient,
                path,
                amountIn,
                0,
                swapRouterInfos[dexId].poolFee,
                uint64(block.timestamp) + swapRouterInfos[dexId].deadline
            );
        } else if (dexId == UNISWAP_V2_ROUTER_ID) {
            uniswapV2Router = IUniswapV2Router02(swapRouterInfos[dexId].router);
            amountOut = uniV2Swap(
                recipient,
                path,
                amountIn,
                0,
                uint64(block.timestamp) + swapRouterInfos[dexId].deadline
            );
        } else if (dexId == SUSHISWAP_ROUTER_ID) {
            uniswapV2Router = IUniswapV2Router02(swapRouterInfos[dexId].router);
            amountOut = uniV2Swap(
                recipient,
                path,
                amountIn,
                0,
                uint64(block.timestamp) + swapRouterInfos[dexId].deadline
            );
        }
        else if (dexId == SIBASWAP_ROUTER_ID) {
            uniswapV2Router = IUniswapV2Router02(swapRouterInfos[dexId].router);
            amountOut = uniV2Swap(
                recipient,
                path,
                amountIn,
                0,
                uint64(block.timestamp) + swapRouterInfos[dexId].deadline
            );
        }
        else if (dexId == KYBERSWAP_ROUTER_ID) {
            uniswapV3Router = ISwapRouter(swapRouterInfos[dexId].router);
            amountOut = uniV3SwapSingle(
                recipient,
                path,
                amountIn,
                0,
                swapRouterInfos[dexId].poolFee,
                uint64(block.timestamp) + swapRouterInfos[dexId].deadline
            );
        }
        else if (dexId == DODOSWAP_ROUTER_ID) {
            dodoswapProxy = IDODOProxy(swapRouterInfos[dexId].router);
            dvmFactory = IDVMFactory(swapRouterInfos[dexId].factory);
            amountOut = dodoSwapV2(
                recipient,
                path,
                amountIn,
                0,
                swapRouterInfos[dexId].poolFee,
                uint64(block.timestamp) + swapRouterInfos[dexId].deadline
            );
        }
        // else if (dexId == BALANCERSWAP_ROUTER_ID) {
        //     balancerVault = IBalancerVault(swapRouterInfos[dexId].router);
        //     amountOut = balancerSingleSwap(
        //         recipient,
        //         path,
        //         amountIn,
        //         0,
        //         swapRouterInfos[dexId].poolFee,
        //         uint64(block.timestamp) + swapRouterInfos[dexId].deadline
        //     );
        // }
        else if (dexId == BANCOR_V3_ROUTER_ID) {
            bancorNetwork = IBancorNetwork(swapRouterInfos[dexId].router);
            amountOut = bancorV3Swap(
                recipient,
                path,
                amountIn,
                0,
                swapRouterInfos[dexId].poolFee,
                uint64(block.timestamp) + swapRouterInfos[dexId].deadline
            );
        }
    }
}