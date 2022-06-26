// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
contract RouterRegistry is Ownable {
    enum DexSeries {
        Other,
        UniswapV3,
        UniswapV2,
        DodoV2
    }
    struct RouterInfo {
        address router;
        address factory;
        address quoter;
        uint24 poolFee;    //  3000
        uint64 deadline;  //  300 ~ 600
        DexSeries series;   // 0 = other, 1 = UniswapV3, 2 = UniswapV2, 3 = DodoV2
    }
   
    // swap router id constants
    uint16 public constant UNISWAP_V3_ROUTER_ID = 1;
    uint16 public constant UNISWAP_V2_ROUTER_ID = 2;
    uint16 public constant SUSHISWAP_ROUTER_ID = 3;
    uint16 public constant SHIBASWAP_ROUTER_ID = 4;
    uint16 public constant DEFISWAP_ROUTER_ID = 5;

    uint16 public constant DODODVM_ROUTER_ID = 6;
    uint16 public constant DODODPP_ROUTER_ID = 7;
    uint16 public constant DODODSP_ROUTER_ID = 8;
    uint16 public constant DODODCP_ROUTER_ID = 9;
    uint16 public constant BANCOR_V3_ROUTER_ID = 10;
    uint16 public constant KYBERSWAP_ROUTER_ID = 11;
    uint16 public constant MOONISWAP_ROUTER_ID = 12;

    uint16 public constant ONEINCHISWAP_ROUTER_ID = 13;
    uint16 public constant BALANCERSWAP_ROUTER_ID = 14;
    mapping(uint16 => RouterInfo) public routerInfos;
    uint16[] public routerIds;
    event RouterInfoSeted(
        uint16 _index,
        address indexed _router,
        address indexed _factory,
        uint24 _poolFee
    );
    event RouterInfoRemoved(
        uint16 _index
    );
    function setRouterInfo(
        uint16 routerID,
        RouterInfo memory routerInfo
    ) public onlyOwner() {

        if (routerInfos[routerID].router == address(0)) routerIds.push(routerID);
        routerInfos[routerID] = routerInfo;

        emit RouterInfoSeted(
            routerID,
            routerInfo.router,
            routerInfo.factory,
            routerInfo.poolFee
        );
    }
    function removeRouterInfo(
        uint16 routerID
    ) public onlyOwner() {
        uint routerNumber = routerIds.length;
        require(routerID <= routerNumber, "Invalid router Id.");
        routerInfos[routerID] = RouterInfo(
            address(0),
            address(0),
            address(0),
            0,
            0,
            DexSeries.Other
        );
        for (uint i; i < routerNumber; i++) {
            if (routerID == routerIds[i]) {
                routerIds[i] = routerIds[routerNumber - 1];
                routerIds.pop();
                break;
            }
        }
        emit RouterInfoRemoved(
            routerID
        );
    }
    function getRouterNumber() public view returns (uint256) {
        return routerIds.length;
    }
    function getRouterIds() public view returns (uint16[] memory) {
        return routerIds;
    }
    function getQuoter(uint16 routerId) public view returns (address) {
        return routerInfos[routerId].quoter;
    }
}