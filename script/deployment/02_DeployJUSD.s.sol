// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Script, console2 as console, stdJson as StdJson } from "forge-std/Script.sol";

import { Base } from "../Base.s.sol";

import { JigsawUSD } from "../../src/JigsawUSD.sol";
import { ManagerContainer } from "../../src/ManagerContainer.sol";

/**
 * @notice Deploys jUSD Contract
 */
contract DeployJUSD is Script, Base {
    using StdJson for string;

    string internal configPath = "./deployment-config/02_JUSDConfig.json";
    string internal config = vm.readFile(configPath);

    address internal INITIAL_OWNER = config.readAddress(".INITIAL_OWNER");
    address internal MANAGER_CONTAINER = config.readAddress(".MANAGER_CONTAINER");

    function run() external broadcast returns (JigsawUSD jUSD) {
        // Validate interface
        _validateInterface(ManagerContainer(MANAGER_CONTAINER));

        // Deploy JigsawUSD contract
        jUSD = new JigsawUSD({ _initialOwner: INITIAL_OWNER, _managerContainer: MANAGER_CONTAINER });
    }
}
