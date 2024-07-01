// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";

import { ILiquidityGauge } from "../interfaces/vyper/ILiquidityGauge.sol";
import { ILiquidityGaugeFactory } from "../interfaces/vyper/ILiquidityGaugeFactory.sol";

contract LiquidityGaugeFactory is ILiquidityGaugeFactory {
    address public referenceImplementation;

    constructor(address _referenceImplementation) {
        require(_referenceImplementation != address(0), "3000");
        referenceImplementation = _referenceImplementation;
    }

    function createLiquidityGauge(
        address _receiptToken,
        address _minter,
        address _owner
    ) public override returns (address newLiquidityGaugeAddress) {
        newLiquidityGaugeAddress = Clones.clone(referenceImplementation);

        ILiquidityGauge(newLiquidityGaugeAddress).initialize(_receiptToken, _minter, _owner);

        emit LiquidityGaugeCreated(newLiquidityGaugeAddress, _receiptToken, _minter, _owner);
    }
}
