// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IUniswapV2Pair {

    function token0() external view returns (address);
    function token1() external view returns (address);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

}
