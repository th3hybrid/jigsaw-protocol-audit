// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOracle {
    /**
     * @notice Returns a human readable (short) name about this oracle.
     * @return (string) A human readable symbol name about this oracle.
     */
    function symbol() external view returns (string memory);

    /**
     * @notice Returns a human readable name about this oracle.
     * @return (string) A human readable name about this oracle.
     */
    function name() external view returns (string memory);

    /**
     * @notice Check the last exchange rate without any state changes.
     *
     * @param data Implementation specific data that contains information and arguments to & about the oracle.
     *
     * @return success If no valid (recent) rate is available, returns false else true.
     * @return rate The rate of the requested asset / pair / pool.
     */
    function peek(
        bytes calldata data
    ) external view returns (bool success, uint256 rate);
}
