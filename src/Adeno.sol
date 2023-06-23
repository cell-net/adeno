// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin/security/Pausable.sol";
import "openzeppelin/access/Ownable.sol";

contract Adeno is ERC20, ERC20Burnable, Pausable, Ownable {
    uint256 public maxSupply;
    mapping(address => bool) public whitelist;

    constructor(uint256 _maxSupply) ERC20("Adeno", "ADE") {
        whitelist[_msgSender()] = true;
        maxSupply = _maxSupply;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyWhitelisted {
        require(totalSupply() + amount <= maxSupply, "Exceeds mint supply");
        _mint(to, amount);
    }

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Sender is not whitelisted");
        _;
    }

    function addToWhitelist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            whitelist[addr] = true;
        }
    }

    function removeFromWhitelist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            whitelist[addr] = false;
        }
    }
}
