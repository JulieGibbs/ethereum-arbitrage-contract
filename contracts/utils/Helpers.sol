// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma experimental ABIEncoderV2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


library Helpers {
    function getPaths(
        address _token0,
        address _token1
    ) internal pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = _token0;
        path[1] = _token1;
        return path;
    }

}