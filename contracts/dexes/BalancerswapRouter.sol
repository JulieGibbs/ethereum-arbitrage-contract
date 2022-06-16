// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;
import { IBalancerVault } from "../interfaces/IBalancerVault.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract BalancerswapRouter {
    IBalancerVault public balancerVault;
    event SwapedOnBalancer(address indexed _sender,  address indexed _assset, uint256 _amountOut);

    function balancerSwap(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        // Approve the router to spend token.
        TransferHelper.safeApprove(path[0], address(balancerVault), amountIn);
        IBalancerVault.SingleSwap memory singleSwap = IBalancerVault.SingleSwap(
            {
                poolId: "",
                kind: IBalancerVault.SwapKind.GIVEN_IN,
                assetIn: path[0],
                assetOut: path[1],
                amount: amountIn,
                userData: "0x"
            }
        );
        IBalancerVault.FundManagement memory fundManagment = IBalancerVault.FundManagement(
            {
                sender: recipient,
                fromInternalBalance: false,
                recipient: payable(recipient),
                toInternalBalance: false
            }
        );
        amountOut = balancerVault.swap(
            singleSwap,
            fundManagment,
            amountOutMin,
            uint256(deadline)
        );
        require(amountOut > 0, "Swap failed on Balancerswap!");
        emit SwapedOnBalancer(recipient, path[1], amountOut);
    } 
}