// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TokenHMG is ERC20 {
    constructor(uint256 initialSupply) ERC20("TokenHMG", "HMG") {
        _mint(msg.sender, initialSupply);
    }
}
