// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../fixtures/ScriptTestsFixture.t.sol";

contract DeployManagersTest is Test, ScriptTestsFixture {
    function setUp() public {
        init();
    }

    function test_deploy_managers() public view {
        // Perform checks on the HoldingManager Contract
        assertEq(holdingManager.owner(), INITIAL_OWNER, "Initial owner in HoldingManager is wrong");
        assertEq(
            address(holdingManager.managerContainer()),
            address(managerContainer),
            "ManagerContainer in HoldingManager is wrong"
        );

        // Perform checks on the LiquidationManager Contract
        assertEq(liquidationManager.owner(), INITIAL_OWNER, "Initial owner in LiquidationManager is wrong");
        assertEq(
            address(liquidationManager.managerContainer()),
            address(managerContainer),
            "ManagerContainer in LiquidationManager is wrong"
        );

        // Perform checks on the StablesManager Contract
        assertEq(stablesManager.owner(), INITIAL_OWNER, "Initial owner in StablesManager is wrong");
        assertEq(
            address(stablesManager.managerContainer()),
            address(managerContainer),
            "ManagerContainer in  StablesManager is wrong"
        );
        assertEq(address(stablesManager.jUSD()), address(jUSD), "jUSD in StablesManager is wrong");

        // Perform checks on the StrategyManager Contract
        assertEq(strategyManager.owner(), INITIAL_OWNER, "Initial owner in StrategyManager is wrong");
        assertEq(
            address(strategyManager.managerContainer()),
            address(managerContainer),
            "ManagerContainer in  StrategyManager is wrong"
        );

        // Perform checks on the SwapManager Contract
        assertEq(swapManager.owner(), INITIAL_OWNER, "Initial owner in SwapManager is wrong");
        assertEq(swapManager.swapRouter(), UNISWAP_SWAP_ROUTER, "UNISWAP_SWAP_ROUTER in SwapManager is wrong");
        assertEq(swapManager.uniswapFactory(), UNISWAP_FACTORY, "UNISWAP_FACTORY in SwapManager is wrong");
        assertEq(
            address(swapManager.managerContainer()),
            address(managerContainer),
            "ManagerContainer in  SwapManager is wrong"
        );

        // Imitate multisig calls
        vm.startPrank(INITIAL_OWNER, INITIAL_OWNER);
        manager.setHoldingManager(address(holdingManager));
        manager.setHoldingManager(address(liquidationManager));
        manager.setHoldingManager(address(stablesManager));
        manager.setHoldingManager(address(strategyManager));
        manager.setHoldingManager(address(swapManager));
        vm.stopPrank();

        assertEq(manager.holdingManager(), address(holdingManager), "HoldingManager in Manager is wrong");
        assertEq(manager.liquidationManager(), address(liquidationManager), "LiquidationManager in Manager is wrong");
        assertEq(manager.stablesManager(), address(stablesManager), "StablesManager in Manager is wrong");
        assertEq(manager.strategyManager(), address(strategyManager), "StrategyManager in Manager is wrong");
        assertEq(manager.swapManager(), address(swapManager), "SwapManager in Manager is wrong");
    }
}
