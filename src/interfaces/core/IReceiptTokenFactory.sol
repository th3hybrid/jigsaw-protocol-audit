// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReceiptTokenFactory {
    event ReceiptTokenCreated(
        address indexed receiptToken,
        address indexed strategy,
        string name,
        string symbol
    );

    function createReceiptToken(
        string memory _name,
        string memory _symbol,
        address _minter,
        address _owner
    ) external returns (address);
}
