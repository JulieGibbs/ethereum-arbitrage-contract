// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;
import { IBalancerVault } from "../interfaces/IBalancerVault.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

contract BalancerswapRouter {
    IBalancerVault public balancerVault;
    
    event SwapedOnBalancer(address indexed _sender,  address indexed _assset, uint256 _amountOut);

    function balancerSingleSwap(
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
        require(amountOut > 0, "Singleswap failed on BalancerV2!");
        emit SwapedOnBalancer(recipient, path[1], amountOut);
    }
    function balancerBatchSwap(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        // Approve the router to spend token.
        uint256 tokenNumber = path.length;
        require(tokenNumber >= 2, "Invalid batch swap");
        TransferHelper.safeApprove(path[0], address(balancerVault), amountIn);
        IBalancerVault.BatchSwapStep[] memory batchSwapSteps = new IBalancerVault.BatchSwapStep[](tokenNumber - 1);
        int256[] memory limits = new int256[](tokenNumber - 1); 
        for (uint i; i < tokenNumber - 1; i++) {
            batchSwapSteps[i] = IBalancerVault.BatchSwapStep(
                {
                    poolId: "",
                    assetInIndex: i,
                    assetOutIndex: i + 1,
                    amount: i == 0 ? amountIn : amountOutMin,
                    userData: "0x"
                }
            );
            limits[i] = i == 0 ? int(amountIn) : int(amountOutMin);
        }
        IBalancerVault.FundManagement memory fundManagment = IBalancerVault.FundManagement(
            {
                sender: recipient,
                fromInternalBalance: false,
                recipient: payable(recipient),
                toInternalBalance: false
            }
        );
        amountOut = uint256(balancerVault.batchSwap(
            IBalancerVault.SwapKind.GIVEN_IN,
            batchSwapSteps,
            path,
            fundManagment,
            limits,
            deadline
        )[tokenNumber - 1]);
        require(amountOut > 0, "Batchswap failed on BalancerV2!");
        emit SwapedOnBalancer(recipient, path[tokenNumber - 1], amountOut);
    }
}