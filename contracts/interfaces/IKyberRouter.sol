// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

/// @notice Functions for swapping tokens via KyberSwap v2
/// - Support swap with exact input or exact output
/// - Support swap with a price limit
/// - Support swap within a single pool and between multiple pools
interface IKyberRouter {
  /// @dev Params for swapping exact input amount
  /// @param tokenIn the token to swap
  /// @param tokenOut the token to receive
  /// @param fee the pool's fee
  /// @param recipient address to receive tokenOut
  /// @param deadline time that the transaction will be expired
  /// @param amountIn the tokenIn amount to swap
  /// @param amountOutMinimum the minimum receive amount
  /// @param limitSqrtP the price limit, if reached, stop swapping
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

  /// @notice Swaps `amountIn` of one token for as much as possible of another token
  /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
  /// @return amountOut The amount of the received token
  function swapExactInputSingle(ExactInputSingleParams calldata params)
    external
    payable
    returns (uint256 amountOut);

  /// @dev Params for swapping exact input using multiple pools
  /// @param path the encoded path to swap from tokenIn to tokenOut
  ///   If the swap is from token0 -> token1 -> token2, then path is encoded as [token0, fee01, token1, fee12, token2]
  /// @param recipient address to receive tokenOut
  /// @param deadline time that the transaction will be expired
  /// @param amountIn the tokenIn amount to swap
  /// @param amountOutMinimum the minimum receive amount
  struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 minAmountOut;
  }

  /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
  /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
  /// @return amountOut The amount of the received token
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
  /// @notice Returns the amount out received for a given exact input swap without executing the swap
  /// @param path The path of the swap, i.e. each token pair and the pool fee
  /// @param amountIn The amount of the first token to swap
  /// @return amountOut The amount of the last token that would be received
  /// @return afterSqrtPList List of the sqrt price after the swap for each pool in the path
  /// @return initializedTicksCrossedList List of the initialized ticks that the swap crossed for each pool in the path
  /// @return gasEstimate The estimate of the gas that the swap consumes
  function quoteExactInput(bytes memory path, uint256 amountIn)
    external
    returns (
      uint256 amountOut,
      uint160[] memory afterSqrtPList,
      uint32[] memory initializedTicksCrossedList,
      uint256 gasEstimate
    );


  /// @notice Returns the amount out received for a given exact input but for a swap of a single pool
  /// @param params The params for the quote, encoded as `QuoteExactInputSingleParams`
  /// tokenIn The token being swapped in
  /// tokenOut The token being swapped out
  /// fee The fee of the token pool to consider for the pair
  /// amountIn The desired input amount
  /// limitSqrtP The price limit of the pool that cannot be exceeded by the swap
  function quoteExactInputSingle(QuoteExactInputSingleParams memory params)
    external
    returns (QuoteOutput memory);
}