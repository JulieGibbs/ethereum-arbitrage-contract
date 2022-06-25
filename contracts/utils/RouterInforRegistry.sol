// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract RouterInforRegistry is Ownable {
    enum DexSeries {
        UniswapV3,
        UniswapV2,
        DodoV2,
        Other
    }
    struct RouterInfo {
        address router;
        address factory;
        address quoter;
        uint24 poolFee;    //  3000
        uint64 deadline;  //  300 ~ 600
        DexSeries series;   // 0 = uniswapV2, 1 = UniswapV3, 2 = other
    }
  
    // swap router id constants
    uint16 public constant UNISWAP_V3_ROUTER_ID = 1;
    uint16 public constant UNISWAP_V2_ROUTER_ID = 201;
    uint16 public constant SUSHISWAP_ROUTER_ID = 202;
    uint16 public constant SHIBASWAP_ROUTER_ID = 203;
    uint16 public constant DEFISWAP_ROUTER_ID = 204;

    uint16 public constant DODODVM_ROUTER_ID = 301;
    uint16 public constant DODODPP_ROUTER_ID = 302;
    uint16 public constant DODODSP_ROUTER_ID = 303;
    uint16 public constant DODODCP_ROUTER_ID = 304;
    uint16 public constant BANCOR_V3_ROUTER_ID = 4;
    uint16 public constant KYBERSWAP_ROUTER_ID = 5;
    uint16 public constant MOONISWAP_ROUTER_ID = 6;

    uint16 public constant ONEINCHISWAP_ROUTER_ID = 10;
    uint16 public constant BALANCERSWAP_ROUTER_ID = 11;
    mapping(uint16 => RouterInfo) public routerInfos;
    event RouterInfoSeted(
        uint16 _index,
        address indexed _router,
        address indexed _factory,
        uint24 _poolFee
    );
    function setRouterInfo(
        uint16 routerID,
        RouterInfo memory routerInfo
    ) external onlyOwner() {
        routerInfos[routerID] = routerInfo;
        emit RouterInfoSeted(
            routerID,
            routerInfo.router,
            routerInfo.factory,
            routerInfo.poolFee
        );
    }
}