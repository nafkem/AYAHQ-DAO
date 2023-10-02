// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Ayatoken is ERC20, Ownable {
    constructor() ERC20("Ayatoken", "AYAX") {
        _mint(address(this), 1500000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        uint bal = balanceOf(address(this));
        require(bal >= amount, "CONTRACT BALANCE LOW!");
        _transfer(address(this), to, amount);
    }
}