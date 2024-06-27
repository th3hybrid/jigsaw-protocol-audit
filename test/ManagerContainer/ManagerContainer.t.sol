// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { Manager } from "../../src/Manager.sol";
import { ManagerContainer } from "../../src/ManagerContainer.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

import { SampleOracle } from "../../src/mocks/SampleOracle.sol";
import { BasicContractsFixture } from "../fixtures/BasicContractsFixture.t.sol";
import { IERC20, IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract ManagerContainerTest is BasicContractsFixture {
    using Math for uint256;

    event ManagerUpdated(address indexed oldAddress, address indexed newAddress);

    function setUp() public {
        init();
    }

    function test_should_deploy_manager_and_update_managerContainer() public {
        vm.startPrank(OWNER, OWNER);

        address oldManager = managerContainer.manager();

        SampleOracle jUsdOracle = new SampleOracle();
        Manager newManager = new Manager(address(usdc), address(weth), address(jUsdOracle), bytes(""));

        vm.expectEmit(true, true, false, false);
        emit ManagerUpdated(oldManager, address(newManager));
        managerContainer.updateManager(address(newManager));
    }

    function test_should_check_manager_is_being_accessed_by_other_contracts() public {
        vm.startPrank(OWNER, OWNER);

        holdingManager.createHolding();

        SampleOracle jUsdOracle = new SampleOracle();
        Manager newManager = new Manager(address(usdc), address(weth), address(jUsdOracle), bytes(""));

        newManager.setPerformanceFee(3000);

        managerContainer.updateManager(address(newManager));

        address managerAddress = managerContainer.manager();

        Manager manager = Manager(managerAddress);
        assertEq(manager.performanceFee(), 3000);
    }

    function test_should_not_let_the_owner_renounce_ownership() public {
        vm.prank(OWNER);
        vm.expectRevert(bytes("1000"));
        managerContainer.renounceOwnership();
    }

    function test_wrong_initialization_values() public {
        vm.startPrank(OWNER);
        vm.expectRevert(bytes("3000"));
        new ManagerContainer(address(0));

        vm.expectRevert(bytes("3003"));
        managerContainer.updateManager(address(0));

        vm.expectRevert(bytes("3062"));
        managerContainer.updateManager(address(manager));
    }
}
