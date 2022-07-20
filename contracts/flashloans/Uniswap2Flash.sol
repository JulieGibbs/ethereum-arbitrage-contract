// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
pragma abicoder v2;

import { IUniswapV2Pair } from "../interfaces/uniswap/IUniswapV2Pair.sol";
import { IUniswapV2Factory } from "../interfaces/uniswap/IUniswapV2Factory.sol";
import { IUniswapV2Callee } from "../interfaces/uniswap/IUniswapV2Callee.sol";
import { PeripheryPayments, IERC20 } from "../utils/PeripheryPayments.sol";
import { PeripheryImmutableState } from "../utils/PeripheryImmutableState.sol";
import { SafeMath } from "../utils/SafeMath.sol";
contract Uniswap2Flash is 
    IUniswapV2Callee, 
    PeripheryImmutableState,
    PeripheryPayments
{
    using SafeMath for uint256;
    struct FlashCallbackData {
        address token;
        uint256 amount;
        address payer;
    }
    struct Call {
        address to;
        bytes data;
    }
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    constructor(
        address _factory,
        address _WETH9
    ) PeripheryImmutableState(_factory, _WETH9) {}

    // Initiate arbtrage
    // begins receving loan to engage and performing arbtrage trades
    function initFlashloan(
        address loanToken, 
        uint256 loanAmount, 
        Call[] calldata calls
    ) external {
        // Get the Factory Pair address for combined tokens
        address otherToken = loanToken == WETH9 ? DAI : WETH9;
        address flashPool = IUniswapV2Factory(factory).getPair(loanToken, otherToken);
        // Return error if combination does not exit
        require (flashPool != address(0), "Invalid flash pool!");
        address token0 = IUniswapV2Pair(flashPool).token0();
        address token1 = IUniswapV2Pair(flashPool).token1();
        uint256 amount0Out = loanToken == token0 ? loanAmount : 0;
        uint256 amount1Out = loanToken == token1 ? loanAmount : 0;
        FlashCallbackData memory callbackData = FlashCallbackData({
            token: loanToken,
            amount: loanAmount,
            payer: msg.sender
        });
        // Execute the initial swap to get the loan
        IUniswapV2Pair(flashPool).swap(
            amount0Out, 
            amount1Out, 
            address(this), 
            abi.encode(
                callbackData,
                flashPool,
                calls
            )
        );
    }

    function uniswapV2Call(
        address, 
        uint256, 
        uint256, 
        bytes calldata data
    ) external override {
        // Ensure this request cane from the contract
        (
            FlashCallbackData memory callback,
            address flashPool,
            Call[] memory calls
        ) = abi.decode(data, (FlashCallbackData, address, Call[]));
        require(msg.sender == flashPool, "Only Pool can call!");
        address loanToken = callback.token;
        uint256 loanAmount = callback.amount;

        for (uint i = 0; i < calls.length; i++) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = calls[i].to.call(calls[i].data);
            require(success, "Trading Failure!");
        }
        uint256 amountOut = IERC20(loanToken).balanceOf(address(this));
        uint256 amountOwed = loanAmount.add(((loanAmount.mul(3)).div(997)).add(1));
        if (amountOut >= amountOwed) {
            pay(loanToken, address(this), flashPool, amountOwed);
        }
        uint256 profit = amountOut.sub(amountOwed);
        if (profit > 0) {
            pay(loanToken, address(this), callback.payer, profit);
        }
    }

}