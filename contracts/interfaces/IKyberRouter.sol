// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

/// @notice Functions for swapping tokens via KyberSwap v2
/// - Support swap with exact input or exact output
/// - Support swap with a price limit
/// - Support swap within a single pool and between multiple pools
interface IKyberV3Router {
    
    struct ExactInputSingleParams {
      address tokenIn;
      address tokenOut;
      uint24 fee;
      address recipient;
      uint256 deadline;
      uint256 amountIn;
      uint256 minAmountOut;
      uint160 limitSqrtP;
    }

    function swapExactInputSingle(ExactInputSingleParams calldata params)
    external
    payable
    returns (uint256 amountOut);
    struct ExactInputParams {
      bytes path;
      address recipient;
      uint256 deadline;
      uint256 amountIn;
      uint256 minAmountOut;
    }

    function swapExactInput(ExactInputParams calldata params)
    external
    payable
    returns (uint256 amountOut);
}
/// @title QuoterV2 Interface
/// @notice Supports quoting the calculated amounts from exact input or exact output swaps.
/// @notice For each pool also tells you the number of initialized ticks crossed and the sqrt price of the pool after the swap.
/// @dev These functions are not marked view because they rely on calling non-view functions and reverting
/// to compute the result. They are also not gas efficient and should not be called on-chain.
interface IQuoterV2 {
    struct QuoteOutput {
        uint256 usedAmount;
        uint256 returnedAmount;
        uint160 afterSqrtP;
        uint32 initializedTicksCrossed;
        uint256 gasEstimate;
    }
    struct QuoteExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint24 feeUnits;
        uint160 limitSqrtP;
    }
    
    function quoteExactInput(bytes memory path, uint256 amountIn)
    external
    returns (
        uint256 amountOut,
        uint160[] memory afterSqrtPList,
        uint32[] memory initializedTicksCrossedList,
        uint256 gasEstimate
    );

    function quoteExactInputSingle(QuoteExactInputSingleParams memory params)
    external
    returns (QuoteOutput memory);
}
interface IKyberV2Router {
    struct GetExpectedReturnParams {
        uint256 srcAmount;
        address[] tradePath;
        uint256 feeBps;
        bytes extraArgs;
    }
    struct SwapParams {
        uint256 srcAmount;
        uint256 minDestAmount;
        address[] tradePath;
        address recipient;
        uint256 feeBps;
        address payable feeReceiver;
        bytes extraArgs;
    }
    function swap(SwapParams calldata params) external payable returns (uint256 destAmount);

    function getExpectedReturn(GetExpectedReturnParams calldata params)
    external
    view
    returns (uint256 destAmount);
}
interface IKyberNetworkProxy {

    /// @notice backward compatible
    function tradeWithHint(
        address src,
        uint256 srcAmount,
        address dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable walletId,
        bytes calldata hint
    ) external payable returns (uint256);

    function tradeWithHintAndFee(
        address src,
        uint256 srcAmount,
        address dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet,
        uint256 platformFeeBps,     // 300
        bytes calldata hint
    ) external payable returns (uint256 destAmount);

    function getExpectedRateAfterFee(
        address src,
        address dest,
        uint256 srcQty,
        uint256 platformFeeBps,     // 300
        bytes calldata hint
    ) external view returns (uint256 expectedRate);
}