pragma solidity >=0.8.0;

import { ERC4626 } from '@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol';
import { IERC20Metadata } from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract DRIP is ERC4626 {
  address constant renbtc = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;

  constructor() ERC4626(IERC20Metadata(renbtc)) ERC20("DRIP", "DRIP") {}

  function deposit(uint256 assets, address receiver, uint256 minOut) public returns (uint256 result) {
    uint256 balance = balanceOf(receiver);

    super.deposit(assets, receiver);
    result = balanceOf(receiver) - balance;

    require(result >= minOut, "Too little received");
  }

  function withdraw(uint256 assets, address receiver, address owner, uint256 minOut) public returns (uint256 result) {
    uint256 balance = IERC20(renbtc).balanceOf(receiver);

    super.withdraw(assets, receiver, owner);
    result = IERC20(renbtc).balanceOf(receiver) - balance;

    require(result >= minOut, "Too little received");
  }

  function mint(uint256 shares, address receiver, uint256 minOut) public returns (uint256 result) {
    uint256 balance = balanceOf(receiver);

    super.mint(shares, receiver);
    result = balanceOf(receiver) - balance;

    require(result >= minOut, "Too little received");
  }

  function redeem(uint256 shares, address receiver, address owner, uint256 minOut) public returns (uint256 result) {
    uint256 balance = IERC20(renbtc).balanceOf(receiver);

    super.redeem(shares, receiver, owner);
    result = IERC20(renbtc).balanceOf(receiver) - balance;

    require(result >= minOut, "Too little received");
  }

  // returns total number of assets
  // function totalAssets() public view override returns(uint256) {
  //   return asset.balanceOf(address(this));
  // }

  // TODO: _deposit and _withdraw need to interact with curve tricrypto2 to stake and unstake
  // TODO: make new mint and redeem functions that include minout


}