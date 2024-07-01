// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Receipt token interface
interface IReceiptToken {
    function mint(address _to, uint256 _amount) external returns (bool);

    function burnFrom(address _from, uint256 _amount) external returns (bool);

    function initialize(string memory _name, string memory _symbol, address _minter, address _owner) external;
}
