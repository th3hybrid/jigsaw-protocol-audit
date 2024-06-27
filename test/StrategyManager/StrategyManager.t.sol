// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../fixtures/BasicContractsFixture.t.sol";

import { MaliciousStrategy } from "../../src/mocks/MaliciousStrategy.sol";

import { SampleTokenBigDecimals } from "../../src/mocks/SampleTokenBigDecimals.sol";
import { StrategyWithRewardsMock } from "../../src/mocks/StrategyWithRewardsMock.sol";
import { StrategyWithoutRewardsMockBroken } from "../../src/mocks/StrategyWithoutRewardsMockBroken.sol";

contract StrategyManagerTest is BasicContractsFixture {
    event PauseUpdated(bool oldVal, bool newVal);
    event StrategyAdded(address indexed strategy);
    event StrategyUpdated(address indexed strategy, bool active, uint256 fee);
    event GaugeAdded(address indexed strategy, address indexed gauge);
    event GaugeRemoved(address indexed strategy);
    event GaugeUpdated(address indexed strategy, address indexed oldGauge, address indexed newGauge);
    event Invested(
        address indexed holding,
        address indexed user,
        address indexed token,
        address strategy,
        uint256 amount,
        uint256 tokenOutResult,
        uint256 tokenInResult
    );
    event InvestmentMoved(
        address indexed holding,
        address indexed user,
        address indexed token,
        address strategyFrom,
        address strategyTo,
        uint256 shares,
        uint256 tokenOutResult,
        uint256 tokenInResult
    );

    event CollateralAdjusted(address indexed holding, address indexed token, uint256 value, bool add);

    function setUp() public {
        init();
    }

    // Tests contract creation with wrong constructor arguments
    function test_wrongConstructorArgs() public {
        vm.expectRevert(bytes("3065"));
        StrategyManager newManager = new StrategyManager(address(0));
        newManager;
    }

    // Checks if initial state of the contract is correct
    function test_strategyManager_initialState() public {
        assertEq(strategyManager.paused(), false);
    }

    // Tests setting contract paused from non-Owner's address
    function test_setPaused_when_unauthorized(address _caller) public {
        vm.assume(_caller != strategyManager.owner());
        vm.startPrank(_caller, _caller);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));

        strategyManager.setPaused(true);
    }

    // Tests setting contract paused from Owner's address
    function test_setPaused_when_authorized() public {
        //Sets contract paused and checks if after pausing contract is paused and event is emitted
        vm.expectEmit();
        emit PauseUpdated(strategyManager.paused(), !strategyManager.paused());
        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.setPaused(true);
        assertEq(strategyManager.paused(), true);

        //Sets contract unpaused and checks if after pausing contract is unpaused and event is emitted
        vm.expectEmit();
        emit PauseUpdated(strategyManager.paused(), !strategyManager.paused());
        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.setPaused(false);
        assertEq(strategyManager.paused(), false);
    }

    // Tests adding new strategy to the protocol when unauthorized
    function test_addStrategy_when_unauthorized(address _caller) public {
        address strategy = address(uint160(uint256(keccak256("random address"))));
        vm.assume(_caller != strategyManager.owner());
        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        strategyManager.addStrategy(strategy);

        (,, bool whitelisted) = strategyManager.strategyInfo(strategy);
        assertEq(whitelisted, false, "Strategy added when unauthorized");
    }

    // Tests adding new strategy to the protocol when invalid address
    function test_addStrategy_when_invalidAddress() public {
        address strategy = address(0);
        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("3000"));
        strategyManager.addStrategy(strategy);

        (,, bool whitelisted) = strategyManager.strategyInfo(strategy);
        assertEq(whitelisted, false, "Strategy added when invalid address");
    }

    // Tests successful addition of the new strategy to the protocol
    function test_addStrategy_when_authorized() public {
        address strategy = address(
            new StrategyWithoutRewardsMock(
                address(managerContainer),
                address(usdc),
                address(usdc),
                address(0),
                address(jigsawMinter),
                "AnotherMock",
                "ARM"
            )
        );

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectEmit();
        emit StrategyAdded(strategy);
        strategyManager.addStrategy(strategy);

        (,, bool whitelisted) = strategyManager.strategyInfo(strategy);
        assertEq(whitelisted, true, "Strategy not added when authorized");
    }

    // Tests adding already existing strategy to the protocol
    function test_addStrategy_when_whitelisted() public {
        address strategy = address(strategyWithoutRewardsMock);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("3014"));
        strategyManager.addStrategy(strategy);
    }

    // Tests adding new strategy to the protocol when unauthorized
    function test_updateStrategy_when_unauthorized(address _caller) public {
        address strategy = address(uint160(uint256(keccak256("random address"))));
        IStrategyManager.StrategyInfo memory info;

        vm.assume(_caller != strategyManager.owner());
        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        strategyManager.updateStrategy(strategy, info);

        (,, bool whitelisted) = strategyManager.strategyInfo(strategy);
        assertEq(whitelisted, false, "Strategy updated when unauthorized");
    }

    // Tests adding new strategy to the protocol when invalid address
    function test_updateStrategy_when_invalidStrategy() public {
        IStrategyManager.StrategyInfo memory info;
        address strategy = address(0);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("3029"));
        strategyManager.updateStrategy(strategy, info);

        (,, bool whitelisted) = strategyManager.strategyInfo(strategy);
        assertEq(whitelisted, false, "Strategy updated when invalid Strategy");
    }

    // Tests successful addition of the new strategy to the protocol
    function test_updateStrategy_when_authorized() public {
        IStrategyManager.StrategyInfo memory info;
        address strategy = address(strategyWithoutRewardsMock);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectEmit();
        emit StrategyUpdated(strategy, info.active, info.performanceFee);
        strategyManager.updateStrategy(strategy, info);

        (,, bool whitelisted) = strategyManager.strategyInfo(strategy);
        assertEq(whitelisted, false, "Strategy not updated when authorized");
    }

    // Tests adding new gauge to the strategy when unauthorized
    function test_addStrategyGauge_when_unauthorized(address _caller) public {
        address strategy = address(uint160(uint256(keccak256("random address"))));
        address gauge = address(uint160(uint256(keccak256("random gauge address"))));

        vm.assume(_caller != strategyManager.owner());
        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        strategyManager.addStrategyGauge(strategy, gauge);

        assertEq(strategyManager.strategyGauges(strategy), address(0), "Strategy gauge added when unauthorized");
    }

    // Tests adding new gauge to the strategy when invalid strategy address
    function test_addStrategyGauge_when_invalidStrategy() public {
        address strategy = address(0);
        address gauge = address(uint160(uint256(keccak256("random gauge address"))));

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("3029"));
        strategyManager.addStrategyGauge(strategy, gauge);

        assertEq(
            strategyManager.strategyGauges(strategy), address(0), "Strategy gauge added when invalid strategy address"
        );
    }

    // Tests adding new gauge when already added
    function test_addStrategyGauge_when_alreadyAdded() public {
        address gauge = address(uint160(uint256(keccak256("random gauge address"))));
        address strategy = address(strategyWithoutRewardsMock);

        vm.startPrank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategyGauge(strategy, gauge);
        vm.expectRevert(bytes("1103"));
        strategyManager.addStrategyGauge(strategy, gauge);
        vm.stopPrank();

        assertEq(strategyManager.strategyGauges(strategy), gauge, "Strategy gauge wrong");
    }

    // Tests adding new gauge to the strategy when invalid gauge address
    function test_addStrategyGauge_when_invalidGauge() public {
        address strategy = address(strategyWithoutRewardsMock);
        address gauge = address(0);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("3000"));
        strategyManager.addStrategyGauge(strategy, gauge);

        assertEq(
            strategyManager.strategyGauges(strategy), address(0), "Strategy gauge added when invalid gauge address"
        );
    }

    // Tests successful addition of the new gauge to the strategy
    function test_addStrategyGauge_when_authorized() public {
        address gauge = address(uint160(uint256(keccak256("random gauge address"))));
        address strategy = address(strategyWithoutRewardsMock);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectEmit();
        emit GaugeAdded(strategy, gauge);
        strategyManager.addStrategyGauge(strategy, gauge);

        assertEq(strategyManager.strategyGauges(strategy), gauge, "Strategy gauge not added when authorized ");
    }

    // Tests adding new gauge to the strategy when unauthorized
    function test_removeStrategyGauge_when_unauthorized(address _caller) public {
        vm.assume(_caller != strategyManager.owner());

        address strategy = address(strategyWithoutRewardsMock);
        address gauge = address(uint160(uint256(keccak256("random gauge address"))));

        vm.startPrank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategyGauge(strategy, gauge);
        vm.stopPrank();

        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        strategyManager.removeStrategyGauge(strategy);

        assertEq(strategyManager.strategyGauges(strategy), gauge, "Strategy gauge removed when unauthorized");
    }

    // Tests removing gauge from strategy when invalid strategy address
    function test_removeStrategyGauge_when_invalidStrategy() public {
        address strategy = address(0);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("3029"));
        strategyManager.removeStrategyGauge(strategy);
    }

    // Tests removing gauge from strategy when there is no gauge
    function test_removeStrategyGauge_when_noGauge() public {
        address strategy = address(strategyWithoutRewardsMock);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("1104"));
        strategyManager.removeStrategyGauge(strategy);

        assertEq(strategyManager.strategyGauges(strategy), address(0), "Strategy gauge not added when authorized ");
    }

    // Tests successful removal of the gauge from strategy
    function test_removeStrategyGauge_when_authorized() public {
        address strategy = address(strategyWithoutRewardsMock);
        address gauge = address(uint160(uint256(keccak256("random gauge address"))));

        vm.startPrank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategyGauge(strategy, gauge);

        vm.expectEmit();
        emit GaugeRemoved(strategy);
        strategyManager.removeStrategyGauge(strategy);
        vm.stopPrank();

        assertEq(strategyManager.strategyGauges(strategy), address(0), "Strategy gauge not removed when authorized ");
    }

    // Tests updating the gauge of the strategy when unauthorized
    function test_updateStrategyGauge_when_unauthorized(address _caller) public {
        address strategy = address(uint160(uint256(keccak256("random address"))));
        address gauge = address(uint160(uint256(keccak256("random gauge address"))));

        vm.assume(_caller != strategyManager.owner());
        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        strategyManager.updateStrategyGauge(strategy, gauge);

        assertEq(strategyManager.strategyGauges(strategy), address(0), "Strategy gauge updated when unauthorized");
    }

    // Tests updating the gauge of the strategy when invalid strategy address
    function test_updateStrategyGauge_when_invalidStrategy() public {
        address strategy = address(0);
        address gauge = address(uint160(uint256(keccak256("random gauge address"))));

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("3029"));
        strategyManager.updateStrategyGauge(strategy, gauge);

        assertEq(
            strategyManager.strategyGauges(strategy), address(0), "Strategy gauge updated when invalid strategy address"
        );
    }

    // Tests updating the gauge of the strategy when invalid gauge address
    function test_updateStrategyGauge_when_invalidGauge() public {
        address strategy = address(strategyWithoutRewardsMock);
        address gauge = address(0);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("3000"));
        strategyManager.updateStrategyGauge(strategy, gauge);

        assertEq(
            strategyManager.strategyGauges(strategy), address(0), "Strategy gauge updated when invalid gauge address"
        );
    }

    // Tests updating the gauge of the strategy when there was no gauge added previously
    function test_updateStrategyGauge_when_noOldGauge() public {
        address strategy = address(strategyWithoutRewardsMock);
        address newGauge = address(uint160(uint256(keccak256("new random gauge address"))));

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("1104"));
        strategyManager.updateStrategyGauge(strategy, newGauge);

        assertNotEq(strategyManager.strategyGauges(strategy), newGauge, "Strategy gauge updated when no old gauge ");
    }

    // Tests updating the gauge of the strategy when the new gauge address is the same
    function test_updateStrategyGauge_when_sameGauge() public {
        address strategy = address(strategyWithoutRewardsMock);
        address oldGauge = address(uint160(uint256(keccak256("random gauge address"))));

        vm.startPrank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategyGauge(strategy, oldGauge);

        vm.expectRevert(bytes("1105"));
        strategyManager.updateStrategyGauge(strategy, oldGauge);

        vm.stopPrank();

        assertEq(strategyManager.strategyGauges(strategy), oldGauge, "Strategy gauge wrongfully changed ");
    }

    // Tests successful update of the gauge of the strategy
    function test_updateStrategyGauge_when_authorized() public {
        address strategy = address(strategyWithoutRewardsMock);
        address oldGauge = address(uint160(uint256(keccak256("random gauge address"))));
        address newGauge = address(uint160(uint256(keccak256("new random gauge address"))));

        vm.startPrank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategyGauge(strategy, oldGauge);

        vm.expectEmit();
        emit GaugeUpdated(strategy, oldGauge, newGauge);
        strategyManager.updateStrategyGauge(strategy, newGauge);

        vm.stopPrank();

        assertEq(strategyManager.strategyGauges(strategy), newGauge, "Strategy gauge not updated when authorized ");
    }

    // Tests configuring of the strategy when unauthorized
    function test_configStrategy_when_unauthorized(address _caller) public {
        address strategy = address(uint160(uint256(keccak256("random strategy"))));
        address gauge = address(uint160(uint256(keccak256("random gauge address"))));

        vm.assume(_caller != strategyManager.owner());
        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        strategyManager.configStrategy(strategy, gauge);

        (,, bool whitelisted) = strategyManager.strategyInfo(strategy);
        assertEq(whitelisted, false, "Strategy added when unauthorized");
        assertEq(strategyManager.strategyGauges(strategy), address(0), "Strategy gauge added when unauthorized");
    }

    // Tests configuring of the strategy when invalid strategy
    function test_configStrategy_when_invalidStrategy() public {
        address strategy = address(0);
        address gauge = address(uint160(uint256(keccak256("random gauge address"))));

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("3000"));
        strategyManager.configStrategy(strategy, gauge);

        (,, bool whitelisted) = strategyManager.strategyInfo(strategy);
        assertEq(whitelisted, false, "Strategy added when invalid address");
        assertEq(
            strategyManager.strategyGauges(strategy), address(0), "Strategy gauge updated when invalid strategy address"
        );
    }

    // Tests configuring of the strategy when invalid gauge
    function test_configStrategy_when_invalidGauge() public {
        address strategy = address(strategyWithoutRewardsMock);
        address gauge = address(0);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        vm.expectRevert(bytes("3000"));
        strategyManager.configStrategy(strategy, gauge);

        assertEq(
            strategyManager.strategyGauges(strategy), address(0), "Strategy gauge updated when invalid strategy address"
        );
    }

    // Tests successful configuration of the  strategy
    function test_configStrategy_when_authorized() public {
        address strategy = address(
            new StrategyWithoutRewardsMock(
                address(managerContainer),
                address(usdc),
                address(usdc),
                address(0),
                address(jigsawMinter),
                "AnotherMock",
                "ARM"
            )
        );
        address gauge = address(uint160(uint256(keccak256("random gauge address"))));

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.configStrategy(strategy, gauge);

        (,, bool whitelisted) = strategyManager.strategyInfo(strategy);
        assertEq(whitelisted, true, "Strategy not added when authorized");
        assertEq(strategyManager.strategyGauges(strategy), gauge, "Strategy gauge not updated when authorized");
    }

    // Tests if invest function reverts correctly when invalid strategy
    function test_invest_when_invalidStrategy() public {
        address token = address(uint160(uint256(keccak256("random token"))));
        address strategy = address(uint160(uint256(keccak256("random strategy"))));
        uint256 amount = 10e18;

        vm.expectRevert(bytes("3029"));
        strategyManager.invest(token, strategy, amount, bytes(""));
    }

    // Tests if invest function reverts correctly when invalid amount
    function test_invest_when_invalidAmount() public {
        address token = address(uint160(uint256(keccak256("random token"))));
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 0;

        vm.expectRevert(bytes("2001"));
        strategyManager.invest(token, strategy, amount, bytes(""));
    }

    // Tests if invest function reverts correctly when invalid token
    function test_invest_when_invalidToken() public {
        address token = address(uint160(uint256(keccak256("random token"))));
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 10e18;

        vm.expectRevert(bytes("3001"));
        strategyManager.invest(token, strategy, amount, bytes(""));
    }

    // Tests if invest function reverts correctly when contract is paused
    function test_invest_when_paused() public {
        address token = address(usdc);
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 10e18;

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.setPaused(true);

        vm.expectRevert(bytes("1200"));
        strategyManager.invest(token, strategy, amount, bytes(""));
    }

    // Tests if invest function reverts correctly when msg.sender isn't holding
    function test_invest_when_notHolding() public {
        address token = address(usdc);
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 10e18;

        vm.expectRevert(bytes("3002"));
        strategyManager.invest(token, strategy, amount, bytes(""));
    }

    // Tests if invest function reverts correctly when strategy is inactive
    function test_invest_when_strategyInactive() public {
        address user = address(uint160(uint256(keccak256("random user"))));
        address token = address(usdc);
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 1e18;

        initiateUser(user, address(usdc), amount);

        IStrategyManager.StrategyInfo memory info;
        info.whitelisted = true;
        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.updateStrategy(strategy, info);

        vm.prank(user, user);
        vm.expectRevert(bytes("1202"));
        strategyManager.invest(token, strategy, amount, bytes(""));
    }

    // Tests if invest function reverts correctly when token != _strategyStakingToken,
    function test_invest_when_differentTokens(uint256 amount) public {
        vm.assume(amount > 0 && amount < 1e20);
        address user = address(uint160(uint256(keccak256("random user"))));
        address token = address(weth);
        address strategy = address(strategyWithoutRewardsMock);
        initiateUser(user, token, amount);

        vm.prank(user, user);
        vm.expectRevert(bytes("3085"));
        strategyManager.invest(token, strategy, amount, bytes(""));
    }

    // Tests if invest function works correctly
    function test_invest_when_authorized(uint256 amount) public {
        vm.assume(amount > 0 && amount < 1e20);
        address user = address(uint160(uint256(keccak256("random user"))));
        address token = address(usdc);
        address strategy = address(strategyWithoutRewardsMock);
        // uint256 amount = 1e18;

        address holding = initiateUser(user, token, amount);
        uint256 holdingBalanceBefore = usdc.balanceOf(holding);

        vm.prank(user, user);
        vm.expectEmit();
        emit Invested(holding, user, token, strategy, amount, amount, amount);
        strategyManager.invest(token, strategy, amount, bytes(""));

        address[] memory holdingStrategies = strategyManager.getHoldingToStrategy(holding);

        assertEq(holdingStrategies.length, 1, "Holding's strategies' count incorrect");
        assertEq(holdingStrategies[0], strategy, "Holding's strategy saved incorrectly");
        assertEq(usdc.balanceOf(holding), holdingBalanceBefore - amount, "Invest didn't transfer holding's funds");
        assertEq(usdc.balanceOf(strategy), amount, "Strategy didn't receive holding's funds");
        assertEq(
            IERC20(address(strategyWithoutRewardsMock.receiptToken())).balanceOf(holding),
            amount,
            "Holding didn't receive receipt tokens"
        );
    }

    // Tests if invest function reverts correctly when strategy returns tokenOutAmount as 0
    function test_invest_when_tokenOutAmount0(uint256 amount) public {
        vm.assume(amount > 0 && amount < 1e20);
        address user = address(uint160(uint256(keccak256("random user"))));
        address token = address(weth);

        vm.startPrank(strategyManager.owner(), strategyManager.owner());
        StrategyWithoutRewardsMockBroken strategyWithoutRewardsMockBroken = new StrategyWithoutRewardsMockBroken(
            address(managerContainer),
            address(weth),
            address(weth),
            address(0),
            address(jigsawMinter),
            "Broken-Mock",
            "BRM"
        );
        strategyManager.addStrategy(address(strategyWithoutRewardsMockBroken));
        vm.stopPrank();

        address strategy = address(strategyWithoutRewardsMockBroken);
        address holding = initiateUser(user, token, amount);

        vm.prank(user, user);
        vm.expectRevert(bytes("3030"));
        strategyManager.invest(token, strategy, amount, bytes(""));

        address[] memory holdingStrategies = strategyManager.getHoldingToStrategy(holding);

        assertEq(holdingStrategies.length, 0, "Holding's strategies' count incorrect");
        assertEq(
            IERC20(address(strategyWithoutRewardsMock.receiptToken())).balanceOf(holding),
            0,
            "Holding wrongfully received receipt tokens"
        );
    }

    // Tests if moveInvestment function reverts correctly when invalid strategyFrom
    function test_moveInvestment_when_invalidStrategyFrom() public {
        address token = address(uint160(uint256(keccak256("random token"))));
        IStrategyManager.MoveInvestmentData memory moveInvestmentData;

        vm.expectRevert(bytes("3029"));
        strategyManager.moveInvestment(token, moveInvestmentData);
    }

    // Tests if moveInvestment function reverts correctly when invalid strategyTo
    function test_moveInvestment_when_invalidStrategyTo() public {
        address token = address(uint160(uint256(keccak256("random token"))));
        IStrategyManager.MoveInvestmentData memory moveInvestmentData;
        moveInvestmentData.strategyFrom = address(strategyWithoutRewardsMock);

        vm.expectRevert(bytes("3029"));
        strategyManager.moveInvestment(token, moveInvestmentData);
    }

    // Tests if moveInvestment function reverts correctly when contract is paused
    function test_moveInvestment_when_paused() public {
        address token = address(uint160(uint256(keccak256("random token"))));
        IStrategyManager.MoveInvestmentData memory moveInvestmentData;
        moveInvestmentData.strategyFrom = address(strategyWithoutRewardsMock);
        moveInvestmentData.strategyTo = address(strategyWithoutRewardsMock);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.setPaused(true);

        vm.expectRevert(bytes("1200"));
        strategyManager.moveInvestment(token, moveInvestmentData);
    }

    // Tests if moveInvestment function reverts correctly when msg.sender has no holding
    function test_moveInvestment_when_notHolding() public {
        address token = address(uint160(uint256(keccak256("random token"))));
        IStrategyManager.MoveInvestmentData memory moveInvestmentData;
        moveInvestmentData.strategyFrom = address(strategyWithoutRewardsMock);
        moveInvestmentData.strategyTo = address(strategyWithoutRewardsMock);

        vm.expectRevert(bytes("3002"));
        strategyManager.moveInvestment(token, moveInvestmentData);
    }

    // Tests if moveInvestment function reverts correctly when strategyTo and strategyFrom are the same
    function test_moveInvestment_when_sameStrategies() public {
        address user = address(uint160(uint256(keccak256("random user"))));
        address token = address(usdc);
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 1e18;

        initiateUser(user, address(usdc), amount);

        IStrategyManager.MoveInvestmentData memory moveInvestmentData;
        moveInvestmentData.strategyFrom = strategy;
        moveInvestmentData.strategyTo = strategy;

        vm.prank(user, user);
        vm.expectRevert(bytes("3086"));
        strategyManager.moveInvestment(token, moveInvestmentData);
    }

    // Tests if invest function reverts correctly when strategyTo is inactive
    function test_moveInvestment_when_strategyToInactive() public {
        address user = address(uint160(uint256(keccak256("random user"))));
        address token = address(usdc);
        address strategyTo = address(strategyWithoutRewardsMock);
        uint256 amount = 1e18;

        initiateUser(user, address(usdc), amount);

        IStrategyManager.StrategyInfo memory info;
        info.whitelisted = true;
        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.updateStrategy(strategyTo, info);

        IStrategyManager.MoveInvestmentData memory moveInvestmentData;
        moveInvestmentData.strategyFrom = address(
            new StrategyWithoutRewardsMock(
                address(managerContainer),
                address(usdc),
                address(usdc),
                address(0),
                address(jigsawMinter),
                "AnotherMock",
                "ARM"
            )
        );
        vm.startPrank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategy(moveInvestmentData.strategyFrom);
        vm.stopPrank();
        moveInvestmentData.strategyTo = strategyTo;

        vm.prank(user, user);
        vm.expectRevert(bytes("1202"));
        strategyManager.moveInvestment(token, moveInvestmentData);
    }

    // Tests if moveInvestment function reverts correctly when claimResult from the strategyFrom is 0
    function test_moveInvestment_when_claimResult0() public {
        vm.startPrank(strategyManager.owner(), strategyManager.owner());
        MaliciousStrategy strategyFrom =
            new MaliciousStrategy(address(managerContainer), address(usdc), address(jigsawMinter), "AnotherMock", "ARM");
        strategyManager.addStrategy(address(strategyFrom));
        vm.stopPrank();

        address user = address(uint160(uint256(keccak256("random user"))));
        address token = address(usdc);
        StrategyWithoutRewardsMock strategyTo = strategyWithoutRewardsMock;
        uint256 amount = 1e18;

        address holding = initiateUser(user, address(usdc), amount);

        vm.prank(user, user);
        strategyManager.invest(token, address(strategyFrom), amount, bytes(""));

        IStrategyManager.MoveInvestmentData memory moveInvestmentData;
        moveInvestmentData.strategyFrom = address(strategyFrom);
        moveInvestmentData.strategyTo = address(strategyTo);
        moveInvestmentData.shares = amount;

        vm.prank(user, user);
        vm.expectRevert(bytes("3016"));
        strategyManager.moveInvestment(token, moveInvestmentData);

        address[] memory holdingStrategies = strategyManager.getHoldingToStrategy(holding);

        assertEq(holdingStrategies.length, 1, "Holding's strategies' count incorrect");
        assertEq(holdingStrategies[0], address(strategyFrom), "Holding's strategy saved incorrectly");
        assertEq(usdc.balanceOf(address(strategyFrom)), amount, "strategyFrom wrongfully sent funds");
        assertEq(usdc.balanceOf(address(strategyTo)), 0, "strategyTo wrongfully received funds");
        assertEq(
            IERC20(address(strategyFrom.receiptToken())).balanceOf(holding),
            amount,
            "StrategyFrom receipt tokens incorrect"
        );
        assertEq(
            IERC20(address(strategyTo.receiptToken())).balanceOf(holding), 0, "StrategyTo receipt tokens incorrect"
        );
    }

    // Tests if moveInvestment function works correctly
    function test_moveInvestment_when_authorized() public {
        vm.startPrank(strategyManager.owner(), strategyManager.owner());
        StrategyWithoutRewardsMock strategyTo = new StrategyWithoutRewardsMock(
            address(managerContainer),
            address(usdc),
            address(usdc),
            address(0),
            address(jigsawMinter),
            "AnotherMock",
            "ARM"
        );
        strategyManager.addStrategy(address(strategyTo));
        vm.stopPrank();

        address user = address(uint160(uint256(keccak256("random user"))));
        address token = address(usdc);
        StrategyWithoutRewardsMock strategyFrom = strategyWithoutRewardsMock;
        uint256 amount = 1e18;

        address holding = initiateUser(user, address(usdc), amount);

        vm.prank(user, user);
        strategyManager.invest(token, address(strategyFrom), amount, bytes(""));

        IStrategyManager.MoveInvestmentData memory moveInvestmentData;
        moveInvestmentData.strategyFrom = address(strategyFrom);
        moveInvestmentData.strategyTo = address(strategyTo);
        moveInvestmentData.shares = amount;

        vm.prank(user, user);
        vm.expectEmit();
        emit InvestmentMoved(
            holding, user, token, moveInvestmentData.strategyFrom, moveInvestmentData.strategyTo, amount, amount, amount
        );
        strategyManager.moveInvestment(token, moveInvestmentData);

        address[] memory holdingStrategies = strategyManager.getHoldingToStrategy(holding);

        assertEq(holdingStrategies.length, 1, "Holding's strategies' count incorrect");
        assertEq(holdingStrategies[0], address(strategyTo), "Holding's strategy saved incorrectly");
        assertEq(usdc.balanceOf(address(strategyFrom)), 0, "strategyFrom didn't send funds");
        assertEq(usdc.balanceOf(address(strategyTo)), amount, "strategyTo didn't receive funds");
        assertEq(
            IERC20(address(strategyFrom.receiptToken())).balanceOf(holding), 0, "StrategyFrom receipt tokens incorrect"
        );
        assertEq(
            IERC20(address(strategyTo.receiptToken())).balanceOf(holding), amount, "StrategyTo receipt tokens incorrect"
        );
    }

    // Tests if claimInvestment reverts correctly when invalid strategy address
    function test_claimInvestment_when_invalidStrategy() public {
        address holding = address(0);
        address strategy = address(0);
        uint256 shares = 0;
        address asset = address(0);
        bytes memory data = bytes("");

        vm.expectRevert(bytes("3029"));
        strategyManager.claimInvestment(holding, strategy, shares, asset, data);
    }

    // Tests if claimInvestment reverts correctly when caller is unauthorized
    function test_claimInvestment_when_unauthorized(address caller) public {
        address holding = address(0);
        address strategy = address(strategyWithoutRewardsMock);
        uint256 shares = 0;
        address asset = address(0);
        bytes memory data = bytes("");

        vm.assume(
            caller != manager.holdingManager() && caller != manager.liquidationManager()
                && caller != holdingManager.holdingUser(holding)
        );

        vm.expectRevert(bytes("1000"));
        vm.prank(caller, caller);
        strategyManager.claimInvestment(holding, strategy, shares, asset, data);
    }

    // Tests if claimInvestment reverts correctly when invalid amount of shares
    function test_claimInvestment_when_invalidAmount() public {
        address holding = address(0);
        address strategy = address(strategyWithoutRewardsMock);
        uint256 shares = 0;
        address asset = address(0);
        bytes memory data = bytes("");

        vm.prank(manager.holdingManager(), manager.holdingManager());
        vm.expectRevert(bytes("2001"));
        strategyManager.claimInvestment(holding, strategy, shares, asset, data);
    }

    // Tests if claimInvestment reverts correctly when paused
    function test_claimInvestment_when_paused() public {
        address holding = address(0);
        address strategy = address(strategyWithoutRewardsMock);
        uint256 shares = 1;
        address asset = address(0);
        bytes memory data = bytes("");

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.setPaused(true);

        vm.prank(manager.holdingManager(), manager.holdingManager());
        vm.expectRevert(bytes("1200"));
        strategyManager.claimInvestment(holding, strategy, shares, asset, data);
    }

    // Tests if claimInvestment reverts correctly when invalid holding
    function test_claimInvestment_when_notHolding(address holding) public {
        address strategy = address(strategyWithoutRewardsMock);
        uint256 shares = 1;
        address asset = address(0);
        bytes memory data = bytes("");

        vm.prank(manager.holdingManager(), manager.holdingManager());
        vm.expectRevert(bytes("3002"));
        strategyManager.claimInvestment(holding, strategy, shares, asset, data);
    }

    // Tests if claimInvestment works  correctly when not enough Receipt Tokens in holding and need to unstake
    function test_claimInvestment_when_unstake(address user, uint256 amount) public {
        vm.assume(user != address(0));
        vm.assume(amount > 0 && amount < 1e20);
        address asset = address(usdc);
        address holding = initiateUser(user, asset, amount);
        address strategy = address(strategyWithoutRewardsMock);
        address receiptToken = strategyWithoutRewardsMock.getReceiptTokenAddress();
        address gauge = liquidityGaugeFactory.createLiquidityGauge(receiptToken, address(jigsawMinter), OWNER);
        bytes memory data = bytes("");
        uint256 holdingBalanceBefore = usdc.balanceOf(holding);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategyGauge(strategy, gauge);

        vm.startPrank(user, user);
        strategyManager.invest(asset, strategy, holdingBalanceBefore, data);
        uint256 holdingReceiptTokenBalanceAfterInvest = IERC20(receiptToken).balanceOf(holding);
        strategyManager.stakeReceiptTokens(strategy, holdingReceiptTokenBalanceAfterInvest);

        (, uint256 shares) = strategyWithoutRewardsMock.recipients(holding);
        uint256 claimAmount = shares;

        strategyManager.claimInvestment(holding, strategy, claimAmount, asset, data);
        vm.stopPrank();

        address[] memory holdingStrategies = strategyManager.getHoldingToStrategy(holding);

        assertEq(holdingStrategies.length, 0, "Holding's strategies' count incorrect");
        assertEq(
            IERC20(receiptToken).balanceOf(holding), shares - claimAmount, "Holding's receipt tokens count incorrect"
        );
        assertEq(IERC20(receiptToken).balanceOf(holding), 0, "Gauge's receipt tokens count incorrect");
        assertEq(usdc.balanceOf(strategy), shares - claimAmount, "Funds weren't taken from strategy");
        assertEq(usdc.balanceOf(holding), claimAmount, "Holding didn't receive funds invested in strategy");
    }

    // Tests if claimInvestment works  correctly when receiptToken has big decimals
    function test_claimInvestment_when_bigDecimals(address user, uint256 amount) public {
        vm.assume(user != address(0));
        vm.assume(amount > 1e6 && amount < 1e20);

        SampleTokenBigDecimals asset = new SampleTokenBigDecimals("BDT", "BDT", 0);

        vm.startPrank(OWNER, OWNER);
        manager.whitelistToken(address(asset));
        SharesRegistry bdtSharesRegistry = new SharesRegistry(
            msg.sender, address(managerContainer), address(asset), address(usdcOracle), bytes(""), 50_000
        );
        stablesManager.registerOrUpdateShareRegistry(address(bdtSharesRegistry), address(asset), true);
        vm.stopPrank();

        address holding = initiateUser(user, address(asset), amount);

        address strategy = address(
            new StrategyWithRewardsMock(
                address(managerContainer),
                address(asset),
                address(asset),
                address(0),
                address(jigsawMinter),
                "RandomToken",
                "RT"
            )
        );

        address receiptToken = IStrategy(strategy).getReceiptTokenAddress();
        address gauge = liquidityGaugeFactory.createLiquidityGauge(receiptToken, address(jigsawMinter), OWNER);
        bytes memory data = bytes("");

        vm.startPrank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategy(strategy);
        strategyManager.addStrategyGauge(strategy, gauge);
        vm.stopPrank();

        uint256 holdingBalanceBefore = asset.balanceOf(holding);

        vm.startPrank(user, user);
        strategyManager.invest(address(asset), strategy, holdingBalanceBefore, data);
        uint256 holdingReceiptTokenBalanceAfterInvest = IERC20(receiptToken).balanceOf(holding);

        strategyManager.stakeReceiptTokens(strategy, holdingReceiptTokenBalanceAfterInvest);

        (, uint256 shares) = IStrategy(strategy).recipients(holding);
        uint256 claimAmount = shares;
        strategyManager.claimInvestment(holding, strategy, claimAmount, address(asset), data);
        vm.stopPrank();

        address[] memory holdingStrategies = strategyManager.getHoldingToStrategy(holding);
        assertEq(holdingStrategies.length, 0, "Holding's strategies' count incorrect");
        assertEq(
            IERC20(receiptToken).balanceOf(holding), shares - claimAmount, "Holding's receipt tokens count incorrect"
        );
        assertEq(IERC20(receiptToken).balanceOf(holding), 0, "Gauge's receipt tokens count incorrect");
        assertEq(asset.balanceOf(strategy), shares - claimAmount, "Funds weren't taken from strategy");
        assertEq(asset.balanceOf(holding), claimAmount, "Holding didn't receive funds invested in strategy");
    }

    // Tests if claimInvestment works  correctly
    function test_claimInvestment_when_authorized(address user, uint256 amount, uint256 _shares) public {
        vm.assume(user != address(0));
        vm.assume(amount > 0 && amount < 1e20);
        address asset = address(usdc);
        address holding = initiateUser(user, asset, amount);
        address strategy = address(strategyWithoutRewardsMock);
        bytes memory data = bytes("");
        uint256 holdingBalanceBefore = usdc.balanceOf(holding);

        vm.prank(user, user);
        strategyManager.invest(asset, strategy, holdingBalanceBefore, data);
        (, uint256 shares) = strategyWithoutRewardsMock.recipients(holding);
        uint256 claimAmount = bound(_shares, 1, shares);

        vm.prank(user, user);
        strategyManager.claimInvestment(holding, strategy, claimAmount, asset, data);

        address[] memory holdingStrategies = strategyManager.getHoldingToStrategy(holding);

        (, uint256 remainingShares) = strategyWithoutRewardsMock.recipients(holding);
        if (remainingShares == 0) {
            assertEq(holdingStrategies.length, 0, "Holding's strategies' count incorrect");
        } else {
            assertEq(holdingStrategies.length, 1, "Holding's strategies' count incorrect");
            assertEq(holdingStrategies[0], strategy, "Holding's strategy saved incorrectly");
        }
        assertEq(
            IERC20(address(strategyWithoutRewardsMock.receiptToken())).balanceOf(holding),
            shares - claimAmount,
            "Holding's receipt tokens count incorrect"
        );
        assertEq(usdc.balanceOf(strategy), shares - claimAmount, "Funds weren't taken from strategy");
        assertEq(usdc.balanceOf(holding), claimAmount, "Holding didn't receive funds invested in strategy");
    }

    // Tests if claimRewards function reverts correctly when invalidStrategy
    function test_claimRewards_when_invalidStrategy() public {
        address strategy = address(0);
        bytes memory data = bytes("");

        vm.expectRevert(bytes("3029"));
        strategyManager.claimRewards(strategy, data);
    }

    // Tests if claimRewards reverts correctly when paused
    function test_claimRewards_when_paused() public {
        address strategy = address(strategyWithoutRewardsMock);
        bytes memory data = bytes("");

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.setPaused(true);

        vm.expectRevert(bytes("1200"));
        strategyManager.claimRewards(strategy, data);
    }

    // Tests if claimRewards reverts correctly when invalid holding
    function test_claimRewards_when_notHolding() public {
        address strategy = address(strategyWithoutRewardsMock);
        bytes memory data = bytes("");

        vm.expectRevert(bytes("3002"));
        strategyManager.claimRewards(strategy, data);
    }

    // Tests if claimRewards works correctly when there are no rewards for the user
    function test_claimRewards_when_noRewards() public {
        address user = address(uint160(uint256(keccak256("random user"))));
        uint256 amount = 10e6;
        address asset = address(usdc);
        initiateUser(user, asset, amount);
        address strategy = address(strategyWithoutRewardsMock);
        bytes memory data = bytes("");

        vm.prank(user, user);
        strategyManager.claimRewards(strategy, data);
    }

    // Tests if claimRewards works correctly when authorized
    function test_claimRewards_when_authorized(address user, uint256 amount) public {
        vm.assume(user != address(0));
        vm.assume(amount > 0 && amount < 1e20);
        address asset = address(usdc);
        address holding = initiateUser(user, asset, amount);
        SampleTokenERC20 strategyRewardToken = new SampleTokenERC20("StrategyRewardToken", "SRT", 0);
        address strategy = address(
            new StrategyWithRewardsMock(
                address(managerContainer),
                address(usdc),
                address(usdc),
                address(strategyRewardToken),
                address(jigsawMinter),
                "RandomToken",
                "RT"
            )
        );
        bytes memory data = bytes("");
        uint256 holdingBalanceBefore = usdc.balanceOf(holding);
        uint256 holdingRewardBalanceBefore = strategyRewardToken.balanceOf(holding);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategy(strategy);

        vm.startPrank(user, user);
        strategyManager.invest(asset, strategy, holdingBalanceBefore, data);
        strategyManager.claimRewards(strategy, data);
        vm.stopPrank();

        assertEq(
            strategyRewardToken.balanceOf(holding),
            holdingRewardBalanceBefore + 100 * 10 ** strategyRewardToken.decimals(),
            "Holding didn't receive rewards after claimRewards"
        );
        assertEq(
            SharesRegistry(registries[asset]).collateral(holding),
            holdingBalanceBefore,
            "Holding's collateral amount wrongfully increased after claimRewards"
        );
    }

    // Tests if claimRewards works correctly when the {rewardToken} and {tokenIn} are the same
    function test_claimRewards_when_sameToken(address user, uint256 amount) public {
        vm.assume(user != address(0));
        vm.assume(amount > 0 && amount < 1e20);
        address asset = address(usdc);
        address holding = initiateUser(user, asset, amount);
        uint256 holdingBalanceBefore = usdc.balanceOf(holding);
        SampleTokenERC20 strategyRewardToken = usdc;
        address strategy = address(
            new StrategyWithRewardsMock(
                address(managerContainer),
                address(usdc),
                address(usdc),
                address(strategyRewardToken),
                address(jigsawMinter),
                "RandomToken",
                "RT"
            )
        );
        bytes memory data = bytes("");

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategy(strategy);

        vm.startPrank(user, user);
        strategyManager.invest(asset, strategy, holdingBalanceBefore, data);
        vm.expectEmit();
        emit CollateralAdjusted(holding, asset, 100 * 10 ** strategyRewardToken.decimals(), true);
        strategyManager.claimRewards(strategy, data);
        vm.stopPrank();

        assertEq(
            strategyRewardToken.balanceOf(holding),
            100 * 10 ** strategyRewardToken.decimals(),
            "Holding didn't receive rewards after claimRewards"
        );
        assertEq(
            SharesRegistry(registries[asset]).collateral(holding),
            holdingBalanceBefore + 100 * 10 ** strategyRewardToken.decimals(),
            "Holding's collateral amount hasn't increased after claimRewards"
        );
    }

    // Tests if invokeHolding reverts correctly when unauthorized
    function test_invokeHolding_when_unauthorized(address _caller) public {
        address holding = address(uint160(uint256(keccak256("random holding"))));
        address callableContract = address(uint160(uint256(keccak256("random contract"))));

        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("1000"));
        strategyManager.invokeHolding(holding, callableContract, bytes(""));
    }

    // Tests if invokeHolding works correctly when authorized
    function test_invokeHolding_when_authorized(address _caller) public {
        vm.assume(_caller != address(0));
        address holding = initiateUser(address(1), address(usdc), 10);
        address callableContract = address(usdc);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        manager.updateInvoker(_caller, true);

        vm.prank(_caller, _caller);
        (bool success,) =
            strategyManager.invokeHolding(holding, callableContract, abi.encodeWithSignature("decimals()"));
        assertEq(success, true, "invokeHolding failed");
    }

    // Tests if invokeApprove reverts correctly when unauthorized
    function test_invokeApprove_when_unauthorized(address _caller) public {
        address holding = address(uint160(uint256(keccak256("random holding"))));
        address token = address(uint160(uint256(keccak256("random token"))));
        address spender = address(uint160(uint256(keccak256("random spender"))));
        uint256 amount = 42;

        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("1000"));
        strategyManager.invokeApprove(holding, token, spender, amount);
    }

    // Tests if invokeApprove works correctly when authorized
    function test_invokeApprove_when_authorized(address _caller) public {
        vm.assume(_caller != address(0));
        address holding = initiateUser(address(1), address(usdc), 10);
        address token = address(usdc);
        address spender = address(uint160(uint256(keccak256("random spender"))));
        uint256 amount = 42;

        vm.prank(strategyManager.owner(), strategyManager.owner());
        manager.updateInvoker(_caller, true);

        vm.prank(_caller, _caller);
        strategyManager.invokeApprove(holding, token, spender, amount);

        assertEq(usdc.allowance(holding, spender), 42, "invokeApprove failed");
    }

    // Tests if invokeTransferal reverts correctly when unauthorized
    function test_invokeTransferal_when_unauthorized(address _caller) public {
        address holding = address(uint160(uint256(keccak256("random holding"))));
        address token = address(uint160(uint256(keccak256("random token"))));
        address to = address(uint160(uint256(keccak256("random to"))));
        uint256 amount = 42;

        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("1000"));
        strategyManager.invokeTransferal(holding, token, to, amount);
    }

    // Tests if invokeTransferal works correctly when authorized
    function test_invokeTransferal_when_authorized(address _caller) public {
        vm.assume(_caller != address(0));
        address holding = initiateUser(address(1), address(usdc), 10);
        address token = address(usdc);
        address to = address(uint160(uint256(keccak256("random to"))));
        uint256 amount = 42;

        vm.prank(strategyManager.owner(), strategyManager.owner());
        manager.updateInvoker(_caller, true);

        deal(address(usdc), holding, amount);
        vm.prank(_caller, _caller);
        strategyManager.invokeTransferal(holding, token, to, amount);

        assertEq(usdc.balanceOf(to), amount, "invokeTransferal failed");
    }

    // Tests if stakeReceiptTokens function reverts correctly when contract is paused
    function test_stakeReceiptTokens_when_paused() public {
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 10e18;

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.setPaused(true);

        vm.expectRevert(bytes("1200"));
        strategyManager.stakeReceiptTokens(strategy, amount);
    }

    // Tests if stakeReceiptTokens function reverts correctly when invalidStrategy
    function test_stakeReceiptTokens_when_invalidStrategy() public {
        address strategy = address(uint160(uint256(keccak256("random strategy"))));
        uint256 amount = 10e18;

        vm.expectRevert(bytes("3029"));
        strategyManager.stakeReceiptTokens(strategy, amount);
    }

    // Tests if stakeReceiptTokens function reverts correctly when invalid amount
    function test_stakeReceiptTokens_when_invalidAmount() public {
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 0;

        vm.expectRevert(bytes("2001"));
        strategyManager.stakeReceiptTokens(strategy, amount);
    }

    // Tests if stakeReceiptTokens function reverts correctly when invalid gauge
    function test_stakeReceiptTokens_when_invalidGauge() public {
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 10e18;

        vm.expectRevert(bytes("1104"));
        strategyManager.stakeReceiptTokens(strategy, amount);
    }

    // Tests if stakeReceiptTokens function reverts correctly when insufficient balance
    function test_stakeReceiptTokens_when_insufficientBalance() public {
        address strategy = address(strategyWithoutRewardsMock);
        address gauge = address(uint160(uint256(keccak256("random gauge"))));
        uint256 amount = 10e18;

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategyGauge(strategy, gauge);

        vm.expectRevert(bytes("2002"));
        strategyManager.stakeReceiptTokens(strategy, amount);
    }

    // Tests if stakeReceiptTokens function works correctly when genericCall fails
    function test_stakeReceiptTokens_when_fail(address _user) public {
        vm.assume(_user != address(0));
        uint256 _amount = type(uint256).max;

        address holding = initiateUser(_user, address(usdc), 42);
        address strategy = address(strategyWithoutRewardsMock);
        address receiptToken = strategyWithoutRewardsMock.getReceiptTokenAddress();
        address gauge = liquidityGaugeFactory.createLiquidityGauge(receiptToken, address(jigsawMinter), OWNER);

        deal(receiptToken, holding, _amount);
        uint256 receiptTokenBalanceBefore = IERC20(receiptToken).balanceOf(holding);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategyGauge(strategy, gauge);

        vm.prank(_user, _user);
        vm.expectRevert(bytes("3015"));
        strategyManager.stakeReceiptTokens(strategy, _amount);

        assertEq(
            IERC20(receiptToken).balanceOf(holding),
            receiptTokenBalanceBefore,
            "Holding's receiptTokenBalance after stake is incorrect"
        );
        assertEq(IERC20(receiptToken).balanceOf(gauge), 0, "Gauge balance after stake is incorrect");
    }

    // Tests if stakeReceiptTokens function works correctly when authorized
    function test_stakeReceiptTokens_when_authorized(address _user, uint256 _amount) public {
        vm.assume(_user != address(0));
        vm.assume(_amount > 0 && _amount < 1e40);

        address holding = initiateUser(_user, address(usdc), 42);
        address strategy = address(strategyWithoutRewardsMock);
        address receiptToken = strategyWithoutRewardsMock.getReceiptTokenAddress();
        address gauge = liquidityGaugeFactory.createLiquidityGauge(receiptToken, address(jigsawMinter), OWNER);

        deal(receiptToken, holding, _amount);
        uint256 receiptTokenBalanceBefore = IERC20(receiptToken).balanceOf(holding);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategyGauge(strategy, gauge);

        vm.prank(_user, _user);
        strategyManager.stakeReceiptTokens(strategy, _amount);

        assertEq(
            IERC20(receiptToken).balanceOf(holding),
            receiptTokenBalanceBefore - _amount,
            "Holding's receiptTokenBalance after stake is incorrect"
        );
        assertEq(IERC20(receiptToken).balanceOf(gauge), _amount, "Gauge balance after stake is incorrect");
    }

    // Tests if unstakeReceiptTokens function reverts correctly when contract is paused
    function test_unstakeReceiptTokens_when_paused() public {
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 10e18;

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.setPaused(true);

        vm.expectRevert(bytes("1200"));
        strategyManager.unstakeReceiptTokens(strategy, amount);
    }

    // Tests if unstakeReceiptTokens function reverts correctly when invalidStrategy
    function test_unstakeReceiptTokens_when_invalidStrategy() public {
        address strategy = address(uint160(uint256(keccak256("random strategy"))));
        uint256 amount = 10e18;

        vm.expectRevert(bytes("3029"));
        strategyManager.unstakeReceiptTokens(strategy, amount);
    }

    // Tests if unstakeReceiptTokens function reverts correctly when invalid amount
    function test_unstakeReceiptTokens_when_invalidAmount() public {
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 0;

        vm.expectRevert(bytes("2001"));
        strategyManager.unstakeReceiptTokens(strategy, amount);
    }

    // Tests if unstakeReceiptTokens function reverts correctly when invalid gauge
    function test_unstakeReceiptTokens_when_invalidGauge() public {
        address strategy = address(strategyWithoutRewardsMock);
        uint256 amount = 10e18;

        vm.expectRevert(bytes("1104"));
        strategyManager.unstakeReceiptTokens(strategy, amount);
    }

    // Tests if unstakeReceiptTokens function works correctly when genericCall fails
    function test_unstakeReceiptTokens_when_fail(address _user) public {
        vm.assume(_user != address(0));
        uint256 amount = 1e30;

        address holding = initiateUser(_user, address(usdc), 42);
        address strategy = address(strategyWithoutRewardsMock);
        address receiptToken = strategyWithoutRewardsMock.getReceiptTokenAddress();
        address gauge = liquidityGaugeFactory.createLiquidityGauge(receiptToken, address(jigsawMinter), OWNER);

        deal(receiptToken, holding, amount);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategyGauge(strategy, gauge);

        vm.startPrank(_user, _user);
        strategyManager.stakeReceiptTokens(strategy, amount);
        uint256 receiptTokenBalanceBefore = IERC20(receiptToken).balanceOf(holding);
        vm.expectRevert(bytes("3016"));
        strategyManager.unstakeReceiptTokens(strategy, type(uint256).max);
        vm.stopPrank();

        assertEq(
            IERC20(receiptToken).balanceOf(holding),
            receiptTokenBalanceBefore,
            "Holding's receiptTokenBalance after failed unstake is incorrect"
        );
        assertEq(IERC20(receiptToken).balanceOf(gauge), amount, "Gauge balance after stake is incorrect");
    }

    // Tests if unstakeReceiptTokens function works correctly when authorized
    function test_unstakeReceiptTokens_when_authorized(address _user, uint256 _amount) public {
        vm.assume(_user != address(0));
        vm.assume(_amount > 0 && _amount < 1e40);

        address holding = initiateUser(_user, address(usdc), 42);
        address strategy = address(strategyWithoutRewardsMock);
        address receiptToken = strategyWithoutRewardsMock.getReceiptTokenAddress();
        address gauge = liquidityGaugeFactory.createLiquidityGauge(receiptToken, address(jigsawMinter), OWNER);

        deal(receiptToken, holding, _amount);

        vm.prank(strategyManager.owner(), strategyManager.owner());
        strategyManager.addStrategyGauge(strategy, gauge);

        vm.startPrank(_user, _user);
        strategyManager.stakeReceiptTokens(strategy, _amount);
        uint256 receiptTokenBalanceBefore = IERC20(receiptToken).balanceOf(gauge);
        strategyManager.unstakeReceiptTokens(strategy, _amount);
        vm.stopPrank();

        assertEq(
            IERC20(receiptToken).balanceOf(holding), _amount, "Holding's receiptTokenBalance after unstake is incorrect"
        );
        assertEq(
            IERC20(receiptToken).balanceOf(gauge),
            receiptTokenBalanceBefore - _amount,
            "Gauge balance after unstake is incorrect"
        );
    }

    //Tests if renouncing ownership reverts with error code 1000
    function test_renounceOwnership() public {
        vm.expectRevert(bytes("1000"));
        strategyManager.renounceOwnership();
    }
}
