// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.8.0;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IFlashLoanReceiver} from "../interfaces/aave/IFlashLoanReceiver.sol";
import {ILendingPoolAddressesProvider} from "../interfaces/aave/ILendingPoolAddressesProvider.sol";
import {ILendingPool} from "../interfaces/aave/ILendingPool.sol";

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
  ILendingPoolAddressesProvider public immutable override ADDRESSES_PROVIDER;
  ILendingPool public immutable override LENDING_POOL;

  constructor(ILendingPoolAddressesProvider provider) {
    ADDRESSES_PROVIDER = provider;
    LENDING_POOL = ILendingPool(provider.getLendingPool());
  }
}
