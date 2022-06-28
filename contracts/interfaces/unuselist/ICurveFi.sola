// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

interface ICurveFi {
    function coins(int128 index) external returns (address);
    function get_virtual_price() external view returns (uint256);
    function calc_token_amount(uint256[] memory _amounts, bool _is_deposit) external view returns (uint256);
    function get_dy(int128 i, int128 j, uint256 _dx) external view returns (uint256);
    function get_dx(int128 i, int128 j, uint256 _dy) external view returns (uint256);
    function get_dy_underlying(int128 i, int128 j, uint256 _dx) external view returns (uint256);
    function get_dx_underlying(int128 i, int128 j, uint256 _dy) external view returns (uint256);
    function exchange(
        int128 i,
        int128 j,
        uint256 _dx,
        uint256 _min_dy
    ) external returns (uint256);
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 _dx,
        uint256 _min_dy
    ) external returns (uint256);
}