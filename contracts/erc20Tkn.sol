// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20{
    constructor() public  ERC20("ULOR","ULO"){
        _mint(msg.sender,(500000000000) * (10 ** uint256(decimals() )));
        
    }
}