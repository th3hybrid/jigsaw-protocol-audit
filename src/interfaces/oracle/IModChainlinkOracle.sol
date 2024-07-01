// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IOracle } from "./IOracle.sol";

interface IModChainlinkOracle is IOracle {
    event AggregatorAdded(address indexed token, address indexed aggregator);

    function aggregators(address token) external view returns (address);

    function getDataParameter(address token) external view returns (bytes memory);
}
