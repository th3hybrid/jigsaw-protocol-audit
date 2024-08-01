// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Script, console2 as console, stdJson as StdJson } from "forge-std/Script.sol";

import { Base } from "../Base.s.sol";

import { Manager } from "../../src/Manager.sol";
import { ManagerContainer } from "../../src/ManagerContainer.sol";
import { ReceiptToken } from "../../src/ReceiptToken.sol";
import { ReceiptTokenFactory } from "../../src/ReceiptTokenFactory.sol";

/**
 * @notice Deploys ReceiptTokenFactory & ReceiptToken Contracts, sets ReceiptToken implementation in the
 * ReceiptTokenFactory Contract
 */
contract DeployReceiptToken is Script, Base {
    using StdJson for string;

    // Read config file
    string internal commonConfig = vm.readFile("./deployment-config/00_CommonConfig.json");

    // Get values from config
    address internal INITIAL_OWNER = commonConfig.readAddress(".INITIAL_OWNER");
    address internal MANAGER_CONTAINER = commonConfig.readAddress(".MANAGER_CONTAINER");

    function run() external broadcast returns (ReceiptTokenFactory receiptTokenFactory, ReceiptToken receiptToken) {
        // Validate interface
        _validateInterface(ManagerContainer(MANAGER_CONTAINER));

        // Get manager address from the MANAGER_CONTAINER
        Manager manager = Manager(address(ManagerContainer(MANAGER_CONTAINER).manager()));

        // Deploy ReceiptTokenFactory Contract
        receiptTokenFactory = new ReceiptTokenFactory({ _initialOwner: INITIAL_OWNER });

        // Deploy ReceiptToken Contract
        receiptToken = new ReceiptToken();

        // Set receipt token implementation
        receiptTokenFactory.setReceiptTokenReferenceImplementation({ _referenceImplementation: address(receiptToken) });

        // Set receipt token factory in the Manager Contract
        manager.setReceiptTokenFactory({ _factory: address(receiptTokenFactory) });
    }
}
