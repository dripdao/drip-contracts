// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV2Router02 } from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IGateway } from "../interfaces/IGateway.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { IWETH } from "../interfaces/IWETH.sol";

contract DRIPBOND is ERC721Upgradeable, OwnableUpgradeable {
  using SafeERC20 for IERC20;
  using SafeMath for *;
  struct DripBond {
    bool spent;
    uint64 maturesAt;
    uint128 initValue;
    uint256 rate;
  }
  event DripBondMinted(address indexed holder, uint256 indexed bond, uint256 initValue, uint256 maturesAt);
  event DripBondBurned(address indexed holder, uint256 indexed bond, uint256 maturedValue);
  uint256 public count;
  address public constant drip = 0x0d44CfA6a50E4C16eE311af6EDAD36E89f90b0a6;
  address public constant treasury = 0x592E10267af60894086d40DcC55Fe7684F8420D5;
  address public constant router = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
  address public constant factory = 0xc35DADB65012eC5796536bD9864eD8773aBc74C4;
  address public constant weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
  address public constant renbtc = 0xDBf31dF14B66535aF65AaC99C32e9eA844e14501;
  address public constant gateway = 0x05Cadbf3128BcB7f2b89F3dD55E5B0a036a49e20;
  mapping (uint256 => DripBond) public bonds;
  uint256 public rate;
  uint256 public target;
  uint256 public maturesAfter;
  function initialize() public initializer {
    __ERC721_init("DRIPBOND", "DRIPBOND");
    rate = 2e16;
    count = 0;
    target = 4e15;
    maturesAfter = 60*60*24*30;
    IERC20(drip).approve(router, uint256(int256(~0)));
    IERC20(weth).approve(router, uint256(int256(~0)));
    IERC20(renbtc).approve(gateway, uint256(int256(~0)));
  }
  function setTarget(uint256 _target) public onlyOwner {
    target = _target;
  }
  function setRate(uint256 _rate) public onlyOwner {
    rate = _rate;
  }
  function setMaturity(uint256 _maturesAfter) public onlyOwner {
    maturesAfter = _maturesAfter;
  }
  function computeTargetDRIP(uint256 ethAmount) public view returns (uint256) {
    return ethAmount.mul(uint256(1 ether)).div(target);
  }
  function mint() public payable returns (uint256) {
    uint256 _count = count;
    require(msg.value != 0, "!enough-eth");
    uint256 dripAmount = computeTargetDRIP(msg.value);
    require(dripAmount != 0, "!enough-drip");
    IERC20(drip).safeTransferFrom(treasury, address(this), dripAmount);
    (uint256 amountToken,,) = IUniswapV2Router02(router).addLiquidityETH{ value: msg.value }(
      drip,
      dripAmount,
      uint256(1),
      msg.value,
      treasury,
      block.timestamp + 1
    );
    uint256 maturesAt = block.timestamp + maturesAfter;
    bonds[_count] = DripBond({
      spent: false,
      initValue: uint128(amountToken),
      maturesAt: uint64(maturesAt),
      rate: rate
    });
    emit DripBondMinted(msg.sender, _count, amountToken, maturesAt);
    _mint(msg.sender, count);
    count++;
    return bonds[count - 1].initValue;
  }
  function computeMatureValue(uint256 input, uint256 _rate) internal pure returns (uint256) {
    return input.mul(uint256(1 ether).add(_rate)).div(uint256(1 ether));
  }
  function _burnBond(uint256 idx) internal returns (uint256 maturedValue) {
    require(ownerOf(idx) == msg.sender, "!owner");
    require(bonds[idx].maturesAt <= block.timestamp, "!matured");
    require(!bonds[idx].spent, "spent");
    bonds[idx].spent = true;
    _burn(idx);
    maturedValue = computeMatureValue(bonds[idx].initValue, bonds[idx].rate);
    emit DripBondBurned(msg.sender, idx, maturedValue); 
  }
  function burn(uint256 idx) public {
    uint256 maturedValue = _burnBond(idx);
    IERC20(drip).safeTransferFrom(treasury, msg.sender, maturedValue);
  }
  function burnToBTC(uint256 idx, bytes memory destination) public payable {
    uint256 maturedValue = _burnBond(idx);
    IERC20(drip).safeTransferFrom(treasury, address(this), maturedValue);
    address[] memory path = new address[](2);
    path[0] = drip;
    path[1] = weth;
    uint256[] memory out = IUniswapV2Router02(router).swapExactTokensForTokens(maturedValue, 1, path, address(this), block.timestamp + 1);
    uint256 wethAmount = out[1];
    if (msg.value != 0) {
      IWETH(weth).deposit{ value: msg.value }();
      wethAmount = wethAmount.add(msg.value);
    }
    path[0] = weth;
    path[1] = renbtc;
    out = IUniswapV2Router02(router).swapExactTokensForTokens(wethAmount, 1, path, address(this), block.timestamp + 1);
    IGateway(gateway).burn(out[1], destination);
  }
}
