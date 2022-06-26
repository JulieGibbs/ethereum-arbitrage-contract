// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma experimental ABIEncoderV2;
import { UniswapFlash } from "../flashloans/uniswap/UniswapFlash.sol";
import { RouterConstant } from "./RouterConstant.sol";
import { SafeMath } from "../utils/SafeMath.sol";
contract SmartRouter is RouterConstant {
    using SafeMath for uint256;
    struct RouterInfo {
        uint16 routerIndex;
        // address poolAddress;
        uint256 amount;
    }
    
    UniswapFlash public immutable uniswapFlash;

    constructor(
        address payable _uniswapFlash
    ){
        uniswapFlash = UniswapFlash(_uniswapFlash);
    }
    function getRouterPath(
        address[] calldata tokenPath,
        uint256 initialAmonutIn
    ) external returns (RouterInfo[] memory routers) {
        // RouterInfo[] memory routers;
        uint16[] memory routerIds = uniswapFlash.getRouterIds();
        for (uint i; i < tokenPath.length; i++) {
            uint256 amountOutMax = 0;
            uint16 routerId = 0;
            uint256 next = (i + 1).mod(tokenPath.length);
            for (uint j = 0; j <= routerIds.length - 1; j++) {
                if(UNISWAP_V3_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnUniV3(
                        uniswapFlash.getQuoter(UNISWAP_V3_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = UNISWAP_V3_ROUTER_ID;
                    }
                }
                if(UNISWAP_V2_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnUniV2(
                        uniswapFlash.getQuoter(UNISWAP_V2_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = UNISWAP_V2_ROUTER_ID;
                    }
                }
                if(SUSHISWAP_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnUniV2(
                        uniswapFlash.getQuoter(SUSHISWAP_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = SUSHISWAP_ROUTER_ID;
                    }
                }
                if(SHIBASWAP_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnUniV2(
                        uniswapFlash.getQuoter(SHIBASWAP_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = SHIBASWAP_ROUTER_ID;
                    }
                }
                if(DEFISWAP_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnUniV2(
                        uniswapFlash.getQuoter(DEFISWAP_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = DEFISWAP_ROUTER_ID;
                    }
                }
                if(DODODVM_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnDodoV2(
                        uniswapFlash.getQuoter(DODODVM_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = DODODVM_ROUTER_ID;
                    }
                }
                if(DODODPP_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnDodoV2(
                        uniswapFlash.getQuoter(DODODPP_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = DODODPP_ROUTER_ID;
                    }
                }
                if(DODODSP_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnDodoV2(
                        uniswapFlash.getQuoter(DODODSP_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = DODODSP_ROUTER_ID;
                    }
                }
                if(DODODCP_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnDodoV2DCP(
                        uniswapFlash.getQuoter(DODODCP_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = DODODCP_ROUTER_ID;
                    }
                }
                if(BANCOR_V3_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnBancorV3(
                        uniswapFlash.getQuoter(BANCOR_V3_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = BANCOR_V3_ROUTER_ID;
                    }
                }
                if(KYBERSWAP_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnKyberSwap(
                        uniswapFlash.getQuoter(KYBERSWAP_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = KYBERSWAP_ROUTER_ID;
                    }
                }
                if(MOONISWAP_ROUTER_ID  == routerIds[j]) {
                    uint256 amountOut = getPriceOnMooniSwap(
                        uniswapFlash.getQuoter(MOONISWAP_ROUTER_ID),
                        tokenPath[i], 
                        tokenPath[next], 
                        initialAmonutIn
                    );
                    if (amountOut > amountOutMax) {
                        amountOutMax = amountOut;
                        routerId = MOONISWAP_ROUTER_ID;
                    }
                }
            }
            routers[i] = RouterInfo(routerId, amountOutMax);
        }
    }
}