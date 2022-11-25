// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IAntisnipe {
    function assureCanTransfer(
        address sender,
        address from,
        address to,
        uint256 amount
    ) external;
}

contract EXT is ERC20, ERC20Burnable, ERC20Permit, ERC20Votes, AccessControl {
    IAntisnipe public antisnipe = IAntisnipe(address(0));
    bool public antisnipeDisable;

    constructor(address _admin) 
        ERC20("Token Example", "EXT") 
        ERC20Permit("Example Token")
    {
        _mint(msg.sender, 5_000_000_000 * 10 ** decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._beforeTokenTransfer(from, to, amount);
        if (from == address(0) || to == address(0)) return;
        if (!antisnipeDisable && address(antisnipe) != address(0)) {
            antisnipe.assureCanTransfer(msg.sender, from, to, amount);
        }
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }

    function setAntisnipeDisable() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!antisnipeDisable);
        antisnipeDisable = true;
    }

    function setAntisnipeAddress(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        antisnipe = IAntisnipe(addr);
    }
}
