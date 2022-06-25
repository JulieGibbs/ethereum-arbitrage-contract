// SPDX-License-Identifier: MIT;
pragma solidity >=0.7.6;

interface IUniswapFlash {
    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address payer;
        PoolAddress.PoolKey poolKey;
        // uint24 poolFee2;
        // uint24 poolFee3;
    }
    mapping(uint16 => RouterInfo) public routerInfos;
    event FalshloanInited(
        address indexed _loanAsset,
        uint256 _loanAmount,
        address indexed _tradeAsset,
        uint16 _tradeDex
    );
    event AssetBorrowedFromPool(
        address indexed _pool,
        address indexed _loanAsset,
        uint256 _loanAmount,
        uint256 _fee
    );
    event AssetSwaped(
        address indexed _swapAsset,
        uint256 _swapAmount
    );
    event RepayedAssetToPool(
        address indexed _pool,
        address indexed _repayedAsset,
        uint256 _repayedAmount
    );
    event TransferProfitToWallet(
        address indexed _owner,
        address indexed _profitAsset,
        uint256 _profitAmount
    );
    event ChangedFlashPoolFee(address indexed _sender, uint24 _fee);

    function initUniFlashSwap(
        address[] calldata loanAssets,
        uint256[] calldata loanAmounts,
        address[] calldata tradeAssets,
        uint16[] calldata tradeDexes
    ) external;
}