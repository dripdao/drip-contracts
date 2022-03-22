// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;


import { ERC20PermitUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";

contract DRIP is ERC20PermitUpgradeable {
  function initialize() public {
    __ERC20_init("DRIP", "DRIP");
  }
}
