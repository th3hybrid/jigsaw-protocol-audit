// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../fixtures/ScriptTestsFixture.t.sol";

contract DeployJUSDTest is Test, ScriptTestsFixture {
    function setUp() public {
        init();
    }

    function test_deploy_jUSD() public view {
        // Perform checks on the JUSD Contract
        assertEq(jUSD.owner(), INITIAL_OWNER, "Initial owner in jUSD is wrong");
        assertEq(address(jUSD.managerContainer()), address(managerContainer), "ManagerContainer in jUSD is wrong");
        assertEq(jUSD.decimals(), 18, "Decimals in jUSD is wrong");
    }
}
