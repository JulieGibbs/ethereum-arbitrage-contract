// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma experimental ABIEncoderV2;

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
        address quoter;
        address factory;
        uint24 poolFee;    //  3000
        uint64 deadline;  //  300 ~ 600
        DexSeries series;   // 0 = other, 1 = UniswapV3, 2 = UniswapV2, 3 = DodoV2
    }
  
    mapping(uint16 => RouterInfo) public routerInfos;
    uint16[] public routerIds;
    function addRouter(uint16 _routerId, RouterInfo memory _routerInfo) public onlyOwner() {
        require(_routerId > 0, "Invalid router id");
        require(!isExistRouter(_routerId), "already exist router");
        if (routerInfos[_routerId].router == address(0)) {
            routerIds.push(_routerId);
            routerInfos[_routerId] = _routerInfo;
        }
    }
    function removeRouter(uint16 _routerId) public onlyOwner() {
        require(_routerId > 0, "Invalid router id");
        require(isExistRouter(_routerId), "Invalid router id");
        uint routerNum = routerIds.length;
        for (uint i; i < routerNum; i++) {
            if (_routerId == routerIds[i]) {
                routerIds[i] = routerIds[routerNum - 1];
                routerIds.pop();
                delete routerInfos[_routerId];
                return;
            }
        }
    }
    function changeRouter(uint16 _routerId, RouterInfo memory routerInfo) public onlyOwner() {
        require(_routerId > 0, "Invalid router id");
        require(isExistRouter(_routerId), "Invalid router id");
        routerInfos[_routerId] = routerInfo;
    }
    function isExistRouter(uint16 _routerId) internal view returns (bool) {
        uint routerNum = routerIds.length;
        for (uint i; i < routerNum; i++) {
            if (_routerId == routerIds[i]) {
               return true;
            }
        }
        return false;
    }
    function getRouterNumber() public view returns (uint256) {
        return routerIds.length;
    }
    function getRouterIds() public view returns (uint16[] memory) {
        return routerIds;
    }
    function getQuoter(uint16 _routerId) public view returns (address) {
        return routerInfos[_routerId].quoter;
    }
    function getRuoter(uint16 _routerId) public view returns (address) {
        return routerInfos[_routerId].router;
    }
}