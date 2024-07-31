// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Script, console2 as console, stdJson as StdJson } from "forge-std/Script.sol";

import { Manager } from "../../src/Manager.sol";
import { ManagerContainer } from "../../src/ManagerContainer.sol";

/**
 * @notice Deploys Manager and ManagerContainer Contracts
 * @notice Configures feeAddress in the Manager Contract
 */
contract DeployManager is Script {
    using StdJson for string;

    string internal configPath = "./deployment-config/01_ManagerConfig.json";
    string internal config = vm.readFile(configPath);

    address internal INITIAL_OWNER = config.readAddress(".INITIAL_OWNER");
    address internal USDC = config.readAddress(".USDC");
    address internal WETH = config.readAddress(".WETH");
    address internal JUSD_Oracle = config.readAddress(".JUSD_Oracle");
    bytes internal JUSD_OracleData = config.readBytes(".JUSD_OracleData");
    address internal FEE_ADDRESS = config.readAddress(".FEE_ADDRESS");

    function run() external returns (Manager manager, ManagerContainer managerContainer) {
        // Deploy Manager contract
        manager = new Manager({
            _initialOwner: INITIAL_OWNER,
            _usdc: USDC,
            _weth: WETH,
            _oracle: JUSD_Oracle,
            _oracleData: JUSD_OracleData
        });

        // Configure the fee address for the Manager Contract
        manager.setFeeAddress(FEE_ADDRESS);

        // Deploy ManagerContainer Contract
        managerContainer = new ManagerContainer({ _initialOwner: INITIAL_OWNER, _manager: address(manager) });
    }
}
