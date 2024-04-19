// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CastyToken is ERC20, ERC20Burnable, ERC20Pausable, ERC20Permit, ERC20Votes, Ownable {
  string public constant TOKEN_NAME = "CastyToken";
  string public constant TOKEN_SYMBOL = "TY";
  uint256 public constant TOKEN_INITIAL_SUPPLY = 10_000_000_000;

  constructor() ERC20(TOKEN_NAME, TOKEN_SYMBOL) ERC20Permit(TOKEN_NAME) Ownable(msg.sender) {
    _mint(msg.sender, TOKEN_INITIAL_SUPPLY * 10 ** decimals());
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
  }

  function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
    return super.nonces(owner);
  }

  function _update(
    address from,
    address to,
    uint256 value
  ) internal override(ERC20, ERC20Pausable, ERC20Votes) {
    super._update(from, to, value);
  }
}
