// SPDX-License-Identifier: MIT;
pragma solidity >=0.7.6;
pragma experimental ABIEncoderV2;
import { IAggregationRouterV4, IAggregationExecutor, IERC20 } from "../interfaces/IOneinchRouter.sol";
contract MockSwap {
    IAggregationExecutor public executor;
    IAggregationRouterV4 public router;
    address public tokenIn;
    address public tokenOut;
    address payable recipient;
    uint256 public amountIn;
    uint256 public amountOut;
    function init(bytes calldata data) external {
        (
            IAggregationExecutor exeCall,
            IAggregationRouterV4.SwapDescription memory swapDesc,
            bytes memory datas
        ) = abi.decode(data, (IAggregationExecutor, IAggregationRouterV4.SwapDescription, bytes));

        swapToken(exeCall, swapDesc, datas);
    }
    function swapToken(
        IAggregationExecutor caller,
        IAggregationRouterV4.SwapDescription memory desc,
        bytes memory data
    )
        public
        payable returns (
            uint256 returnAmount,
            uint256 spentAmount,
            uint256 gasLeft
    )
    {
        executor = caller;
        tokenIn = address(desc.srcToken);
        tokenOut = address(desc.dstToken);
        recipient = desc.dstReceiver;
        amountIn = desc.amount;
        
    }
    function unoswap(
        IERC20 srcToken,
        uint256 _amount,
        uint256 minReturn,
        // solhint-disable-next-line no-unused-vars
        bytes32[] calldata pools
    ) public payable returns(uint256 returnAmount) {
        tokenIn = address(srcToken);
        amountIn = _amount;
        amountOut = minReturn;
    }
    function clipperSwap(
        IERC20 srcToken,
        IERC20 dstToken,
        uint256 amount,
        uint256 minReturn
    ) external payable returns(uint256 returnAmount) {
        tokenIn = address(srcToken);
        tokenOut = address(dstToken);
        amountIn = amount;
        amountOut = minReturn;
    }
    function uniswapV3Swap(
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external payable returns(uint256 returnAmount) {
        amountIn = amount;
        amountOut = minReturn;
    }
}