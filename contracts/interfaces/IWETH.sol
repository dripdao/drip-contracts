// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract IWETH is IERC20 {
  function deposit() virtual external payable;
  function withdraw(uint256) virtual external;
}
  
