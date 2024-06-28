// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Gauge controller interface
interface IGaugeController {
    // solhint-disable-next-line func-name-mixedcase
    function gauge_relative_weight(address addr) external view returns (uint256);

    // solhint-disable-next-line func-name-mixedcase
    function gauge_relative_weight_write(address addr) external returns (uint256);

    function add_type(string calldata _name, uint256 weight) external;

    function add_gauge(address addr, int128 gauge_type, uint256 weight) external;

    function admin() external view returns (address);
}
