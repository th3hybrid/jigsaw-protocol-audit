// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Script, console2 as console, stdJson as StdJson } from "forge-std/Script.sol";

import { Base } from "../Base.s.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IOracle } from "../../src/interfaces/oracle/IOracle.sol";

import { Manager } from "../../src/Manager.sol";
import { ManagerContainer } from "../../src/ManagerContainer.sol";
import { SharesRegistry } from "../../src/SharesRegistry.sol";
import { StablesManager } from "../../src/StablesManager.sol";

/**
 * @notice Deploys SharesRegistry Contracts for each configured token (a.k.a. collateral)
 */
contract DeployRegistries is Script, Base {
    using StdJson for string;

    struct RegistryConfig {
        address token;
        address oracle;
        bytes oracleData;
        uint256 collateralizationRate;
    }

    // Array to store registry configurations
    RegistryConfig[] internal registryConfigs;

    // Array to store deployed registries' addresses
    address[] internal registries;

    string internal configPath = "./deployment-config/04_RegistryConfig.json";
    string internal config = vm.readFile(configPath);

    address internal INITIAL_OWNER = config.readAddress(".INITIAL_OWNER");
    address internal MANAGER_CONTAINER = config.readAddress(".MANAGER_CONTAINER");
    address internal STABLES_MANAGER = config.readAddress(".STABLES_MANAGER");

    // Store configs
    address internal USDC = address(1);
    address internal USDC_Oracle = address(11);
    bytes internal USDC_OracleData = bytes("");
    uint256 internal USDC_CR = 50_000;

    address internal WETH = address(2);
    address internal WETH_Oracle = address(22);
    bytes internal WETH_OracleData = bytes("");
    uint256 internal WETH_CR = 50_000;

    constructor() {
        // Add configs for USDC registry
        registryConfigs.push(
            RegistryConfig({
                token: USDC,
                oracle: USDC_Oracle,
                oracleData: USDC_OracleData,
                collateralizationRate: USDC_CR
            })
        );

        // Add configs for WETH registry
        registryConfigs.push(
            RegistryConfig({
                token: WETH,
                oracle: WETH_Oracle,
                oracleData: WETH_OracleData,
                collateralizationRate: WETH_CR
            })
        );
    }

    function run() external broadcast returns (address[] memory deployedRegistries) {
        // Validate interfaces
        _validateInterface(ManagerContainer(MANAGER_CONTAINER));
        _validateInterface(StablesManager(STABLES_MANAGER));

        // Get manager address from the MANAGER_CONTAINER
        Manager manager = Manager(address(ManagerContainer(MANAGER_CONTAINER).manager()));

        for (uint256 i = 0; i < registryConfigs.length; i += 1) {
            // Validate interfaces
            _validateInterface(IERC20(registryConfigs[i].token));
            _validateInterface(IOracle(registryConfigs[i].oracle));

            // Deploy SharesRegistry contract
            SharesRegistry registry = new SharesRegistry({
                _initialOwner: INITIAL_OWNER,
                _managerContainer: MANAGER_CONTAINER,
                _token: registryConfigs[i].token,
                _oracle: registryConfigs[i].oracle,
                _oracleData: registryConfigs[i].oracleData,
                _collateralizationRate: registryConfigs[i].collateralizationRate
            });

            // Save the deployed SharesRegistry contract to the StablesManager contract
            StablesManager(STABLES_MANAGER).registerOrUpdateShareRegistry({
                _registry: address(registry),
                _token: registryConfigs[i].token,
                _active: true
            });

            // Whitelist token in the Manager Contract
            manager.whitelistToken(registryConfigs[i].token);

            // Save the registry deployment address locally
            registries.push(address(registry));
        }

        return registries;
    }
}
