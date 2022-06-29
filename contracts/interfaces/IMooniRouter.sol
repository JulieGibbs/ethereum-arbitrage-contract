// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;
import { IERC20 } from "./IERC20.sol";
interface IMooniFactory {
    function pools(IERC20 tokenA, IERC20 tokenB) external view returns (IMooniSwap);
    function getAllPools() external view returns(IMooniSwap[] memory);
}
interface IMooniSwap {
    function swap(
        IERC20 src,
        IERC20 dst,
        uint256 amount,
        uint256 minReturn,
        address referral
    ) external payable returns(uint256 result);
    function getReturn(
        IERC20 src, 
        IERC20 dst, 
        uint256 amount
    ) external view returns(uint256);
}
