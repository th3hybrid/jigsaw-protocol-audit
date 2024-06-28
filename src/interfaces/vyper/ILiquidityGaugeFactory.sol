// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILiquidityGaugeFactory {
    event LiquidityGaugeCreated(
        address indexed liquidityGauge,
        address indexed receiptToken,
        address minter,
        address owner
    );

    function createLiquidityGauge(
        address _receiptToken,
        address _minter,
        address _owner
    ) external returns (address);
}
