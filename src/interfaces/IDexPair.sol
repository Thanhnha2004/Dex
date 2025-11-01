// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IDexPair {

    // Events
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint256 reserve0, uint256 reserve1);

    // State-changing functions
    function initialize(address _token0, address _token1) external;
    function mint(address to) external returns(uint256 liquidity);
    function burn(address to) external returns(uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    // View functions
    function token0() external view returns(address);
    function token1() external view returns(address);
    function getReserves() external view returns(uint256 reserve0, uint256 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns(uint256);

    // LP Token functions (inherited from ERC20)
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
}