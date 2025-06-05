// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

/**
 * @title MockUniswapV3Pool
 * @notice Mock implementation of IUniswapV3Pool for testing oracle vulnerabilities
 * @dev This mock allows us to simulate various pool states and failure conditions
 */
contract MockUniswapV3Pool {
    // Pool state variables - simplified for focused testing
    bool public isStale;

    // Mock data
    uint160 public mockSqrtPriceX96 = 79228162514264337593543950336; // ~1:1 price
    int24 public mockTick = 0;
    uint128 public mockLiquidity = 1000000e18; // Default liquidity

    // Observation data for TWAP
    struct Observation {
        uint32 blockTimestamp;
        int56 tickCumulative;
        uint160 secondsPerLiquidityCumulativeX128;
        bool initialized;
    }

    mapping(uint256 => Observation) public observations;
    uint16 public observationIndex;
    uint16 public observationCardinality = 1;

    constructor() {
        // Initialize with some default observations
        observations[0] = Observation({
            blockTimestamp: uint32(block.timestamp),
            tickCumulative: 0,
            secondsPerLiquidityCumulativeX128: 1000000000000000000000000000000000000, // Non-zero value
            initialized: true
        });
    }

    // State manipulation functions for testing
    function setStaleData() external {
        isStale = true;
        // Set old timestamp to simulate stale historical data
        observations[0].blockTimestamp = uint32(block.timestamp - 7200); // 2 hours old
    }

    // IUniswapV3Pool interface implementation
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex_,
            uint16 observationCardinality_,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        )
    {


        return (
            mockSqrtPriceX96,
            mockTick,
            observationIndex,
            observationCardinality,
            observationCardinality,
            0,
            true
        );
    }

    function liquidity() external view returns (uint128) {
        return mockLiquidity;
    }

    function observe(
        uint32[] calldata secondsAgos
    )
        external
        view
        returns (
            int56[] memory tickCumulatives,
            uint160[] memory secondsPerLiquidityCumulativeX128s
        )
    {
        uint256 length = secondsAgos.length;
        tickCumulatives = new int56[](length);
        secondsPerLiquidityCumulativeX128s = new uint160[](length);

        for (uint256 i = 0; i < length; i++) {
            if (isStale) {
                // Return stale data - simulate historical data that's outdated
                uint32 timeDelta = secondsAgos[i] > 0 ? secondsAgos[i] : 1;
                tickCumulatives[i] = int56(mockTick) * int56(int32(timeDelta));
                secondsPerLiquidityCumulativeX128s[i] = observations[0]
                    .secondsPerLiquidityCumulativeX128;
            } else {
                // Return normal data
                uint32 timeDelta = secondsAgos[i] > 0 ? secondsAgos[i] : 1;
                tickCumulatives[i] = int56(mockTick) * int56(int32(timeDelta));
                secondsPerLiquidityCumulativeX128s[i] = observations[0]
                    .secondsPerLiquidityCumulativeX128;
            }
        }
    }

    // Additional required functions (minimal implementation)
    function token0() external pure returns (address) {
        return 0xdAC17F958D2ee523a2206206994597C13D831ec7; // USDT
    }

    function token1() external pure returns (address) {
        return 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC
    }

    function fee() external pure returns (uint24) {
        return 500; // 0.05%
    }

    function tickSpacing() external pure returns (int24) {
        return 10;
    }

    // Stub implementations for other required functions
    function factory() external pure returns (address) {
        return address(0);
    }
    function maxLiquidityPerTick() external pure returns (uint128) {
        return type(uint128).max;
    }
    function protocolFees() external pure returns (uint128, uint128) {
        return (0, 0);
    }
    function positions(
        bytes32
    ) external pure returns (uint128, uint256, uint256, uint128, uint128) {
        return (0, 0, 0, 0, 0);
    }
    function ticks(
        int24
    )
        external
        pure
        returns (
            uint128,
            int128,
            uint256,
            uint256,
            int56,
            uint160,
            uint32,
            bool
        )
    {
        return (0, 0, 0, 0, 0, 0, 0, false);
    }
    function tickBitmap(int16) external pure returns (uint256) {
        return 0;
    }
    function feeGrowthGlobal0X128() external pure returns (uint256) {
        return 0;
    }
    function feeGrowthGlobal1X128() external pure returns (uint256) {
        return 0;
    }

    // Functions that would cause reverts in real scenarios
    function mint(
        address,
        int24,
        int24,
        uint128,
        bytes calldata
    ) external pure returns (uint256, uint256) {
        revert("Not implemented");
    }

    function burn(
        int24,
        int24,
        uint128
    ) external pure returns (uint256, uint256) {
        revert("Not implemented");
    }

    function swap(
        address,
        bool,
        int256,
        uint160,
        bytes calldata
    ) external pure returns (int256, int256) {
        revert("Not implemented");
    }

    function flash(address, uint256, uint256, bytes calldata) external pure {
        revert("Not implemented");
    }

    function increaseObservationCardinalityNext(uint16) external pure {
        revert("Not implemented");
    }

    function collect(
        address,
        int24,
        int24,
        uint128,
        uint128
    ) external pure returns (uint128, uint128) {
        revert("Not implemented");
    }

    function collectProtocol(
        address,
        uint128,
        uint128
    ) external pure returns (uint128, uint128) {
        revert("Not implemented");
    }

    function setFeeProtocol(uint8, uint8) external pure {
        revert("Not implemented");
    }
}
