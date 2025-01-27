// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IPyth } from "@pyth/IPyth.sol";
import { PythStructs } from "@pyth/PythStructs.sol";

import { IOracle } from "../interfaces/oracle/IOracle.sol";

/**
 * @title PythOracle Contract
 *
 * @notice Oracle contract that fetches and normalizes price data from Pyth Network.
 * @dev Implements IOracle interface and uses Pyth Network as price feed source.
 *
 * @author Hovooo (@hovooo)
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract PythOracle is IOracle, Initializable {
    struct InitializerParams {
        address underlying; // Address of the token the oracle is for.
        address pyth; // Pyth Oracle address.
        bytes32 priceId; //  Pyth's priceId used to determine the price of the `underlying`.
        uint256 age; // Age in seconds after which the price is considered invalid.
    }

    /**
     * @notice Address of the token the oracle is for.
     */
    address public override underlying;

    /**
     * @notice Pyth Oracle address.
     */
    address public override pyth;

    /**
     * @notice  Pyth's priceId used to determine the price of the `underlying`.
     */
    bytes32 public override priceId;

    /**
     * @notice Allowed age of the returned price in seconds.
     */
    uint256 public override age;

    /**
     * @notice The standard decimal precision (18) used for price normalization across the protocol
     */
    uint256 private constant ALLOWED_DECIMALS = 18;

    // -- Constructor --

    constructor() {
        _disableInitializers();
    }

    // -- Initialization --

    /**
     * @notice Initializes the Oracle contract with necessary parameters.
     */
    function initialize(
        InitializerParams memory _params
    ) public initializer {
        underlying = _params.underlying;
        pyth = _params.pyth;
        priceId = _params.priceId;
        age = _params.age;
    }

    // -- Getters --

    /**
     * @notice Check the last exchange rate without any state changes.
     *
     * @param data Implementation specific data that contains information and arguments to & about the oracle.
     *
     * @return success If no valid (recent) rate is available, returns false else true.
     * @return rate The rate of the requested asset / pair / pool.
     */
    function peek(
        bytes calldata
    ) external view returns (bool success, uint256 rate) {
        try IPyth(pyth).getPriceNoOlderThan({ id: priceId, age: age }) returns (PythStructs.Price memory price) {
            // Ensure price is not negative as negative prices are not supported
            if (price.price < 0) revert NegativeOraclePrice();

            // Check if exponent is positive which would make price too large
            if (price.expo > 0) revert ExpoTooBig();

            // Verify the exponent won't cause underflow when normalizing to ALLOWED_DECIMALS
            if (uint256(price.expo) > ALLOWED_DECIMALS) revert ExpoTooSmall();

            // Normalize the price to ALLOWED_DECIMALS (18)
            // Formula: price * 10^(ALLOWED_DECIMALS - expo)
            // Example: If price = 1234, expo = -8, ALLOWED_DECIMALS = 18
            // Result: 1234 * 10^(18 - uint256(-8)) = 1234 * 10^10
            rate = price.price * 10 ** (ALLOWED_DECIMALS - uint256(price.expo));
            success = true;
        } catch {
            // Return false and 0 if price fetch fails or is too old
            success = false;
            rate = 0;
        }
    }

    /**
     * @notice Returns a human readable name of the underlying of the oracle.
     */
    function name() external view override returns (string memory) {
        IERC20Metadata(underlying).name();
    }

    /**
     * @notice Returns a human readable symbol of the underlying of the oracle.
     */
    function symbol() external view override returns (string memory) {
        IERC20Metadata(underlying).symbol();
    }
}
