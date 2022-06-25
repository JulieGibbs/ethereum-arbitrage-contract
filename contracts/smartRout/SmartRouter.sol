// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { RouterRegistry } from "./RouterRegistry.sol";
import { SafeMath } from "../utils/SafeMath.sol";
contract SmartRouter is RouterRegistry {
    using SafeMath for uint256;
    
    constructor(
        address uniswapFlash
    ) RouterRegistry(uniswapFlash){}
    function getRouterPath(
        address[] calldata tokenPath,
        uint256 amonutIn
    ) external view returns (RouterInfor[] memory routers) {
        uint256 amountOutMax;
        for (uint i; i < tokenPath.length; i++) {
            uint256 next = (i + 1).mod(tokenPath.length);
            uint256 routerIndex;
            for (uint j = 1; j <= uniswapFlash.routerInfos.length; j++) {
                if(UNISWAP_V3_ROUTER_ID  == j) {
                    uint256 amountOut = getPriceOnUniV3(
                        uniswapFlash.routerInfos[j].quoter,
                        tokenPath[i], 
                        tokenPath[next], 
                        amountIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerIndex = UNISWAP_V3_ROUTER_ID;
                    }
                }
            }
            routers.push(
                RouterInfo(
                    {
                        routerIndex: UNISWAP_V3_ROUTER_ID,
                        amount: amountOut
                    }
                )
            );
        }
    }
}