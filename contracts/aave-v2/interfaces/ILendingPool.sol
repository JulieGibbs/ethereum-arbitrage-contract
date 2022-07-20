// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.7.6;
pragma experimental ABIEncoderV2;

interface ILendingPool {
  
    function flashLoan(
      address receiverAddress,
      address[] calldata assets,
      uint256[] calldata amounts,
      uint256[] calldata modes,
      address onBehalfOf,
      bytes calldata params,
      uint16 referralCode
    ) external;
}
