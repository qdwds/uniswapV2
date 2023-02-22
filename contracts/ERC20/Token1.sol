// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token1 is ERC20 {
    constructor() ERC20("Token Coin 1", "t1") {
        _mint(msg.sender, 100000 * uint(10 ** 18));
    }
}