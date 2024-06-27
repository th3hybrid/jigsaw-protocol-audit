// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { ISharesRegistry } from "../../src/interfaces/stablecoin/ISharesRegistry.sol";
import { SharesRegistry } from "../../src/stablecoin/SharesRegistry.sol";
import { BasicContractsFixture } from "../fixtures/BasicContractsFixture.t.sol";

contract SharesRegistryTest is BasicContractsFixture {
    /// @notice event emitted when contract new ownership is accepted
    event OwnershipAccepted(address indexed newOwner);
    /// @notice event emitted when contract ownership transferal was initated
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    /// @notice event emitted when collateral was registered
    event CollateralAdded(address indexed user, uint256 share);
    /// @notice event emitted when collateral was unregistered
    event CollateralRemoved(address indexed user, uint256 share);
    /// @notice event emitted when the collateralization rate is updated
    event CollateralizationRateUpdated(uint256 oldVal, uint256 newVal);
    /// @notice event emitted when accrue was called
    event Accrued(uint256 updatedTotalBorrow, uint256 extraAmount);
    /// @notice oracle data updated
    event OracleDataUpdated();
    /// @notice emitted when new oracle data is requested
    event NewOracleDataRequested(bytes newData);
    /// @notice emitted when new oracle is requested
    event NewOracleRequested(address newOracle);
    /// @notice oracle updated
    event OracleUpdated();
    /// @notice event emitted when borrowed amount is set
    event BorrowedSet(address indexed _holding, uint256 oldVal, uint256 newVal);
    // @notice event emitted when timelock amount is updated
    event TimelockAmountUpdated(uint256 oldVal, uint256 newVal);
    // @notice event emitted when a new timelock amount is requested
    event TimelockAmountUpdateRequested(uint256 oldVal, uint256 newVal);
    /// @notice event emitted when interest per second is updated
    event InterestUpdated(uint256 oldVal, uint256 newVal);

    ISharesRegistry internal registry;

    function setUp() public {
        init();
        registry = ISharesRegistry(registries[address(usdc)]);
    }

    // Tests if init fails correctly when owner is address(0)
    function test_init_when_invalidOwner() public {
        address owner = address(0);
        address container = address(0);
        address token = address(0);
        address oracle = address(0);
        bytes memory data = "0x0";
        uint256 colRate = 0;
        vm.expectRevert(bytes("3032"));
        SharesRegistry failedSharesRegistry = new SharesRegistry(owner, container, token, oracle, data, colRate);
        failedSharesRegistry;
    }

    // Tests if init fails correctly when _managerContainer is address(0)
    function test_init_when_invalidContainer() public {
        address owner = address(1);
        address container = address(0);
        address token = address(0);
        address oracle = address(0);
        bytes memory data = "0x0";
        uint256 colRate = 0;
        vm.expectRevert(bytes("3065"));
        SharesRegistry failedSharesRegistry = new SharesRegistry(owner, container, token, oracle, data, colRate);
        failedSharesRegistry;
    }

    // Tests if init fails correctly when token is address(0)
    function test_init_when_invalidToken() public {
        address owner = address(1);
        address container = address(1);
        address token = address(0);
        address oracle = address(0);
        bytes memory data = "0x0";
        uint256 colRate = 0;
        vm.expectRevert(bytes("3001"));
        SharesRegistry failedSharesRegistry = new SharesRegistry(owner, container, token, oracle, data, colRate);
        failedSharesRegistry;
    }

    // Tests if init fails correctly when oracle is address(0)
    function test_init_when_invalidOracle() public {
        address owner = address(1);
        address container = address(1);
        address token = address(1);
        address oracle = address(0);
        bytes memory data = "0x0";
        uint256 colRate = 0;
        vm.expectRevert(bytes("3034"));
        SharesRegistry failedSharesRegistry = new SharesRegistry(owner, container, token, oracle, data, colRate);
        failedSharesRegistry;
    }

    // Tests if init fails correctly when _collateralizationRate is invalid
    function test_init_when_invalidColRate(uint256 _colRate) public {
        address owner = address(1);
        address container = address(managerContainer);
        address token = address(1);
        address oracle = address(1);
        bytes memory data = "0x0";

        if (_colRate > 1e5) {
            vm.expectRevert(bytes("3066"));
        } else if (_colRate < 20e3) {
            vm.expectRevert(bytes("2001"));
        } else {
            return;
        }

        SharesRegistry failedSharesRegistry = new SharesRegistry(owner, container, token, oracle, data, _colRate);
        failedSharesRegistry;
    }

    // Tests if requestNewOracle reverts correctly when caller is not authorized
    function test_requestNewOracle_when_unauthorized(address _caller) public onlyNotOwner(_caller) {
        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("1000"));
        registry.requestNewOracle(address(2));
    }

    // Tests if requestNewOracle reverts correctly when oracle in active change
    function test_requestNewOracle_when_inActiveChange(address _oracle) public {
        vm.assume(_oracle != address(0));
        vm.prank(registry.owner(), registry.owner());
        registry.requestNewOracle(_oracle);

        vm.prank(registry.owner(), registry.owner());
        vm.expectRevert(bytes("3093"));
        registry.requestNewOracle(_oracle);
    }

    // Tests if requestNewOracle reverts correctly when time lock is in active change
    function test_requestNewOracle_when_timelockInActiveChange(uint256 _newVal) public {
        vm.assume(_newVal != 0);
        vm.prank(registry.owner(), registry.owner());
        registry.requestTimelockAmountChange(_newVal);

        vm.prank(registry.owner(), registry.owner());
        vm.expectRevert(bytes("3095"));
        registry.requestNewOracle(address(1));
        vm.stopPrank();
    }

    // Tests if requestNewOracle reverts correctly when oracle is address(0)
    function test_requestNewOracle_when_invalidOracle() public {
        vm.prank(registry.owner(), registry.owner());
        vm.expectRevert(bytes("3000"));
        registry.requestNewOracle(address(0));
    }

    // Tests if requestNewOracle works correctly when authorized
    function test_requestNewOracle_when_authorized(address _oracle) public {
        vm.assume(_oracle != address(0));
        vm.prank(registry.owner(), registry.owner());
        vm.expectEmit();
        emit NewOracleRequested(_oracle);
        registry.requestNewOracle(_oracle);
    }

    // Tests if requestNewOracle works correctly when authorized and oracle wasn't set
    function test_requestNewOracle_when_oldOracleNotUsed(address _oracle, address _otherOracle) public {
        vm.assume(_oracle != address(0));
        vm.assume(_otherOracle != address(0));

        vm.prank(registry.owner(), registry.owner());
        registry.requestNewOracle(_oracle);

        vm.warp(block.timestamp + 4 weeks);

        vm.prank(registry.owner(), registry.owner());
        registry.requestNewOracle(_otherOracle);
    }

    // Tests if setOracle reverts correctly when caller is not authorized
    function test_setOracle_when_unauthorized(address _caller) public onlyNotOwner(_caller) {
        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("1000"));
        registry.setOracle();
    }

    // Tests if setOracle reverts correctly when change is not requested (not in active change)
    function test_setOracle_when_notInActiveChange() public {
        vm.prank(registry.owner(), registry.owner());
        vm.expectRevert(bytes("3094"));
        registry.setOracle();
    }

    // Tests if setOracle reverts correctly when setting before time lock expired
    function test_setOracle_when_early(address _oracle) public {
        vm.assume(_oracle != address(0));
        vm.prank(registry.owner(), registry.owner());
        registry.requestNewOracle(_oracle);

        vm.prank(registry.owner(), registry.owner());
        vm.expectRevert(bytes("3066"));
        registry.setOracle();
    }

    // Tests if setOracle works correctly when authorized
    function test_setOracle_when_authorized(address _oracle) public {
        vm.assume(_oracle != address(0));
        vm.prank(registry.owner(), registry.owner());
        registry.requestNewOracle(_oracle);

        vm.warp(block.timestamp + 2 days);

        vm.prank(registry.owner(), registry.owner());
        vm.expectEmit();
        emit OracleUpdated();
        registry.setOracle();

        assertEq(address(registry.oracle()), _oracle, "Oracle was set incorrect");
    }

    // Tests if setInterestPerSecond reverts correctly when caller is not authorized
    function test_setInterestPerSecond_when_unauthorized(address _caller) public onlyNotOwner(_caller) {
        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("1000"));
        registry.setInterestPerSecond(uint64(1));
    }

    // Tests if setInterestPerSecond works correctly when authorized
    function test_setInterestPerSecond_when_authorized(uint64 _newVal) public {
        (,, uint64 oldInterest) = registry.accrueInfo();

        vm.prank(registry.owner(), registry.owner());
        vm.expectEmit();
        emit InterestUpdated(oldInterest, _newVal);
        registry.setInterestPerSecond(_newVal);

        (,, uint64 interest) = registry.accrueInfo();

        assertEq(interest, _newVal, "Interest per second is incorrect after setInterestPerSecond");
    }

    // Tests if requestTimelockAmountChange reverts correctly when caller is not authorized
    function test_requestTimelockAmountChange_when_unauthorized(address _caller) public onlyNotOwner(_caller) {
        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("1000"));
        registry.requestTimelockAmountChange(1);
    }

    // Tests if requestTimelockAmountChange reverts correctly when timelock in active change
    function test_requestTimelockAmountChange_when_inActiveChange(uint256 _newVal) public {
        vm.assume(_newVal != 0);
        vm.prank(registry.owner(), registry.owner());
        registry.requestTimelockAmountChange(_newVal);

        vm.prank(registry.owner(), registry.owner());
        vm.expectRevert(bytes("3095"));
        registry.requestTimelockAmountChange(1);
    }

    // Tests if requestTimelockAmountChange reverts correctly when oracle is in active change
    function test_requestTimelockAmountChange_when_oracleInActiveChange(uint256 _newVal) public {
        vm.assume(_newVal != 0);

        vm.prank(registry.owner(), registry.owner());
        registry.requestNewOracle(address(1));

        vm.prank(registry.owner(), registry.owner());
        vm.expectRevert(bytes("3093"));
        registry.requestTimelockAmountChange(_newVal);
    }

    // Tests if requestTimelockAmountChange reverts correctly when oracle data is in active change
    function test_requestTimelockAmountChange_when_oracleDataInActiveChange(uint256 _newVal) public {
        vm.assume(_newVal != 0);

        vm.prank(registry.owner(), registry.owner());
        registry.requestNewOracleData(bytes(""));

        vm.prank(registry.owner(), registry.owner());
        vm.expectRevert(bytes("3096"));
        registry.requestTimelockAmountChange(_newVal);
    }

    // Tests if requestTimelockAmountChange reverts correctly when _newVal == 0
    function test_requestTimelockAmountChange_when_invalidValue() public {
        vm.prank(registry.owner(), registry.owner());
        vm.expectRevert(bytes("2001"));
        registry.requestTimelockAmountChange(0);
    }

    // Tests if requestTimelockAmountChange works correctly when authorized
    function test_requestTimelockAmountChange_when_authorized(uint256 _newVal) public {
        vm.assume(_newVal != 0);
        uint256 oldLock = registry.timelockAmount();
        vm.expectEmit();
        emit TimelockAmountUpdateRequested(oldLock, _newVal);
        vm.prank(registry.owner(), registry.owner());
        registry.requestTimelockAmountChange(_newVal);

        vm.warp(block.timestamp + oldLock);

        vm.prank(registry.owner(), registry.owner());
        vm.expectEmit();
        emit TimelockAmountUpdated(oldLock, _newVal);
        registry.acceptTimelockAmountChange();

        assertEq(registry.timelockAmount(), _newVal);
    }

    // Tests if acceptTimelockAmountChange reverts correctly when caller is not authorized
    function test_acceptTimelockAmountChange_when_unauthorized(address _caller) public onlyNotOwner(_caller) {
        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("1000"));
        registry.acceptTimelockAmountChange();
    }

    // Tests if acceptTimelockAmountChange reverts correctly when not in active change
    function test_acceptTimelockAmountChange_when_notInActiveChange() public {
        vm.prank(registry.owner(), registry.owner());
        vm.expectRevert(bytes("3094"));
        registry.acceptTimelockAmountChange();
    }

    // Tests if setOracle reverts correctly when setting before time lock expired
    function test_acceptTimelockAmountChange_when_early() public {
        vm.prank(registry.owner(), registry.owner());
        registry.requestTimelockAmountChange(1);

        vm.prank(registry.owner(), registry.owner());
        vm.expectRevert(bytes("3066"));
        registry.acceptTimelockAmountChange();
    }

    // Tests if setCollateralizationRate reverts correctly when caller is not authorized
    function test_setCollateralizationRate_when_unauthorized(address _caller) public onlyNotOwner(_caller) {
        vm.prank(_caller, _caller);
        vm.expectRevert(bytes("1000"));
        registry.setCollateralizationRate(1);
    }

    // Tests if setCollateralizationRate reverts correctly when invalid amount
    function test_setCollateralizationRate_when_invalidAmount(uint256 _newVal) public {
        // _newVal = bound(_newVal, 0, 20e3 - 1);
        vm.prank(registry.owner(), registry.owner());

        if (_newVal > 1e5) {
            vm.expectRevert(bytes("3066"));
        } else if (_newVal < 20e3) {
            vm.expectRevert(bytes("2001"));
        } else {
            return;
        }

        registry.setCollateralizationRate(_newVal);
    }

    // Tests if setCollateralizationRate works correctly when authorized
    function test_setCollateralizationRate_when_authorized(uint256 _newVal) public {
        _newVal = bound(_newVal, 20e3, 1e5);
        vm.expectEmit();
        emit CollateralizationRateUpdated(registry.collateralizationRate(), _newVal);
        vm.prank(registry.owner(), registry.owner());
        registry.setCollateralizationRate(_newVal);

        assertEq(
            registry.collateralizationRate(),
            _newVal,
            "Collateralization rate incorrect after  setCollateralizationRate"
        );
    }

    // @note continue from requestNewOracleData()

    modifier onlyNotOwner(address _caller) {
        vm.assume(_caller != registry.owner());
        _;
    }
}
