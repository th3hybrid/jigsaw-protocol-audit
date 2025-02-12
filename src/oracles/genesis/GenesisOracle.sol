// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IOracle } from "../../../interfaces/oracle/IOracle.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title GenesisOracle
 *
 * @notice A mock oracle contract for the jUSD token, implementing the IOracle interface.
 *
 * @dev This contract provides a fixed exchange rate of 1:1 for jUSD and includes basic metadata functions.
 * @dev It serves as a temporary solution during the initial phase of the protocol and must be replaced by a real
 * on-chain oracle as soon as one becomes available.
 *
 * @author Hovooo (@hovooo)
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract GenesisOracle is IOracle {
    // -- Errors --

    /**
     * @notice Thrown when an invalid address is provided.
     * @dev This error is thrown when the provided address is the zero address (address(0)).
     */
    error InvalidAddress();

    // -- State variables --

    /**
     * @notice Address of the underlying token for this oracle (jUSD).
     */
    address public override underlying;

    // -- Constructor --

    /**
     * @notice Initializes the oracle with the specified jUSD token address.
     * @dev Ensures the provided address is not zero.
     * @param _jUSD Address of the jUSD token contract.
     */
    constructor(
        address _jUSD
    ) Ownable(_initialOwner) {
        if (_jUSD == address(0)) revert InvalidAddress();
        underlying = _jUSD;
    }

    // -- Getters --

    /**
     * @notice Always returns a fixed exchange rate of 1e18 (1:1).
     *
     * @return success Boolean indicating whether a valid rate is available.
     * @return rate The exchange rate of the underlying asset.
     */
    function peek(
        bytes calldata
    ) external view returns (bool success, uint256 rate) {
        rate = 1e18; // Fixed rate of 1 jUSD = 1 USD
        success = true;
    }

    /**
     * @notice Retrieves the name of the underlying token.
     * @return The human-readable name of the jUSD token.
     */
    function name() external view override returns (string memory) {
        return IERC20Metadata(underlying).name();
    }

    /**
     * @notice Retrieves the symbol of the underlying token.
     * @return The human-readable symbol of the jUSD token.
     */
    function symbol() external view override returns (string memory) {
        return IERC20Metadata(underlying).symbol();
    }
}
