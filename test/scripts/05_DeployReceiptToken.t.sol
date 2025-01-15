// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../fixtures/ScriptTestsFixture.t.sol";

contract DeployReceiptTokenTest is Test, ScriptTestsFixture {
    function setUp() public {
        init();
    }

    function test_deploy_receiptToken() public view {
        // Perform checks on the ReceiptTokenFactory Contract
        assertEq(receiptTokenFactory.owner(), INITIAL_OWNER, "INITIAL_OWNER in ReceiptTokenFactory is wrong");
        assertEq(
            receiptTokenFactory.referenceImplementation(),
            address(receiptToken),
            "ReferenceImplementation in ReceiptTokenFactory is wrong"
        );
    }
}
