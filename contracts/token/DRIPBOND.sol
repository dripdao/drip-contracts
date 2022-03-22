import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DRIPBOND is ERC721Upgradeable, OwnableUpgradeable {
  using SafeERC20 for IERC20;
  using SafeMath for *;
  uint256 count;
  address drip;
  address treasury;
  mapping (uint256 => uint256) public locked;
  mapping (uint256 => uint256) public unlockAt;
  uint256 public rate;
  uint256 public maturesAfter;
  function initialize(address _treasury, address _drip, uint256 _rate) public {
    __ERC721_init("DRIPBOND", "DRIPBOND");
    treasury = _treasury;
    drip = _drip;
    rate = _rate;
    count = 0;
    maturesAfter = 60*60*24*30;
  }
  function setMaturity(uint256 _maturesAfter) public onlyOwner {
    maturesAfter = _maturesAfter;
  }
  function mint(uint256 amount) public {
    _mint(msg.sender, count);
    IERC20(drip).safeTransferFrom(msg.sender, treasury, amount);
    locked[count] = amount;
    unlockAt[count] = block.timestamp + maturesAfter;
    count++;
  }
  function computeMatureValue(uint256 input) internal view returns (uint256) {
    return input.mul(uint256(1 ether).add(rate)).div(uint256(1 ether));
  }
  function burn(uint256 idx) public {
    require(unlockAt[idx] <= block.timestamp, "!matured");
    _burn(idx);
    IERC20(drip).safeTransferFrom(treasury, msg.sender, computeMatureValue(locked[idx]));
  }
}
