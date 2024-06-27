// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Receipt token interface
interface IMinter {
    function mint(address _gauge) external;
}
