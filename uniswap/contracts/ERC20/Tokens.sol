// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor(string memory symbol, string memory name, uint amount) ERC20(symbol, name) {
        _mint(msg.sender, amount * uint(10 ** 18));
    }
}