// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.0;

import { IFlashLoanSimpleReceiver } from "../interfaces/aave/IFlashLoanSimpleReceiver.sol";
import { IPoolAddressesProvider } from "../interfaces/aave/IPoolAddressesProvider.sol";
import { IPool } from "../interfaces/aave/IPool.sol";
/**
 * @title FlashLoanSimpleReceiverBase
 * @author Aave
 * @notice Base contract to develop a flashloan-receiver contract.
 */
abstract contract FlashLoanSimpleReceiverBase is IFlashLoanSimpleReceiver {
    IPoolAddressesProvider public immutable override ADDRESSES_PROVIDER;
    IPool public immutable override POOL;

    constructor(IPoolAddressesProvider provider) {
        ADDRESSES_PROVIDER = provider;
        POOL = IPool(provider.getPool());
    }
}
