// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Script, console2 as console, stdJson as StdJson } from "forge-std/Script.sol";

import { Manager } from "../../src/Manager.sol";
import { ManagerContainer } from "../../src/ManagerContainer.sol";
import { ReceiptToken } from "../../src/ReceiptToken.sol";
import { ReceiptTokenFactory } from "../../src/ReceiptTokenFactory.sol";

/**
 * @notice Deploys ReceiptTokenFactory & ReceiptToken Contracts, sets ReceiptToken implementation in the
 * ReceiptTokenFactory Contract
 */
contract DeployReceiptToken is Script {
    using StdJson for string;

    string internal configPath = "./deployment-config/05_ReceiptTokenConfig.json";
    string internal config = vm.readFile(configPath);

    address internal INITIAL_OWNER = config.readAddress(".INITIAL_OWNER");
    address internal MANAGER_CONTAINER = config.readAddress(".MANAGER_CONTAINER");

    function run() external returns (ReceiptTokenFactory receiptTokenFactory, ReceiptToken receiptToken) {
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
