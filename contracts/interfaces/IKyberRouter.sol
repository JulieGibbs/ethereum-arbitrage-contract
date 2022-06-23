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

  /// @dev Params for swapping exact output amount
  /// @param tokenIn the token to swap
  /// @param tokenOut the token to receive
  /// @param fee the pool's fee
  /// @param recipient address to receive tokenOut
  /// @param deadline time that the transaction will be expired
  /// @param amountOut the tokenOut amount of tokenOut
  /// @param amountInMaximum the minimum input amount
  /// @param limitSqrtP the price limit, if reached, stop swapping
  struct ExactOutputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountOut;
    uint256 maxAmountIn;
    uint160 limitSqrtP;
  }

  /// @notice Swaps as little as possible of one token for `amountOut` of another token
  /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
  /// @return amountIn The amount of the input token
  function swapExactOutputSingle(ExactOutputSingleParams calldata params)
    external
    payable
    returns (uint256 amountIn);

  /// @dev Params for swapping exact output using multiple pools
  /// @param path the encoded path to swap from tokenIn to tokenOut
  ///   If the swap is from token0 -> token1 -> token2, then path is encoded as [token2, fee12, token1, fee01, token0]
  /// @param recipient address to receive tokenOut
  /// @param deadline time that the transaction will be expired
  /// @param amountOut the tokenOut amount of tokenOut
  /// @param amountInMaximum the minimum input amount
  struct ExactOutputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountOut;
    uint256 maxAmountIn;
  }

  /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
  /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
  /// @return amountIn The amount of the input token
  function swapExactOutput(ExactOutputParams calldata params)
    external
    payable
    returns (uint256 amountIn);
}
interface ISwapCallback {
    /// @notice Called to `msg.sender` after swap execution of IPool#swap.
    /// @dev This function's implementation must pay tokens owed to the pool for the swap.
    /// The caller of this method must be checked to be a Pool deployed by the canonical Factory.
    /// deltaQty0 and deltaQty1 can both be 0 if no tokens were swapped.
    /// @param deltaQty0 The token0 quantity that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send deltaQty0 of token0 to the pool.
    /// @param deltaQty1 The token1 quantity that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send deltaQty1 of token1 to the pool.
    /// @param data Data passed through by the caller via the IPool#swap call
    function swapCallback(
      int256 deltaQty0,
      int256 deltaQty1,
      bytes calldata data
    ) external;
}