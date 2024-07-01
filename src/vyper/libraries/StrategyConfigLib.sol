// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { IReceiptTokenFactory } from "../../interfaces/core/IReceiptTokenFactory.sol";
import { IStrategyManager } from "../../interfaces/core/IStrategyManager.sol";
import { ILiquidityGaugeFactory } from "../../interfaces/vyper/ILiquidityGaugeFactory.sol";

library StrategyConfigLib {
    /// @notice deploys the receipt token and liquidity gauge associated with this strategy
    /// @param _receiptTokenFactory address of the receipt token factory
    /// @param _liquidityGaugeFactory address of the liquidity gauge factory
    /// @param _minter jigsaw minter address
    /// @param _receiptTokenName name of the receipt token
    /// @param _receiptTokenSymbol symbol of the receipt token
    function configStrategy(
        address _receiptTokenFactory,
        address _liquidityGaugeFactory,
        address _minter,
        string memory _receiptTokenName,
        string memory _receiptTokenSymbol
    ) internal returns (address) {
        address receiptToken = IReceiptTokenFactory(_receiptTokenFactory).createReceiptToken(
            _receiptTokenName, _receiptTokenSymbol, address(this), msg.sender
        );
        ILiquidityGaugeFactory(_liquidityGaugeFactory).createLiquidityGauge(receiptToken, _minter, msg.sender);
        return (receiptToken);
    }
}
