// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { TransferHelper } from "./TransferHelper.sol";
import { SafeMath } from "./SafeMath.sol";


library Helpers {
    using SafeMath for uint256;
    function getPaths(
        address _token0,
        address _token1
    ) internal pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = _token0;
        path[1] = _token1;
        return path;
    }
    function getSelector(string memory _functionName) internal pure returns (bytes4) {
        return bytes4(keccak256(bytes(_functionName)));
    }
    function withdraw(address token) internal {
    
        //     // transfor to owner 0.5% of profit
        //     uint256 ownerAmount = (amount.mul(5)).div(1000);
        //     TransferHelper.safeTransferFrom(
        //         token,
        //         from,
        //         owner,
        //         ownerAmount
        //     );
        //     // transfer to trader profit amounts of assets 
        //     TransferHelper.safeTransferFrom(token, from, to, amount.sub(ownerAmount));

        
        // // withdraw all ETH
        // (bool success, ) = owner.call{ value: from.balance }("");
        // require(success, "transfer failed");
    }
}