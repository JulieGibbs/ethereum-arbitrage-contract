// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;
// https://github.com/1inch/1inchProtocol
interface IOneinchV4Router {
    struct SwapDescription {
        address srcToken;
        address dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }
    function swap(
        IAggregationExecutor caller,
        SwapDescription calldata desc,
        bytes calldata data
    ) external payable returns (
            uint256 returnAmount,
            uint256 spentAmount,
            uint256 gasLeft
    );
}
interface IAggregationExecutor {
    /// @notice Make calls on `msgSender` with specified data
    function callBytes(address msgSender, bytes calldata data) external payable;  // 0x2636f7f8
}