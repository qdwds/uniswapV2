// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token3 is ERC20 {
    constructor() ERC20("Token Coin 3", "t3") {
        _mint(msg.sender, 1000000000 * uint(10 ** 18));
    }
}