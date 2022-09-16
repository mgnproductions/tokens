// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract MultiAccessControl {
    mapping(address => bool) internal _owners;

    modifier isOwner() {
        require(_owners[msg.sender] == true, "ERR_NOT_OWNER");
        _;
    }

    constructor() {
        _owners[msg.sender] = true;
    }

    function addOwnership(address payable newOwner) external isOwner {
        require(newOwner != address(0), "ERR_ZERO_ADDR");
        _owners[newOwner] = true;
    }

    function removeOwnership(address payable existingOwner) external isOwner {
        require(_owners[existingOwner] == true, "ERR_ADDR_NOT_OWNER");
        _owners[existingOwner] = false;
    }
}

contract ERC20Capped is ERC20, MultiAccessControl {
    // define 7.5 milions as mark cap
    uint256 public maxSupply = 7000000 * 10**decimals();

    constructor(string memory _name, string memory _symbol)
        MultiAccessControl()
        ERC20(_name, _symbol)
    {}

    function _mintCapped(address _account, uint256 _value) internal {
        require(totalSupply() + _value <= maxSupply, "ERR_EXCEEDED_MAX_SUPPLY");
        _mint(_account, _value);
    }
}

contract TokenERC20 is ERC20Capped {
    uint256 private _mintAmount = 700000 * 10**decimals();

    constructor() ERC20Capped("MGN community", "MGN") {
        _mintCapped(msg.sender, _mintAmount );
    }
}
