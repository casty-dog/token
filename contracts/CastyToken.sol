// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ICastyToken {
  function pause() external;
  function unpause() external;
  function mint(address to, uint256 amount) external;
  function nonces(address owner) external view returns (uint256);
  function mintableAmount() external view returns (uint256);
}

contract CastyToken is
  ICastyToken,
  ERC20,
  ERC20Burnable,
  ERC20Pausable,
  ERC20Permit,
  ERC20Votes,
  Ownable
{
  string public constant TOKEN_NAME = "CastyToken";
  string public constant TOKEN_SYMBOL = "TY";

  uint256 public constant MINIMUM_TIME_BETWEEN_MINTS = 1 days * 30;
  uint256 public constant PRIMARY_MINT_CAP = 2;
  uint256 public constant SECONDARY_MINT_CAP = 1;
  uint256 public constant PRIMARY_MINT_TIMES = 10;
  uint256 public constant SECONDARY_MINT_TIMES = 20;

  // @dev MAX_SUPPLY is calculated as follows:
  //   INITIAL_SUPPLY *
  //     (1 + (PRIMARY_MINT_CAP * PRIMARY_MINT_TIMES + SECONDARY_MINT_CAP * SECONDARY_MINT_TIMES) / 100);
  uint256 public constant MAX_SUPPLY = 14_000_000_000;
  uint256 public constant INITIAL_SUPPLY = 10_000_000_000;

  uint256 private _mintedCount = 0;
  uint256 private _initialSuppliedAt = 0;

  error ZeroAddressBlocked();
  error MintExceedsMintableAmount();
  error MintExceedsMaxSupply();

  event Minted(address indexed to, uint256 amount);

  /**
   * @dev Throws if the address is zero.
   */
  modifier nonZeroAddress(address addr) {
    if (addr == address(0)) {
      revert ZeroAddressBlocked();
    }
    _;
  }

  constructor() ERC20(TOKEN_NAME, TOKEN_SYMBOL) ERC20Permit(TOKEN_NAME) Ownable(msg.sender) {
    _mint(msg.sender, INITIAL_SUPPLY * 10 ** decimals());
    _initialSuppliedAt = block.timestamp;
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  function mint(address to_, uint256 amount_) public onlyOwner nonZeroAddress(to_) {
    if (mintableAmount() > amount_) {
      revert MintExceedsMintableAmount();
    }

    _mintToken(to_, amount_);
    _mintedCount += 1;

    emit Minted(to_, amount_);
  }

  function nonces(
    address owner_
  ) public view override(ICastyToken, ERC20Permit, Nonces) returns (uint256) {
    return super.nonces(owner_);
  }

  function mintableAmount() public view returns (uint256) {
    uint256 mintableTimes_ = (block.timestamp - _initialSuppliedAt) / MINIMUM_TIME_BETWEEN_MINTS;
    uint256 primaryCount = mintableTimes_;
    uint256 secondaryCount = 0;

    if (mintableTimes_ >= PRIMARY_MINT_TIMES) {
      primaryCount = PRIMARY_MINT_TIMES;
      secondaryCount = mintableTimes_ - PRIMARY_MINT_TIMES;
    }
    if (secondaryCount >= SECONDARY_MINT_TIMES) {
      secondaryCount = SECONDARY_MINT_TIMES;
    }

    uint256 primary = primaryCount * PRIMARY_MINT_CAP * INITIAL_SUPPLY;
    uint256 secondary = secondaryCount * SECONDARY_MINT_CAP * INITIAL_SUPPLY;
    uint256 suppliable = INITIAL_SUPPLY + (primary + secondary) / 100;

    return suppliable * 10 ** decimals() - totalSupply();
  }

  function _mintToken(address to_, uint256 amount_) internal {
    if (totalSupply() + amount_ > MAX_SUPPLY * 10 ** decimals()) {
      revert MintExceedsMaxSupply();
    }

    super._mint(to_, amount_);
  }

  function _update(
    address from_,
    address to_,
    uint256 value_
  ) internal override(ERC20, ERC20Pausable, ERC20Votes) {
    super._update(from_, to_, value_);
  }
}
