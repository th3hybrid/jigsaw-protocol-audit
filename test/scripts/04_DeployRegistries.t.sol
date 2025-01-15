// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../fixtures/ScriptTestsFixture.t.sol";

contract DeployRegistriesTest is Test, ScriptTestsFixture {
    function setUp() public {
        init();
    }

    function test_deploy_registries() public view {
        for (uint256 i = 0; i < registries.length; i += 1) {
            SharesRegistry registry = SharesRegistry(registries[i]);

            // Perform checks on the ShareRegistry Contracts
            assertEq(registry.owner(), INITIAL_OWNER, "INITIAL_OWNER in ShareRegistry is wrong");
            assertEq(
                address(registry.managerContainer()),
                address(managerContainer),
                "ManagerContainer in ShareRegistry is wrong"
            );

            // Perform checks on the StablesManager Contract
            (bool active, address _registry) = stablesManager.shareRegistryInfo(registry.token());
            assertEq(active, true, "Active flag in StablesManager is wrong");
            assertEq(_registry, address(registry), "Registry address in StablesManager is wrong");

            // @note imitate multisig to whitelist token
            // assertEq(manager.isTokenWhitelisted(registry.token()), true, "Token not whitelisted in Manager");
        }
    }
}
