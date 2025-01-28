// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { PythOracle } from "src/oracles/pyth/PythOracle.sol";

import { PythOracleFactory } from "src/oracles/pyth/PythOracleFactory.sol";
import { IPythOracle } from "src/oracles/pyth/interfaces/IPythOracle.sol";

contract PythOracleTest is Test {
    error OwnableUnauthorizedAccount(address account);

    PythOracle internal pythOracle;
    PythOracleFactory internal pythOracleFactory;
    address internal pythOracleImplementation;

    address internal constant OWNER = address(uint160(uint256(keccak256("owner"))));
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant PYTH = 0x4305FB66699C3B2702D4d05CF36551390A4c69C6;
    bytes32 internal constant PRICE_ID = 0x9d4294bbcd1174d6f2003ec365831e64cc31d9f6f15a2b85399db8d5000960f6;
    uint256 internal constant AGE = type(uint256).max;

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"), 21_722_108);

        pythOracleImplementation = address(new PythOracle());
        pythOracleFactory =
            new PythOracleFactory({ _initialOwner: OWNER, _referenceImplementation: pythOracleImplementation });
    }

    // Tests whether the initialization went right
    function test_pyth_initialization() public withRegularOracle {
        vm.assertEq(
            pythOracleFactory.referenceImplementation(), pythOracleImplementation, "Reference implementation wrong"
        );
        vm.assertEq(pythOracleFactory.owner(), OWNER, "Owner in factory set wrong");

        vm.assertEq(pythOracle.owner(), OWNER, "Owner in oracle set wrong");
        vm.assertEq(pythOracle.underlying(), WETH, "underlying in oracle set wrong");
        vm.assertEq(pythOracle.pyth(), PYTH, "PYTH in oracle set wrong");
        vm.assertEq(pythOracle.priceId(), PRICE_ID, "PRICE_ID in oracle set wrong");
        vm.assertEq(pythOracle.age(), AGE, "AGE in oracle set wrong");
    }

    // Tests whether the oracle returns success false when price is too old
    function test_pyth_peek_when_fail() public {
        pythOracle = PythOracle(
            pythOracleFactory.createPythOracle({
                _initialOwner: OWNER,
                _underlying: WETH,
                _pyth: PYTH,
                _priceId: PRICE_ID,
                _age: 1 seconds
            })
        );

        (bool success, uint256 rate) = pythOracle.peek("");

        vm.assertEq(success, false, "Peek must have returned false");
        vm.assertEq(rate, 0, "Peek must have returned 0");
    }

    // Tests whether the oracle returns valid rate
    function test_pyth_peek_when_validResponse() public withRegularOracle {
        (bool success, uint256 rate) = pythOracle.peek("");

        vm.assertEq(success, true, "Peek failed");
        vm.assertEq(rate, 3_295_633_182_430_000_000_000, "Rate is wrong");
    }

    function test_pyth_updateAge(
        uint256 _newAge
    ) public withRegularOracle {
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(this)));
        pythOracle.updateAge(0);

        vm.startPrank(OWNER, OWNER);
        vm.expectRevert(IPythOracle.InvalidAge.selector);
        pythOracle.updateAge(0);

        uint256 oldAge = pythOracle.age();
        vm.expectRevert(IPythOracle.InvalidAge.selector);
        pythOracle.updateAge(oldAge);

        vm.assume(_newAge != oldAge && _newAge != 0);

        vm.expectEmit();
        emit IPythOracle.AgeUpdated({ oldValue: oldAge, newValue: _newAge });
        pythOracle.updateAge(_newAge);

        vm.assertEq(pythOracle.age(), _newAge, "Age wrong after update");
        vm.stopPrank();
    }

    modifier withRegularOracle() {
        pythOracle = PythOracle(
            pythOracleFactory.createPythOracle({
                _initialOwner: OWNER,
                _underlying: WETH,
                _pyth: PYTH,
                _priceId: PRICE_ID,
                _age: AGE
            })
        );
        _;
    }
}
