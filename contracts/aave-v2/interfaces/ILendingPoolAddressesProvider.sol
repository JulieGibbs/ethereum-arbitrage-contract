// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.7.6;
interface ILendingPoolAddressesProvider {
    
    function getLendingPool() external view returns (address);
}
