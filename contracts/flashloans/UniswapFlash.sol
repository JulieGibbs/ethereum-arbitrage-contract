// SPDX-License-Identifier: MIT;
pragma solidity >=0.7.6;
pragma abicoder v2;

import { IUniswapV3FlashCallback } from "../interfaces/IUniswapV3FlashCallback.sol";
import { IUniswapV3Pool } from "../interfaces/IUniswapV3Pool.sol";
import { PeripheryPayments, IERC20, TransferHelper } from "../utils/PeripheryPayments.sol";
import { PeripheryImmutableState } from "../utils/PeripheryImmutableState.sol";
import { PoolAddress } from "../utils/PoolAddress.sol";
import { SafeMath } from "../utils/SafeMath.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Flashloan contract implementation
/// @notice contract using the Uniswap V3 flash function
contract UniswapFlash is 
    IUniswapV3FlashCallback,
    PeripheryImmutableState,
    PeripheryPayments,
    ReentrancyGuard,
    Ownable {
    using SafeMath for uint256;
    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address payer;
        PoolAddress.PoolKey poolKey;
    }
    uint24 public flashPoolFee = 500;  //  flash from the 0.05% fee of pool
    constructor(
        address _factory,
        address _WETH9
    ) PeripheryImmutableState(_factory, _WETH9) {}
    function initUniFlashSwap(
        address[] calldata _loanAssets,
        uint256[] calldata _loanAmounts,
        address[] calldata _tokenPath,
        address[] calldata _spenders,
        address[] calldata _routers,
        bytes[] calldata _tradeDatas
    ) external payable nonReentrant {
        
        PoolAddress.PoolKey memory poolKey = PoolAddress.PoolKey(
            {
                token0: _loanAssets[0],
                token1: _loanAssets[1],
                fee: flashPoolFee
            }
        );
        address flashPool = getFlashPool(factory, poolKey);
        require(flashPool != address(0), "Invalid flash pool!");
        uint256 amount0 = _loanAmounts[0];
        uint256 amount1 = _loanAmounts[1];
        FlashCallbackData memory callbackData = FlashCallbackData({
            amount0: amount0,
            amount1: amount1,
            payer: msg.sender,
            poolKey: poolKey
        });
        address[] memory tokenPath = _tokenPath;
        address[] memory spenders = _spenders;
        address[] memory routers = _routers;
        bytes[] memory tradeDatas = _tradeDatas;
        IUniswapV3Pool(flashPool).flash(
            address(this),
            amount0,
            amount1,
            abi.encode(
                callbackData, 
                tokenPath,
                spenders,
                routers,
                tradeDatas
            )
        );   
    }

    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external override {
        (
            FlashCallbackData memory callback,
            address[] memory tokenPath,
            address[] memory spenders,
            address[] memory routers,
            bytes[] memory tradeDatas
        ) = abi.decode(data, (FlashCallbackData, address[], address[], address[], bytes[]));
        require(msg.sender == getFlashPool(factory, callback.poolKey), "Only Pool can call!");
        
        address loanToken = callback.amount0 > 0 ? callback.poolKey.token0: callback.poolKey.token1;
        uint256 loanAmount = callback.amount0 > 0 ? callback.amount0: callback.amount1;
        uint256 fee = callback.amount0 > 0 ? fee0 : fee1;
        // start trade
        for (uint256 i = 0; i < routers.length; i++) {

           swapExecute(tokenPath[i], spenders[i], payable(routers[i]), tradeDatas[i]);
        }
        uint256 amountOut = IERC20(loanToken).balanceOf(address(this));
        uint256 amountOwed = loanAmount.add(fee);
        
        if (amountOut >= amountOwed) {
            pay(loanToken, address(this), msg.sender, amountOwed);
        }
        uint256 profit = amountOut.sub(amountOwed);
        if (profit > 0) {
            pay(loanToken, address(this), callback.payer, profit);
        }
    }
    function swapExecute(
        address token, 
        address spender, 
        address payable router, 
        bytes memory tradeData
    ) internal {
        uint256 amount = IERC20(token).balanceOf(address(this));
        require(amount > 0, "Balanace is 0!");
        approveToken(token, spender, amount);
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = router.call{value: msg.value}(tradeData);
        require(success, "Swap Failure!");
    }
    function getFlashPool(
        address _factory, 
        PoolAddress.PoolKey memory _poolKey
    ) internal pure returns (address) {
        return PoolAddress.computeAddress(_factory, _poolKey);
    }
    function approveToken(address token, address spender, uint256 amount) public {
        uint256 allowance = IERC20(token).allowance(address(this), spender);
        if (allowance < amount) {
            TransferHelper.safeApprove(token, spender, uint256(-1));
        }
    }
    function changeFlashPoolFee(uint24 poolFee) public onlyOwner() {
        flashPoolFee = poolFee;
    }
    fallback() external payable {}
    receive() external payable {}
}
