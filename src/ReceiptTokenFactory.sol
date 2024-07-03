// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";

import { IReceiptToken } from "./interfaces/core/IReceiptToken.sol";
import { IReceiptTokenFactory } from "./interfaces/core/IReceiptTokenFactory.sol";

/**
 * @title ReceiptTokenFactory
 * @dev This contract is used to create new instances of receipt tokens for strategies using the clone factory pattern.
 */
contract ReceiptTokenFactory is IReceiptTokenFactory {
    /**
     * @notice Address of the reference implementation of the receipt token contract.
     */
    address public referenceImplementation;

    // -- Constructor --

    /**
     * @notice Constructor to set the reference implementation address.
     * @param _referenceImplementation Address of the reference implementation contract.
     */
    constructor(address _referenceImplementation) {
        require(_referenceImplementation != address(0), "3000");
        referenceImplementation = _referenceImplementation;
    }

    // -- Receipt token creation --

    /**
     * @notice Creates a new receipt token by cloning the reference implementation.
     *
     * @param _name Name of the new receipt token.
     * @param _symbol Symbol of the new receipt token.
     * @param _minter Address of the account that will have the minting rights.
     * @param _owner Address of the owner of the new receipt token.
     *
     * @return newReceiptTokenAddress Address of the newly created receipt token.
     */
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
