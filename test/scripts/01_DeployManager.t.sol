// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { stdJson as StdJson } from "forge-std/Script.sol";
import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { DeployMocks } from "../../script/deployment/00_DeployMocks.s.sol";
import { DeployManager } from "../../script/deployment/01_DeployManager.s.sol";

import { Manager } from "../../src/Manager.sol";
import { ManagerContainer } from "../../src/ManagerContainer.sol";

import { SampleOracle } from "../utils/mocks/SampleOracle.sol";
import { SampleTokenERC20 } from "../utils/mocks/SampleTokenERC20.sol";
import { wETHMock } from "../utils/mocks/wETHMock.sol";

contract DeployManagerTest is Test {
    using StdJson for string;

    string internal managerConfigPath = "./deployment-config/01_ManagerConfig.json";
    string internal commonConfigPath = "./deployment-config/00_CommonConfig.json";

    address internal INITIAL_OWNER = vm.addr(vm.envUint("DEPLOYER_PRIVATE_KEY"));
    address internal FEE_ADDRESS = address(uint160(uint256(keccak256("FEE ADDRESS"))));
    address internal USDC;
    address internal WETH;
    address internal JUSD_Oracle;

    Manager internal manager;
    ManagerContainer internal managerContainer;

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        DeployMocks mockScript = new DeployMocks();
        (SampleTokenERC20 USDC_MOCK, wETHMock WETH_MOCK,,, SampleOracle JUSD_OracleMock) = mockScript.run();

        USDC = address(USDC_MOCK);
        WETH = address(WETH_MOCK);
        JUSD_Oracle = address(JUSD_OracleMock);

        // Update config files with needed values
        Strings.toHexString(uint160(INITIAL_OWNER), 20).write(commonConfigPath, ".INITIAL_OWNER");
        Strings.toHexString(uint160(USDC), 20).write(managerConfigPath, ".USDC");
        Strings.toHexString(uint160(WETH), 20).write(managerConfigPath, ".WETH");
        Strings.toHexString(uint160(JUSD_Oracle), 20).write(managerConfigPath, ".JUSD_Oracle");
        Strings.toHexString(uint256(bytes32("")), 32).write(managerConfigPath, ".JUSD_OracleData");
        Strings.toHexString(uint160(FEE_ADDRESS), 20).write(managerConfigPath, ".FEE_ADDRESS");

        //Run Manager deployment script
        DeployManager deployManagerScript = new DeployManager();
        (manager, managerContainer) = deployManagerScript.run();
    }

    function test_deploy_manager() public view {
        // Perform checks on the Manager Contract
        assertEq(manager.owner(), INITIAL_OWNER, "Initial owner in Manager is wrong");
        assertEq(manager.USDC(), USDC, "USDC address in Manager is wrong");
        assertEq(manager.WETH(), WETH, "WETH address in Manager is wrong");
        assertEq(address(manager.jUsdOracle()), JUSD_Oracle, "JUSD_Oracle address in Manager is wrong");
        assertEq(bytes32(manager.oracleData()), bytes32(""), "JUSD_OracleData in Manager is wrong");
        assertEq(manager.feeAddress(), FEE_ADDRESS, "Fee address in Manager is wrong");

        // Perform checks on the ManagerContainer Contract
        assertEq(managerContainer.owner(), INITIAL_OWNER, "Initial owner in ManagerContainer is wrong");
        assertEq(managerContainer.manager(), address(manager), "Manager address in ManagerContainer is wrong");
    }
}
