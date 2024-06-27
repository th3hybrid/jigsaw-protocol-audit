// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";

import { IReceiptTokenFactory } from "./interfaces/core/IReceiptTokenFactory.sol";
import { IReceiptToken } from "./interfaces/vyper/IReceiptToken.sol";

contract ReceiptTokenFactory is IReceiptTokenFactory {
    address public referenceImplementation;

    constructor(address _referenceImplementation) {
        require(_referenceImplementation != address(0), "3000");
        referenceImplementation = _referenceImplementation;
    }

    function createReceiptToken(
        string memory _name,
        string memory _symbol,
        address _minter,
        address _owner
    ) public override returns (address newReceiptTokenAddress) {
        newReceiptTokenAddress = Clones.clone(referenceImplementation);

        IReceiptToken(newReceiptTokenAddress).initialize(_name, _symbol, _minter, _owner);

        emit ReceiptTokenCreated(newReceiptTokenAddress, msg.sender, _name, _symbol);
    }
}
