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
    struct Call {
        address to;
        bytes data;
    }
    uint24 public flashPoolFee = 500;  //  flash from the 0.05% fee of pool
    constructor(
        address _factory,
        address _WETH9
    ) PeripheryImmutableState(_factory, _WETH9) {}
    function initUniFlashSwap(
        address[] calldata loanAssets,
        uint256[] calldata loanAmounts,
        Call[] calldata calldatas
    ) external payable nonReentrant {
        
        PoolAddress.PoolKey memory poolKey = PoolAddress.PoolKey(
            {
                token0: loanAssets[0],
                token1: loanAssets[1],
                fee: flashPoolFee
            }
        );
        address flashPool = getFlashPool(factory, poolKey);
        require(flashPool != address(0), "Invalid flash pool!");
        IUniswapV3Pool(flashPool).flash(
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
                calldatas
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
            Call[] memory calldatas
        ) = abi.decode(data, (FlashCallbackData, Call[]));
        require(msg.sender == getFlashPool(factory, callback.poolKey), "Only Pool can call!");
        
        address loanToken = callback.amount0 > 0 ? callback.poolKey.token0: callback.poolKey.token1;
        uint256 loanAmount = callback.amount0 > 0 ? callback.amount0: callback.amount1;
        uint256 fee = callback.amount0 > 0 ? fee0 : fee1;
        // start trade
        for (uint256 i = 0; i < calldatas.length; i++) {

           tradeExecute(payable(calldatas[i].to), calldatas[i].data);
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
    function tradeExecute(
        address payable to, 
        bytes memory data
    ) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = to.call(data);
        require(success, "Trading Failure!");
    }
    function getFlashPool(
        address _factory, 
        PoolAddress.PoolKey memory _poolKey
    ) internal pure returns (address) {
        return PoolAddress.computeAddress(_factory, _poolKey);
    }
    function changeFlashPoolFee(uint24 poolFee) public onlyOwner() {
        flashPoolFee = poolFee;
    }
    fallback() external payable {}
    receive() external payable {}
}
