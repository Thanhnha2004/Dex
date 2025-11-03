// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/// @title Test Token H
/// @notice ERC20 token for testing
contract TokenHMG is ERC20 {
    /// @notice Deploy with initial supply
    /// @param initialSupply Amount minted to deployer
    constructor(uint256 initialSupply) ERC20("TokenHMG", "HMG") {
        _mint(msg.sender, initialSupply);
    }
}
