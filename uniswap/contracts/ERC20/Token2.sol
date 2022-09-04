// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token2 is ERC20 {
    constructor() ERC20("Token Coin 2", "t2") {
        _mint(msg.sender, 10000000 * uint(10 ** 18));
    }
}