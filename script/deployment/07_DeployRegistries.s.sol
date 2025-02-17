// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Script, console2 as console, stdJson as StdJson } from "forge-std/Script.sol";

import { Base } from "../Base.s.sol";

import { IERC20, IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { IOracle } from "../../src/interfaces/oracle/IOracle.sol";

import { ManagerContainer } from "../../src/ManagerContainer.sol";

import { SharesRegistry } from "../../src/SharesRegistry.sol";
import { StablesManager } from "../../src/StablesManager.sol";
import { PythOracleFactory } from "../../src/oracles/pyth/PythOracleFactory.sol";

/**
 * @notice Deploys SharesRegistry Contracts for each configured token (a.k.a. collateral)
 */
contract DeployRegistries is Script, Base {
    using StdJson for string;

    struct RegistryConfig {
        string symbol;
        address token;
        uint256 collateralizationRate;
        bytes oracleData;
        bytes32 pythId;
        uint256 age;
    }

    // Array to store registry configurations
    RegistryConfig[] internal registryConfigs;

    // Array to store deployed registries' addresses
    address[] internal registries;

    // Read config files
    string internal commonConfig = vm.readFile("./deployment-config/00_CommonConfig.json");
    string internal deployments = vm.readFile("./deployments.json");

    // Get values from configs
    address internal INITIAL_OWNER = commonConfig.readAddress(".INITIAL_OWNER");
    address internal MANAGER_CONTAINER = deployments.readAddress(".MANAGER_CONTAINER");
    address internal STABLES_MANAGER = deployments.readAddress(".STABLES_MANAGER");
    address internal PYTH_ORACLE_FACTORY = deployments.readAddress(".PYTH_ORACLE_FACTORY");

    // Common configs for oracle
    bytes internal COMMON_ORACLE_DATA = bytes("");
    uint256 internal COMMON_ORACLE_AGE = 1 hours;

    function run() external broadcast returns (address[] memory deployedRegistries) {
        // Validate interfaces
        _validateInterface(ManagerContainer(MANAGER_CONTAINER));
        _validateInterface(StablesManager(STABLES_MANAGER));

        _populateRegistriesArray();

        for (uint256 i = 0; i < registryConfigs.length; i += 1) {
            // Validate interfaces
            _validateInterface(IERC20(registryConfigs[i].token));

            address oracle = PythOracleFactory(PYTH_ORACLE_FACTORY).createPythOracle({
                _initialOwner: INITIAL_OWNER,
                _underlying: registryConfigs[i].token,
                _priceId: registryConfigs[i].pythId,
                _age: registryConfigs[i].age
            });

            // Deploy SharesRegistry contract
            SharesRegistry registry = new SharesRegistry({
                _initialOwner: INITIAL_OWNER,
                _managerContainer: MANAGER_CONTAINER,
                _token: registryConfigs[i].token,
                _oracle: oracle,
                _oracleData: registryConfigs[i].oracleData,
                _collateralizationRate: registryConfigs[i].collateralizationRate
            });

            // @note save the deployed SharesRegistry contract to the StablesManager contract
            // @note whitelistToken on Manager Contract for all the tokens

            // Save the registry deployment address locally
            registries.push(address(registry));

            string memory jsonKey = string.concat(".REGISTRY_", IERC20Metadata(registryConfigs[i].token).symbol());

            // Save addresses of all the deployed contracts to the deployments.json
            Strings.toHexString(uint160(address(registry)), 20).write("./deployments.json", jsonKey);
        }

        return registries;
    }

    function _populateRegistriesArray() internal {
        // Add configs for desired collaterals' registries
        registryConfigs.push(
            RegistryConfig({
                symbol: "USDC",
                token: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
                collateralizationRate: 90_000,
                pythId: 0xeaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "USDT",
                token: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
                collateralizationRate: 90_000,
                pythId: 0x2b89b9dc8fdf9f34709a5b106b472f0f39bb6ca9ce04b0fd7f2e971688e2e53b,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "DAI",
                token: 0x6B175474E89094C44Da98b954EedeAC495271d0F,
                collateralizationRate: 90_000,
                pythId: 0xb0948a5e5313200c632b51bb5ca32f6de0d36e9950a942d19751e833f70dabfd,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "sUSDe",
                token: 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497,
                collateralizationRate: 80_000,
                pythId: 0xca3ba9a619a4b3755c10ac7d5e760275aa95e9823d38a84fedd416856cdba37c,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "USD0++",
                token: 0x35D8949372D46B7a3D5A56006AE77B215fc69bC0,
                collateralizationRate: 80_000,
                pythId: 0xf9c96a45784d0ce4390825a43a313149da787e6a6c66076f3a3f83e92501baeb,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "wBTC",
                token: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,
                collateralizationRate: 80_000,
                pythId: 0xc9d8b075a5c69303365ae23633d4e085199bf5c520a3b90fed1322a0342ffc33,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "wETH",
                token: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
                collateralizationRate: 80_000,
                pythId: 0x9d4294bbcd1174d6f2003ec365831e64cc31d9f6f15a2b85399db8d5000960f6,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "wstETH",
                token: 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0,
                collateralizationRate: 80_000,
                pythId: 0x6df640f3b8963d8f8358f791f352b8364513f6ab1cca5ed3f1f7b5448980e784,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "rswETH",
                token: 0xFAe103DC9cf190eD75350761e95403b7b8aFa6c0,
                collateralizationRate: 75_000,
                pythId: 0x17e349391a4d8362706ec4126c2fa42047601cb71c1063e38ca305fab9b0ec4d,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "pufETH",
                token: 0xD9A442856C234a39a81a089C06451EBAa4306a72,
                collateralizationRate: 75_000,
                pythId: 0xe5801530292c348f322b7b4a48c1c0d59ab629846cce1c816fc27aee2054b560,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "weETH",
                token: 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee,
                collateralizationRate: 75_000,
                pythId: 0x9ee4e7c60b940440a261eb54b6d8149c23b580ed7da3139f7f08f4ea29dad395,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "ezETH",
                token: 0xbf5495Efe5DB9ce00f80364C8B423567e58d2110,
                collateralizationRate: 75_000,
                pythId: 0x06c217a791f5c4f988b36629af4cb88fad827b2485400a358f3b02886b54de92,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "pxETH",
                token: 0x04C154b66CB340F3Ae24111CC767e0184Ed00Cc6,
                collateralizationRate: 75_000,
                pythId: 0x834be8951394714988606b3a1ac299c48bd07d68e5abb02766bcf881fdc1e69c,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );

        registryConfigs.push(
            RegistryConfig({
                symbol: "LBTC",
                token: 0x8236a87084f8B84306f72007F36F2618A5634494,
                collateralizationRate: 75_000,
                pythId: 0x8f257aab6e7698bb92b15511915e593d6f8eae914452f781874754b03d0c612b,
                oracleData: COMMON_ORACLE_DATA,
                age: COMMON_ORACLE_AGE
            })
        );
    }
}
