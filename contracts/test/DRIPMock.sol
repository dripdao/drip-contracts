// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;


import { DRIP } from "../token/DRIP.sol";

contract DRIPMock is DRIP {
  function permission(address source, address target, uint256 amount) public {
    _approve(source, target, amount);
  }
}
