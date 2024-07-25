// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { ReceiptTokenFactory } from "../../src/ReceiptTokenFactory.sol";

contract ReceiptTokenFactoryTest is Test {
    ReceiptTokenFactory internal receiptTokenFactory;

    address internal OWNER = vm.addr(uint256(keccak256(bytes("OWNER"))));

    function setUp() public {
        receiptTokenFactory = new ReceiptTokenFactory(OWNER);
    }

    // Test if setReceiptTokenReferenceImplementation function reverts correctly when receipt token implementation is
    // set to address(0)
    function test_setReceiptTokenReferenceImplementation_when_address0() public {
        vm.prank(OWNER);
        vm.expectRevert(bytes("3000"));
        receiptTokenFactory.setReceiptTokenReferenceImplementation(address(0));
    }
}
