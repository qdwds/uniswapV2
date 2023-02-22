// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Uni is ERC20 {
    constructor() ERC20("Uniswap", "UNI") {
        _mint(msg.sender, 100000000 * uint(10 ** 18));
    }
}