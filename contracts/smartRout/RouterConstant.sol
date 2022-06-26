// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
import { UniV2Adapter, IUniswapV2Router02 } from "./adapters/UniV2Adapter.sol";
import { UniV3Adapter, IQuoter } from "./adapters/UniV3Adapter.sol";
import { DodoV2Adapter, IDODOFactory, IDCPFactory } from "./adapters/DodoV2Adapter.sol";
import { BancorV3Adapter, IBancorNetworkInfo } from "./adapters/BancorV3Adapter.sol";
import { KyberAdapter, IQuoterV2 } from "./adapters/KyberAdapter.sol";
import { MooniAdapter, IMooniFactory } from "./adapters/MooniAdapter.sol";
contract RouterConstant is 
    UniV2Adapter, 
    UniV3Adapter, 
    DodoV2Adapter,
    BancorV3Adapter,
    KyberAdapter,
    MooniAdapter {
    
    // swap router id constants
    uint16 public constant UNISWAP_V3_ROUTER_ID = 1;
    uint16 public constant UNISWAP_V2_ROUTER_ID = 2;
    uint16 public constant SUSHISWAP_ROUTER_ID = 3;
    uint16 public constant SHIBASWAP_ROUTER_ID = 4;
    uint16 public constant DEFISWAP_ROUTER_ID = 5;

    uint16 public constant DODODVM_ROUTER_ID = 6;
    uint16 public constant DODODPP_ROUTER_ID = 7;
    uint16 public constant DODODSP_ROUTER_ID = 8;
    uint16 public constant DODODCP_ROUTER_ID = 9;
    uint16 public constant BANCOR_V3_ROUTER_ID = 10;
    uint16 public constant KYBERSWAP_ROUTER_ID = 11;
    uint16 public constant MOONISWAP_ROUTER_ID = 12;

    uint16 public constant ONEINCHISWAP_ROUTER_ID = 13;
    uint16 public constant BALANCERSWAP_ROUTER_ID = 14;

    // function initRoterInstances() internal {
    //     for (uint i = 1; i <= uniswapFlash.routerInfos.length; i++) {
    //         if(UNISWAP_V2_ROUTER_ID  == i) {
    //             uniV2Quoter = IUniswapV2Router02(
    //                 uniswapFlash.routerInfos[UNISWAP_V2_ROUTER_ID].quoter
    //             );
    //         }
    //         if(UNISWAP_V3_ROUTER_ID  == i) {
    //             uniV3Quoter = IQuoter(
    //                 uniswapFlash.routerInfos[UNISWAP_V3_ROUTER_ID].quoter
    //             );
    //         }
    //         sushiQuoter = IUniswapV2Router02(
    //             uniswapFlash.routerInfos[SUSHISWAP_ROUTER_ID].quoter
    //         );
    //         shibaQuoter = IUniswapV2Router02(
    //             uniswapFlash.routerInfos[SHIBASWAP_ROUTER_ID].quoter
    //         );
    //         defiQuoter = IUniswapV2Router02(
    //             uniswapFlash.routerInfos[DEFISWAP_ROUTER_ID].quoter
    //         );
    //         dodoDVMQuoter = IDODOFactory(
    //             uniswapFlash.routerInfos[DODODVM_ROUTER_ID].quoter
    //         );
    //         dodoDPPQuoter = IDODOFactory(
    //             uniswapFlash.routerInfos[DODODPP_ROUTER_ID].quoter
    //         );
    //         dodoDSPQuoter = IDODOFactory(
    //             uniswapFlash.routerInfos[DODODSP_ROUTER_ID].quoter
    //         );
    //         dodoDCPQuoter = IDODOFactory(
    //             uniswapFlash.routerInfos[DODODCP_ROUTER_ID].quoter
    //         );
    //         bancorV3Quoter = IBancorNetworkInfo(
    //             uniswapFlash.routerInfos[BANCOR_V3_ROUTER_ID].quoter
    //         );
    //         kyberQuoter = IQuoterV2(
    //             uniswapFlash.routerInfos[KYBERSWAP_ROUTER_ID].quoter
    //         );
    //         mooniQuoter = IMooniFactory(
    //             uniswapFlash.routerInfos[MOONISWAP_ROUTER_ID].quoter
    //         );
    //     }
    // }
}