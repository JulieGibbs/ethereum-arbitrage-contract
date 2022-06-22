// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract SwapInforRegistry is Ownable {
    struct SwapRouterInfo {
        address router;
        address factory;
        uint24 poolFee;    //  3000
        uint64 deadline;    //  300 ~ 600
    }
  
    // swap router id constants
    uint16 public constant UNISWAP_V3_ROUTER_ID = 1;
    uint16 public constant UNISWAP_V2_ROUTER_ID = 2;
    uint16 public constant SUSHISWAP_ROUTER_ID = 3;
    uint16 public constant SIBASWAP_ROUTER_ID = 4;
    uint16 public constant ONEINCHISWAP_ROUTER_ID = 5;
    uint16 public constant APESWAP_ROUTER_ID = 6;
    uint16 public constant KYBERSWAP_ROUTER_ID = 7;
    uint16 public constant PANCAKESWAP_ROUTER_ID = 8;
    uint16 public constant DODOSWAP_ROUTER_ID = 9;
    uint16 public constant QUICKSWAP_ROUTER_ID = 10;
    uint16 public constant BALANCERSWAP_ROUTER_ID = 11;
    uint16 public constant BABYSWAP_ROUTER_ID = 12;
    uint16 public constant MOONISWAP_ROUTER_ID = 13;
    uint16 public constant BANCOR_V3_ROUTER_ID = 14;
    mapping(uint16 => SwapRouterInfo) public swapRouterInfos;
    event RouterInfoSeted(
        uint16 _index,
        address indexed _router,
        address indexed _factory,
        uint24 _poolFee
    );
    function setSwapRouterInfo(
        uint16 routerID,
        SwapRouterInfo memory routerInfo
    ) external onlyOwner() {
        swapRouterInfos[routerID] = routerInfo;
        emit RouterInfoSeted(
            routerID,
            routerInfo.router,
            routerInfo.factory,
            routerInfo.poolFee
        );
    }
}