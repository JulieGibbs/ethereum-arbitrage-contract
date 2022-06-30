// SPDX-License-Identifier: MIT;
pragma solidity >=0.7.6;
pragma experimental ABIEncoderV2;

import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3FlashCallback.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/libraries/LowGasSafeMath.sol";
import "@uniswap/v3-periphery/contracts/base/PeripheryPayments.sol";
import "@uniswap/v3-periphery/contracts/base/PeripheryImmutableState.sol";
import "@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol";
import "@uniswap/v3-periphery/contracts/libraries/CallbackValidation.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IOneinchRouter.sol";
import "../utils/ReentrancyGuard.sol";
/// @title Flashloan contract implementation
/// @notice contract using the Uniswap V3 flash function
contract UniswapFlash1Inch is 
    IUniswapV3FlashCallback,
    PeripheryImmutableState,
    PeripheryPayments,
    ReentrancyGuard,
    Ownable {
    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address payer;
        PoolAddress.PoolKey poolKey;
    }
    using LowGasSafeMath for uint256;
    IUniswapV3Pool public flashPool;
    uint24 public flashPoolFee;  //  flash from the 0.05% fee of pool
    constructor(
        address _factory,
        address _WETH9
    ) PeripheryImmutableState(_factory, _WETH9) {}
    function initUniFlashSwap(
        address[] calldata loanAssets,
        uint256[] calldata loanAmounts,
        address[] calldata oneInchRouters,
        address[] calldata tokenPath,
        bytes[] calldata tradeData
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
                oneInchRouters,
                tokenPath,
                tradeData
            )
        );
    }

    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external override {
       
        (
            FlashCallbackData memory decoded,
            address[] memory routers,
            address[] memory tokenPath,
            bytes[] memory tradeDatas
        ) = abi.decode(data, (FlashCallbackData, address[],  address[], bytes[]));
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
        uint256 amountOut = 0;
        for (uint i; i < tokenPath.length; i++) {
            uint256 amountIn = IERC20(tokenPath[i]).balanceOf(address(this));
            TransferHelper.safeApprove(tokenPath[i], routers[i], amountIn);
            (bool success, ) = routers.call(tradeDatas[i]);
            require(success, "Swap Failue!");

        }
  
        uint256 amountOwed = LowGasSafeMath.add(loanAmount, fee);
        
        if (amountOwed > 0) {
            pay(loanAsset, address(this), msg.sender, amountOwed);
        }
        uint256 profit = LowGasSafeMath.sub(amountOut, amountOwed);
        if (profit > 0) {
            pay(loanAsset, address(this), payer, profit);
        }
    }
    
    function setFlashPoolFee(uint24 poolFee) public onlyOwner() {
        flashPoolFee = poolFee;
    }
    fallback() external payable {}
}
