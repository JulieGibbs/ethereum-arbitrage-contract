// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

contract RouterConstant {
    
    // swap router id constants
    uint16 public constant UNISWAP_V3_ROUTER_ID = 1;
    uint16 public constant UNISWAP_V2_ROUTER_ID = 2;
    uint16 public constant SUSHISWAP_ROUTER_ID = 3;
    uint16 public constant SHIBASWAP_ROUTER_ID = 4;
    uint16 public constant DEFISWAP_ROUTER_ID = 5;
    uint16 public constant BANCOR_V3_ROUTER_ID = 6;
    uint16 public constant BALANCERSWAP_ROUTER_ID = 7;

    uint16 public constant DODODVM_ROUTER_ID = 8;
    uint16 public constant DODODPP_ROUTER_ID = 9;
    uint16 public constant DODODSP_ROUTER_ID = 10;
    uint16 public constant DODODCP_ROUTER_ID = 11;
    uint16 public constant MOONISWAP_ROUTER_ID = 12;
    uint16 public constant KYBERSWAP_V3_ROUTER_ID = 13;
    uint16 public constant KYBERSWAP_V2_ROUTER_ID = 14;
    uint16 public constant ONEINCHI_V4_ROUTER_ID = 15;
    uint16 public constant ONEINCHI_V3_ROUTER_ID = 16;
    uint16 public constant ONEINCHI_V2_ROUTER_ID = 17;

    string public constant UNIV3_ROUTER_FUNC = "exactInputSingle(ExactInputSingleParams calldata)";
    string public constant UNIV2_ROUTER_FUNC = "swapExactTokensForTokens(uint,uint,address[] calldata,address,uint)";
    string public constant DODOV2_ROUTER_FUNC = "dodoSwapV2TokenToToken(address,address,uint256,uint256,address[] memory,uint256,bool,uint256)";
    string public constant BANCORV3_ROUTER_FUNC = "tradeBySourceAmount(address,address,uint256,uint256,uint256,address)";
    string public constant MOONI_ROUTER_FUNC = "swap(address,address,uint256,uint256,address)";
    string public constant KYBER_ROUTER_FUNC = "swapExactInputSingle(ExactInputSingleParams calldata)";

    string public constant UNIV3_QUOTER_FUNC = "quoteExactInput(bytes memory,uint256)";
    string public constant UNIV2_QUOTER_FUNC = "getAmountsOut(uint256,address[] memory)";
    string public constant DODOV2_QUOTER_FUNC = "querySellBase(address,uint256)";
    string public constant BANCORV3_QUOTER_FUNC = "tradeOutputBySourceAmount(address,address,uint256)";
    string public constant MOONI_QUOTER_FUNC = "getReturn(address,address,uint256)";
    string public constant KYBER_QUOTER_FUNC = "quoteExactInput(bytes memory,uint256)";
}