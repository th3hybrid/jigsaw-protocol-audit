// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { stdJson as StdJson } from "forge-std/Script.sol";
import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { DeployMocks } from "../../script/deployment/00_DeployMocks.s.sol";
import { DeployManager } from "../../script/deployment/01_DeployManager.s.sol";
import { DeployManagerContainer } from "../../script/deployment/02_DeployManagerContainer.s.sol";
import { DeployJUSD } from "../../script/deployment/03_DeployJUSD.s.sol";

import { JigsawUSD } from "../../src/JigsawUSD.sol";
import { Manager } from "../../src/Manager.sol";
import { ManagerContainer } from "../../src/ManagerContainer.sol";

import { SampleOracle } from "../utils/mocks/SampleOracle.sol";
import { SampleTokenERC20 } from "../utils/mocks/SampleTokenERC20.sol";
import { wETHMock } from "../utils/mocks/wETHMock.sol";

contract DeployJUSDTest is Test {
    using StdJson for string;

    string internal commonConfigPath = "./deployment-config/00_CommonConfig.json";
    string internal managerConfigPath = "./deployment-config/01_ManagerConfig.json";

    address internal INITIAL_OWNER = vm.addr(vm.envUint("DEPLOYER_PRIVATE_KEY"));
    address internal FEE_ADDRESS = address(uint160(uint256(keccak256("FEE ADDRESS"))));
    address internal USDC;
    address internal WETH;
    address internal JUSD_Oracle;

    Manager internal manager;
    ManagerContainer internal managerContainer;
    JigsawUSD internal jUSD;

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
        DeployManagerContainer deployManagerContainerScript = new DeployManagerContainer();
        manager = deployManagerScript.run();
        managerContainer = deployManagerContainerScript.run();

        //Run JUSD deployment script
        DeployJUSD deployJUSDScript = new DeployJUSD();
        jUSD = deployJUSDScript.run();
    }

    function test_deploy_jUSD() public view {
        // Perform checks on the JUSD Contract
        assertEq(jUSD.owner(), INITIAL_OWNER, "Initial owner in jUSD is wrong");
        assertEq(address(jUSD.managerContainer()), address(managerContainer), "ManagerContainer in jUSD is wrong");
        assertEq(jUSD.decimals(), 18, "Decimals in jUSD is wrong");
    }
}
