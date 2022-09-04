// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token0 is ERC20 {
    constructor() ERC20("Token Coin 0", "t0") {
        _mint(msg.sender, 1000 * uint(10 ** 18));
    }
}