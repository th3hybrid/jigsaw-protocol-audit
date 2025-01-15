// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../fixtures/ScriptTestsFixture.t.sol";

contract DeployManagerTest is Test, ScriptTestsFixture {
    function setUp() public {
        init();
    }

    function test_deploy_manager() public view {
        // Perform checks on the Manager Contract
        assertEq(manager.owner(), INITIAL_OWNER, "Initial owner in Manager is wrong");
        assertEq(manager.USDC(), USDC, "USDC address in Manager is wrong");
        assertEq(manager.WETH(), WETH, "WETH address in Manager is wrong");
        assertEq(address(manager.jUsdOracle()), JUSD_Oracle, "JUSD_Oracle address in Manager is wrong");
        assertEq(bytes32(manager.oracleData()), bytes32(""), "JUSD_OracleData in Manager is wrong");

        // Perform checks on the ManagerContainer Contract
        assertEq(managerContainer.owner(), INITIAL_OWNER, "Initial owner in ManagerContainer is wrong");
        assertEq(managerContainer.manager(), address(manager), "Manager address in ManagerContainer is wrong");
    }
}
