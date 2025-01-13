// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { stdJson as StdJson } from "forge-std/Script.sol";
import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { TransferOwnership } from "../../script/ownership/06_TransferOwnership.s.sol";

import { JigsawUSD } from "../../src/JigsawUSD.sol";
import { ReceiptTokenFactory } from "../../src/ReceiptTokenFactory.sol";

contract TransferOwnershipTest is Test {
    using StdJson for string;

    address internal INITIAL_OWNER = vm.addr(vm.envUint("DEPLOYER_PRIVATE_KEY"));
    address internal MANAGER_CONTAINER = address(uint160(uint256(keccak256("MANAGER_CONTAINER"))));
    address internal NEW_OWNER = address(uint160(uint256(keccak256("NEW_OWNER"))));

    TransferOwnership internal transferOwnershipScript;

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        transferOwnershipScript = new TransferOwnership();
    }

    function test_transferOwnershipScript() public {
        vm.startPrank(INITIAL_OWNER, INITIAL_OWNER);
        JigsawUSD jUSD = new JigsawUSD({ _initialOwner: INITIAL_OWNER, _managerContainer: MANAGER_CONTAINER });
        ReceiptTokenFactory receiptTokenFactory =
            new ReceiptTokenFactory({ _initialOwner: INITIAL_OWNER, _referenceImplementation: address(jUSD) });
        vm.stopPrank();

        address[] memory transferOwnershipFrom = new address[](2);
        transferOwnershipFrom[0] = address(jUSD);
        transferOwnershipFrom[1] = address(receiptTokenFactory);

        transferOwnershipScript.run(transferOwnershipFrom, NEW_OWNER);

        vm.startPrank(NEW_OWNER, NEW_OWNER);
        jUSD.acceptOwnership();
        receiptTokenFactory.acceptOwnership();
        vm.stopPrank();

        assertEq(jUSD.owner(), NEW_OWNER, "NEW_OWNER in jUSD is wrong");
        assertEq(receiptTokenFactory.owner(), NEW_OWNER, "NEW_OWNER in receiptTokenFactory is wrong");
    }
}
