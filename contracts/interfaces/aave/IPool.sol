// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.0;
pragma experimental ABIEncoderV2;

interface IPool {
  
    function flashLoanSimple(
        address receiverAddress,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external;
}
