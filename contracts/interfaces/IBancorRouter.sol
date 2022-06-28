// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
interface IBancorNetwork {
    function tradeBySourceAmount(
        address sourceToken,
        address targetToken,
        uint256 sourceAmount,
        uint256 minReturnAmount,
        uint256 deadline,
        address beneficiary
    ) external payable returns (uint256);
    function flashLoan(
        address token,
        uint256 amount,
        IFlashLoanRecipient recipient,
        bytes calldata data
    ) external;
}
interface IFlashLoanRecipient {
    /**
     * @dev a flash-loan recipient callback after each the caller must return the borrowed amount and an additional fee
     */
    function onFlashLoan(
        address caller,
        IERC20 erc20Token,
        uint256 amount,
        uint256 feeAmount,
        bytes memory data
    ) external;
}
interface IBancorNetworkInfo {
    function tradeOutputBySourceAmount(
        address sourceToken,
        address targetToken,
        uint256 sourceAmount
    ) external view returns (uint256);
}