pragma solidity >=0.8.0;

import { ERC4626 } from '@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol';

import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { SafeERC20 } from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import { IERC20Metadata } from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

import { IRENCRV } from './interfaces/IRENCRV.sol';
import { ITRICRYPTO2 } from './interfaces/ITRICRYPTO2.sol';

contract DRIP is ERC4626 {
  address constant renbtc = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
  address constant wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

  address constant renCrvPool = 0x93054188d876f558f4a66B2EF1d97d16eDf0895B;
  address constant renCrvLp = 0x49849C98ae39Fff122806C06791Fa73784FB3675;

  address constant triCrypto2Pool = 0xD51a44d3FaE010294C616388b506AcdA1bfAAE46;
  address constant triCrypto2Token = 0xc4AD29ba4B3c580e6D59105FFf484999997675Ff;

  constructor() ERC4626(IERC20Metadata(renbtc)) ERC20("DRIP", "DRIP") {
    // IERC20 approve renbtc spend on ren curve contracts
    IERC20(renbtc).approve(renCrvPool, type(uint256).max);
    IERC20(wbtc).approve(triCrypto2Pool, type(uint256).max);
  }

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
  function totalAssets() public view virtual override returns (uint256) {
    // get lp tokens balance in this vault
    uint256 balance = IERC20(triCrypto2Token).balanceOf(address(this));
    // convert to wbtc
    uint256 converted = ITRICRYPTO2(triCrypto2Pool).calc_withdraw_one_coin(balance, 1);
    return IRENCRV(renCrvLp).get_dy(1, 0, converted);
  }

  function _deposit(
    address caller,
    address receiver,
    uint256 assets,
    uint256 shares
  ) internal virtual override {
    SafeERC20.safeTransferFrom(IERC20(asset()), caller, address(this), assets);
    _mint(receiver, shares);

    // swap renbtc --> wbtc --> tricrypto2 LP
    // make low-level call instead of .exchange()
    // use abi coder to make a low level call --> returns boolean followed by bytes mem

    // renbtc --> wbtc
    (bool renSuccess, ) = renCrvPool.call{gas:gasleft()} (abi.encodeWithSelector(IRENCRV.exchange.selector, 0, 1, assets, 1));
    require(renSuccess, "RenCrv reverted.");

    // wbtc --> tricrypto2 LP
    uint256[3] memory amounts = [ 0, IERC20(wbtc).balanceOf(address(this)), 0 ];
    (bool triSuccess, ) = triCrypto2Pool.call{gas:gasleft()} (abi.encodeWithSelector(ITRICRYPTO2.add_liquidity.selector, amounts, 1));
    require(triSuccess, "triCrypto2 reverted.");

    emit Deposit(caller, receiver, assets, shares);
  }

  function _withdraw(
    address caller,
    address receiver,
    address owner,
    uint256 assets,
    uint256 shares
  ) internal virtual override {
    if (caller != owner) {
        _spendAllowance(owner, caller, shares);
    }

    // TODO: convert LP tokens --> WBTC --> renBTC

    _burn(owner, shares);
    SafeERC20.safeTransfer(IERC20(asset()), receiver, assets);

    emit Withdraw(caller, receiver, owner, assets, shares);
  }
}