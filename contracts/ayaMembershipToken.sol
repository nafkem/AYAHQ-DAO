// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AyaMembershipToken is ERC20, Ownable {
    constructor() ERC20("AyaMembershipToken", "AYAM") {
        _mint(address(this), 1500000000 * 10 ** decimals());
    }

    /*
     * NOTE: Only contract deployer can call the transfer function: it is a non transferable token.
     */
    function transfer(address recipient, uint256 amount) public onlyOwner override returns (bool) {
        return super.transfer(recipient, amount);
    }

     /*
     * NOTE: Only contract deployer can call the transferFrom function: it is a non transferable token.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public onlyOwner override returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    // function for the deployer to mint token to users.
    function mint(address to, uint256 amount) public onlyOwner {
        uint bal = balanceOf(address(this));
        require(bal >= amount, "CONTRACT BALANCE LOW!");
        _transfer(address(this), to, amount);
    }


}