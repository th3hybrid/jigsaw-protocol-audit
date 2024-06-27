// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {IStablesManager} from "../interfaces/core/IStablesManager.sol";
import {IManager} from "../interfaces/core/IManager.sol";
import {IJigsawUSD} from "../interfaces/stablecoin/IJigsawUSD.sol";
import {IManagerContainer} from "../interfaces/core/IManagerContainer.sol";

/// @title Jigsaw stablecoin
/// @author Cosmin Grigore (@gcosmintech)
contract JigsawUSD is IJigsawUSD, ERC20 {
    /// @notice token's symbol
    string private constant SYMBOL = "jUsd";
    /// @notice token's name
    string private constant NAME = "Jigsaw USD";
    /// @notice token's decimals
    uint8 private constant DECIMALS = 18;

    /// @notice contract that contains the address of the manager contract
    IManagerContainer public immutable override managerContainer;

    /// @notice mint limit
    uint256 public override mintLimit;

    /// @notice owner of the contract
    address private _owner;

    /// @notice creates the jUsd contract
    /// @param _managerContainer contract that contains the address of the manager contract
    constructor(address _managerContainer) ERC20(NAME, SYMBOL) {
        require(_managerContainer != address(0), "3065");
        managerContainer = IManagerContainer(_managerContainer);
        _owner = msg.sender;
        mintLimit = 1e6 * (10**DECIMALS); // initial 1M limit
    }

    // -- Owner specific methods --

    /// @notice sets the maximum mintable amount
    /// @param _limit the new mint limit
    function updateMintLimit(uint256 _limit)
        external
        override
        onlyOwner
        validAmount(_limit)
    {
        emit MintLimitUpdated(mintLimit, _limit);
        mintLimit = _limit;
    }

    // -- Write type methods --

    /// @notice mint tokens
    /// @dev no need to check if '_to' is a valid address if the '_mint' method is used
    /// @param _to address of the user receiving minted tokens
    /// @param _amount the amount to be minted
    function mint(address _to, uint256 _amount)
        external
        override
        onlyStablesManager
        validAmount(_amount)
    {
        require(totalSupply() + _amount <= mintLimit, "2007");
        _mint(_to, _amount);
    }

    /// @notice burns token from sender
    /// @param _amount the amount of tokens to be burnt
    function burn(uint256 _amount) external override validAmount(_amount) {
        _burn(msg.sender, _amount);
    }

    /// @notice burns token from an address
    /// @param _user the user to burn it from
    /// @param _amount the amount of tokens to be burnt
    function burnFrom(address _user, uint256 _amount)
        external
        override
        validAmount(_amount)
        onlyStablesManager
    {
        _burn(_user, _amount);
    }

    // -- Modifiers --
    modifier validAmount(uint256 _val) {
        require(_val > 0, "2001");
        _;
    }
    modifier onlyStablesManager() {
        require(
            msg.sender == IManager(managerContainer.manager()).stablesManager(),
            "1000"
        );
        _;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "1000");
        _;
    }
}
