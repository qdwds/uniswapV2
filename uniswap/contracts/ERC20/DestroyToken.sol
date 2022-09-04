// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DestroyToken is ERC20 {
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    constructor(uint256 amount) ERC20("DestroyToken", "DT") {
        _mint(msg.sender, amount * uint(10 ** 18));
    }

    function transfer(address to, uint256 _amount) public virtual override returns (bool) {
        address owner = _msgSender();
        uint256 fee = _amount * 10 / 100;
        uint256 amount = _amount - fee;
        _transfer(owner, DEAD, fee);
        _transfer(owner, to, amount);
        return true;
    }
}