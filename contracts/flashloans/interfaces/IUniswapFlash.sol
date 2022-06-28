// SPDX-License-Identifier: MIT;
pragma solidity >=0.7.6;
interface IUniswapFlash {
    
    function initUniFlashSwap(
        address[] calldata loanAssets,
        uint256[] calldata loanAmounts,
        address[] calldata tradeAssets,
        uint16[] calldata tradeDexes
    ) external;
}