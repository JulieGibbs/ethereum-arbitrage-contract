// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;

interface IMooniFactory {
    function swap(
        address src,
        address dst,
        uint256 amount,
        uint256 minReturn,
        address referral
    ) external payable returns(uint256 result);
    function getReturn(address src, address dst, uint256 amount) external view returns(uint256);
}