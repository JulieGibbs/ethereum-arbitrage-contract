// SPDX-License-Identifier: MIT;
pragma solidity >=0.7.6;
pragma abicoder v2;

import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3FlashCallback.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/libraries/LowGasSafeMath.sol";
import "@uniswap/v3-periphery/contracts/base/PeripheryPayments.sol";
import "@uniswap/v3-periphery/contracts/base/PeripheryImmutableState.sol";
import "@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol";
import "@uniswap/v3-periphery/contracts/libraries/CallbackValidation.sol";
import "../../utils/SwapAssets.sol";
import "../../utils/ReentrancyGuard.sol";
/// @title Flash contract implementation
/// @notice contract using the Uniswap V3 flash function
contract UniswapFlash is 
    IUniswapV3FlashCallback,
    PeripheryImmutableState,
    PeripheryPayments,
    SwapAssets,
    ReentrancyGuard {
    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address payer;
        PoolAddress.PoolKey poolKey;
        // uint24 poolFee2;
        // uint24 poolFee3;
    }
    using LowGasSafeMath for uint256;
    IUniswapV3Pool public flashPool;
    uint24 public flashPoolFee;  //  flash from the 0.05% fee of pool
    constructor(
        address _factory,
        address _WETH9
    ) PeripheryImmutableState(_factory, _WETH9) {
     
    }

    /// @param loanAssets array of assets pair to loan. for example [token0, token1].
    /// @param loanAmounts array of assets amounts to loan. for example [amount0, amount1].
    ///         one of two amounts must be 0
    /// @param tradeAssets array of assets to trade. end asset must be equal to loaned assest
    /// @param tradeDexes array of dexes to trade.
    /// @notice Calls the pools flash function with data needed in `uniswapV3FlashCallback`
    function initUniFlashSwap(
        address[] calldata loanAssets,
        uint256[] calldata loanAmounts,
        address[] calldata tradeAssets,
        uint16[] calldata tradeDexes
    ) external nonReentrant {
        PoolAddress.PoolKey memory poolKey = PoolAddress.PoolKey(
            {
                token0: loanAssets[0],
                token1: loanAssets[1],
                fee: flashPoolFee
            }
        );
        flashPool = IUniswapV3Pool(PoolAddress.computeAddress(factory, poolKey));
        require(address(flashPool) != address(0), "Invalid flash pool!");

        flashPool.flash(
            address(this),
            loanAmounts[0],
            loanAmounts[1],
            abi.encode(
                FlashCallbackData({
                    amount0: loanAmounts[0],
                    amount1: loanAmounts[1],
                    payer: msg.sender,
                    poolKey: poolKey
                }),
                tradeAssets,
                tradeDexes
            )
        );
    }

    /// @param fee0 The fee from calling flash for token0
    /// @param fee1 The fee from calling flash for token1
    /// @param data The data needed in the callback passed as FlashCallbackData from `initUniFlashSwap`
    /// @notice implements the callback called from flash
    /// @dev fails if the flash is not profitable, meaning the amountOut from the flash is less than the amount borrowed
    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external override {
       
        (
            FlashCallbackData memory decoded,
            address[] memory tradeAssets,
            uint16[] memory tradeDexes
        ) = abi.decode(data, (FlashCallbackData, address[], uint16[]));
        CallbackValidation.verifyCallback(factory, decoded.poolKey);
        require(
            decoded.amount0 == 0 ||  decoded.amount1 == 0,
            "one of amounts must be 0"
        );
        address loanAsset = decoded.amount0 > 0 ? decoded.poolKey.token0: decoded.poolKey.token1;
        uint256 loanAmount = decoded.amount0 > 0 ? decoded.amount0: decoded.amount1;
        uint256 fee = decoded.amount0 > 0 ? fee0 : fee1;
        address payer = decoded.payer;
        // start trade
        uint256 amountOut = tradeExecute(
            address(this),
            loanAsset,
            loanAmount,
            tradeAssets,
            tradeDexes
        );

        // compute amount to pay back to pool 
        // loanAmount + fee
        uint256 amountOwed = LowGasSafeMath.add(loanAmount, fee);
        
        // pay back pool the loan 
        // note: msg.sender == pool to pay back 
        if (amountOwed > 0) {
            pay(loanAsset, address(this), msg.sender, amountOwed);
        }
        uint256 profit = LowGasSafeMath.sub(amountOut, amountOwed);
        // if profitable pay profits to payer
        if (profit > 0) {
            pay(loanAsset, address(this), payer, profit);
        }
    }
    function setFlashPoolFee(uint24 poolFee) public onlyOwner() {
        flashPoolFee = poolFee;
    }
    fallback() external payable {}
}
