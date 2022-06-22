// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import { IDODOV2, IDODOApprove, IDODOV2Proxy, IDVMFactory} from "../interfaces/IDODO.sol";
import { TransferHelper } from "../utils/TransferHelper.sol";

/*
    There are six swap functions in DODOProxy. Which are executed for different sources or versions
    
    - dodoSwapV1: Used for DODOV1 pools
    - dodoSwapV2ETHToToken: Used for DODOV2 pools and specify ETH as fromToken
    - dodoSwapV2TokenToETH: Used for DODOV2 pools and specify ETH as toToken
    - dodoSwapV2TokenToToken:  Used for DODOV2 pools and both fromToken and toToken are ERC20
    - externalSwap: Used for executing third-party protocols' aggregation algorithm
    - mixSwap: Used for executing DODO’s custom aggregation algorithm
    Note: Best Trading path is calculated by off-chain program. DODOProxy's swap functions is only used for executing.
*/
contract DodoswapRouter {
   
    IDODOV2Proxy public dodoswapProxy;
    address public dodoApprove;
    IDVMFactory public dvmFactory;
    event SwapedOnDodo(address indexed _sender, address indexed _assset, uint256 _amountOut);

    function dodoSwapV2(
        address recipient,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        uint64 deadline
    ) internal returns (uint256 amountOut) {
        // address dodoV2Pool = 0xD534fAE679f7F02364D177E9D44F1D15963c0Dd7; //BSC DODO - WBNB (DODO as BaseToken, WBNB as QuoteToken)
        // address fromToken = 0x67ee3Cb086F8a16f34beE3ca72FAD36F7Db929e2; //BSC DODO
        // address toToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //BSC WBNB
        // uint256 fromTokenAmount = 1e18; //sellBaseAmount
        // uint256 slippage = 1;
        require(dodoApprove != address(0), "Invalid Dodo Approve!");
        /*
            Note: (only used for DODOV2 pool)
            Users can estimate prices before spending gas. Include two situations
            Sell baseToken and estimate received quoteToken 
            Sell quoteToken and estimate received baseToken
            DODOV2 Pool contract provides two view functions. Users can use directly.
            function querySellBase(address trader, uint256 payBaseAmount) external view  returns (uint256 receiveQuoteAmount,uint256 mtFee);
            function querySellQuote(address trader, uint256 payQuoteAmount) external view  returns (uint256 receiveBaseAmount,uint256 mtFee);
        */

        // IERC20(fromToken).transferFrom(msg.sender, address(this), fromTokenAmount);
        // (uint256 receivedQuoteAmount,) = IDODOV2(dodoV2Pool).querySellBase(msg.sender, fromTokenAmount);
        // uint256 minReturnAmount = receivedQuoteAmount.mul(100 - slippage).div(100);
        address dodoV2Pool = dvmFactory.getDODOPool(path[0], path[1])[0];
        address[] memory dodoPairs = new address[](1); //one-hop
        dodoPairs[0] = dodoV2Pool;
        
        /*
            Note: Differentiate sellBaseToken or sellQuoteToken. If sellBaseToken represents 0, sellQuoteToken represents 1. 
            At the same time, dodoSwapV1 supports multi-hop linear routing, so here we use 0,1 combination to represent the multi-hop directions to save gas consumption
            For example: 
                A - B - C (A - B sellBase and  B - C sellQuote)  Binary: 10, Decimal 2 (directions = 2)
                D - E - F (D - E sellQuote and E - F sellBase) Binary: 01, Decimal 1 (directions = 1) 
        */
        uint256 directions = IDODOV2(dodoV2Pool)._BASE_TOKEN_() == path[0] ? 0 : 1;
        /*
            Note: Users need to authorize their sellToken to DODOApprove contract before executing the trade.
            ETH DODOApprove: 0xCB859eA579b28e02B87A1FDE08d087ab9dbE5149
            BSC DODOApprove: 0xa128Ba44B2738A558A1fdC06d6303d52D3Cef8c1
            Polygon DODOApprove: 0x6D310348d5c12009854DFCf72e0DF9027e8cb4f4
            Heco DODOApprove: 0x68b6c06Ac8Aa359868393724d25D871921E97293
            Arbitrum DODOApprove: 0xA867241cDC8d3b0C07C85cC06F25a0cD3b5474d8
        */
        // dodoApprove = 0xCB859eA579b28e02B87A1FDE08d087ab9dbE5149;
        // _generalApproveMax(path[0], dodoApprove, amountIn);
        TransferHelper.safeApprove(path[0], dodoApprove, amountIn);


        /*
            ETH DODOV2Proxy: 0xa356867fDCEa8e71AEaF87805808803806231FdC
            BSC DODOV2Proxy: 0x8F8Dd7DB1bDA5eD3da8C9daf3bfa471c12d58486
            Polygon DODOV2Proxy: 0xa222e6a71D1A1Dd5F279805fbe38d5329C1d0e70
            Heco DODOV2Proxy: 0xAc7cC7d2374492De2D1ce21e2FEcA26EB0d113e7
            Arbitrum DODOV2Proxy: 0x88CBf433471A0CD8240D2a12354362988b4593E5
        */
        // address dodoProxy = 0x8F8Dd7DB1bDA5eD3da8C9daf3bfa471c12d58486;
 
        amountOut = IDODOV2Proxy(dodoswapProxy).dodoSwapV2TokenToToken(
            path[0],
            path[1],
            amountIn,
            amountOutMin,
            dodoPairs,
            directions,
            false,
            deadline
        );
        TransferHelper.safeTransfer(path[1], recipient, amountOut);
        emit SwapedOnDodo(recipient, path[1], amountOut);
    }
    function setDodoApprove(address _dodoApprove) external {
        dodoApprove = _dodoApprove;
    }
}