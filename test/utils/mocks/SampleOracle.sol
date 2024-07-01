// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IOracle } from "../../../src/interfaces/oracle/IOracle.sol";

contract SampleOracle is IOracle {
    uint256 public someNo;
    uint256 public price;
    bool public updated = true;

    constructor() {
        price = 1e18;
    }

    function setPrice(uint256 _price) external {
        price = _price;
    }

    function setPriceForLiquidation() external {
        price = 5e17;
    }

    function setPriceForPossibleLiquidation() external {
        price = 8e17;
    }

    function setAVeryLowPrice() external {
        price = 1e17;
    }

    function setRateTo0() external {
        price = 0;
    }

    function setUpdatedToFalse() external {
        updated = false;
    }

    function get(bytes calldata) external override returns (bool success, uint256 rate) {
        someNo = 1; //to avoid "can be restricted to pure" compiler warning
        return (true, price);
    }

    function peek(bytes calldata) external view override returns (bool success, uint256 rate) {
        return (updated, price);
    }

    function peekSpot(bytes calldata data) external view override returns (uint256 rate) 
    // solhint-disable-next-line no-empty-blocks
    { }

    function symbol(bytes calldata data) external view override returns (string memory) 
    // solhint-disable-next-line no-empty-blocks
    { }

    function name(bytes calldata data) external view override returns (string memory) 
    // solhint-disable-next-line no-empty-blocks
    { }
}
