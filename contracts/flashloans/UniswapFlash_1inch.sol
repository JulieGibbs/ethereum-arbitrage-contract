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
        bytes calldata tradeData
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
            bytes memory tradeData
        ) = abi.decode(data, (FlashCallbackData, bytes));
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
        bytes[] memory dexDatas = abi.decode(tradeData, (bytes[]));
        uint256 amountOut = 0;
        for (uint i; i < dexDatas.length; i++) {
            amountOut = oneinchV4Swap(address(this), dexDatas[i]);
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
    function oneinchV4Swap(
        address recipient,
       bytes memory tradeData
    ) internal returns (uint256 amountOut) {
        (
            address router,
            address executor,
            IAggregationRouterV4.SwapDescription memory swapParam,
            bytes memory pathData
        ) = abi.decode(tradeData, (address, address, IAggregationRouterV4.SwapDescription, bytes));
        // aggregationRouter = router;
        // aggregationExecutor = executor;
        swapParam.dstReceiver = payable(recipient);
        TransferHelper.safeApprove(swapParam.srcToken, router, swapParam.amount);
        (
            bool success, 
            bytes memory returnData
        ) = router.call(
            abi.encodeWithSelector(
                IAggregationRouterV4.swap.selector,
                IAggregationExecutor(executor),
                swapParam,
                pathData      // data should not be empty
            )
        );
        require(success, "Swap failed on 1inchV4!");
        (amountOut,,) = abi.decode(returnData, (uint256, uint256, uint256));
    }
    function setFlashPoolFee(uint24 poolFee) public onlyOwner() {
        flashPoolFee = poolFee;
    }
    fallback() external payable {}
}
