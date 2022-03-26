// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

interface IGateway {
  function burn(uint256 amount, bytes memory destination) external;
}
