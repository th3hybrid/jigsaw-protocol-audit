This file is a merged representation of a subset of the codebase, containing specifically included files, combined into a single document by Repomix.

# File Summary

## Purpose
This file contains a packed representation of the entire repository's contents.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Only files matching these patterns are included: src/**/*.*
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
```
src/
  interfaces/
    core/
      IHolding.sol
      IHoldingManager.sol
      IJigsawUSD.sol
      ILiquidationManager.sol
      IManager.sol
      IReceiptToken.sol
      IReceiptTokenFactory.sol
      ISharesRegistry.sol
      IStablesManager.sol
      IStaker.sol
      IStrategy.sol
      IStrategyManager.sol
      IStrategyManagerMin.sol
      ISwapManager.sol
    oracle/
      IOracle.sol
    IWETH.sol
  libraries/
    OperationsLib.sol
  oracles/
    chronicle/
      interfaces/
        IChronicleMinimal.sol
        IChronicleOracle.sol
        IChronicleOracleFactory.sol
      ChronicleOracle.sol
      ChronicleOracleFactory.sol
    genesis/
      GenesisOracle.sol
    uniswap/
      interfaces/
        IUniswapV3Oracle.sol
      GenericUniswapV3Oracle.sol
      UniswapV3Oracle.sol
  Holding.sol
  HoldingManager.sol
  JigsawUSD.sol
  LiquidationManager.sol
  Manager.sol
  ReceiptToken.sol
  ReceiptTokenFactory.sol
  SharesRegistry.sol
  StablesManager.sol
  Staker.sol
  StrategyManager.sol
  SwapManager.sol
```

# Files

## File: src/interfaces/core/IReceiptToken.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import { IERC20, IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// Receipt token interface
interface IReceiptToken is IERC20, IERC20Metadata, IERC20Errors {
    // -- Events --

    /**
     * @notice Emitted when the minter address is updated
     *  @param oldMinter The address of the old minter
     *  @param newMinter The address of the new minter
     */
    event MinterUpdated(address oldMinter, address newMinter);

    // --- Initialization ---

    /**
     * @notice This function initializes the contract (instead of a constructor) to be cloned.
     *
     * @notice Requirements:
     * - The contract must not be already initialized.
     * - The `__minter` must not be the zero address.
     *
     * @notice Effects:
     * - Sets `_initialized` to true.
     * - Updates `_name`, `_symbol`, `minter` state variables.
     * - Stores `__owner` as owner.
     *
     * @param __name Receipt token name.
     * @param __symbol Receipt token symbol.
     * @param __minter Receipt token minter.
     * @param __owner Receipt token owner.
     */
    function initialize(string memory __name, string memory __symbol, address __minter, address __owner) external;

    /**
     * @notice Mints receipt tokens.
     *
     * @notice Requirements:
     * - Must be called by the Minter or Owner of the Contract.
     *
     * @notice Effects:
     * - Mints the specified amount of tokens to the given address.
     *
     * @param _user Address of the user receiving minted tokens.
     * @param _amount The amount to be minted.
     */
    function mint(address _user, uint256 _amount) external;

    /**
     * @notice Burns tokens from an address.
     *
     * @notice Requirements:
     * - Must be called by the Minter or Owner of the Contract.
     *
     * @notice Effects:
     * - Burns the specified amount of tokens from the specified address.
     *
     * @param _user The user to burn it from.
     * @param _amount The amount of tokens to be burnt.
     */
    function burnFrom(address _user, uint256 _amount) external;

    /**
     * @notice Sets minter.
     *
     * @notice Requirements:
     * - Must be called by the Minter or Owner of the Contract.
     * - The `_minter` must be different from `minter`.
     *
     * @notice Effects:
     * - Updates minter state variable.
     *
     * @notice Emits:
     * - `MinterUpdated` event indicating minter update operation.
     *
     * @param _minter The user to burn it from.
     */
    function setMinter(
        address _minter
    ) external;
}
```

## File: src/interfaces/core/IReceiptTokenFactory.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IReceiptTokenFactory {
    /**
     * @notice Emitted when ReceiptToken reference implementation is updated.
     * @param newReceiptTokenImplementationAddress Address of the new Receipt Token implementation.
     */
    event ReceiptTokenImplementationUpdated(address indexed newReceiptTokenImplementationAddress);

    /**
     * @notice Emitted when a new receipt token is created.
     *
     * @param newReceiptTokenAddress Address of the newly created receipt token.
     * @param creator Address of the account that initiated the creation.
     * @param name Name of the new receipt token.
     * @param symbol Symbol of the new receipt token.
     */
    event ReceiptTokenCreated(
        address indexed newReceiptTokenAddress, address indexed creator, string name, string symbol
    );

    /**
     * @notice Sets the reference implementation address for the receipt token.
     * @param _referenceImplementation Address of the new reference implementation contract.
     */
    function setReceiptTokenReferenceImplementation(
        address _referenceImplementation
    ) external;

    /**
     * @notice Creates a new receipt token by cloning the reference implementation.
     *
     * @param _name Name of the new receipt token.
     * @param _symbol Symbol of the new receipt token.
     * @param _minter Address of the account that will have the minting rights.
     * @param _owner Address of the owner of the new receipt token.
     *
     * @return newReceiptTokenAddress Address of the newly created receipt token.
     */
    function createReceiptToken(
        string memory _name,
        string memory _symbol,
        address _minter,
        address _owner
    ) external returns (address);
}
```

## File: src/interfaces/core/IStaker.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IStaker
 * @notice Interface for Staker contract.
 */
interface IStaker {
    // -- Events --

    /**
     * @notice Event emitted when participant deposited.
     * @param user The address of the participant.
     * @param amount The amount deposited.
     */
    event Staked(address indexed user, uint256 amount);

    /**
     * @notice Event emitted when participant claimed the investment.
     * @param user The address of the participant.
     * @param amount The amount withdrawn.
     */
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @notice Event emitted when participant claimed rewards.
     * @param user The address of the participant.
     * @param reward The amount of rewards claimed.
     */
    event RewardPaid(address indexed user, uint256 reward);

    /**
     * @notice Event emitted when rewards duration was updated.
     * @param newDuration The new duration of the rewards period.
     */
    event RewardsDurationUpdated(uint256 newDuration);

    /**
     * @notice Event emitted when rewards were added.
     * @param reward The amount of added rewards.
     */
    event RewardAdded(uint256 reward);

    /**
     * @notice Address of the staking token.
     */
    function tokenIn() external view returns (address);

    /**
     * @notice Address of the reward token.
     */
    function rewardToken() external view returns (address);

    /**
     * @notice Timestamp indicating when the current reward distribution ends.
     */
    function periodFinish() external view returns (uint256);

    /**
     * @notice Rate of rewards per second.
     */
    function rewardRate() external view returns (uint256);

    /**
     * @notice Duration of current reward period.
     */
    function rewardsDuration() external view returns (uint256);

    /**
     * @notice Timestamp of the last update time.
     */
    function lastUpdateTime() external view returns (uint256);

    /**
     * @notice Stored rewards per token.
     */
    function rewardPerTokenStored() external view returns (uint256);

    /**
     * @notice Mapping of user addresses to the amount of rewards already paid to them.
     * @param participant The address of the participant.
     */
    function userRewardPerTokenPaid(
        address participant
    ) external view returns (uint256);

    /**
     * @notice Mapping of user addresses to their accrued rewards.
     * @param participant The address of the participant.
     */
    function rewards(
        address participant
    ) external view returns (uint256);

    /**
     * @notice Total supply limit of the staking token.
     */
    function totalSupplyLimit() external view returns (uint256);

    // -- User specific methods  --

    /**
     * @notice Performs a deposit operation for `msg.sender`.
     * @dev Updates participants' rewards.
     *
     * @param _amount to deposit.
     */
    function deposit(
        uint256 _amount
    ) external;

    /**
     * @notice Withdraws investment from staking.
     * @dev Updates participants' rewards.
     *
     * @param _amount to withdraw.
     */
    function withdraw(
        uint256 _amount
    ) external;
    /**
     * @notice Claims the rewards for the caller.
     * @dev This function allows the caller to claim their earned rewards.
     */
    function claimRewards() external;

    /**
     * @notice Withdraws the entire investment and claims rewards for `msg.sender`.
     */
    function exit() external;

    // -- Administration --

    /**
     * @notice Sets the duration of each reward period.
     * @param _rewardsDuration The new rewards duration.
     */
    function setRewardsDuration(
        uint256 _rewardsDuration
    ) external;

    /**
     * @notice Adds more rewards to the contract.
     *
     * @dev Prior approval is required for this contract to transfer rewards from `_from` address.
     *
     * @param _from address to transfer rewards from.
     * @param _amount The amount of new rewards.
     */
    function addRewards(address _from, uint256 _amount) external;

    /**
     * @notice Triggers stopped state.
     */
    function pause() external;

    /**
     * @notice Returns to normal state.
     */
    function unpause() external;

    // -- Getters --

    /**
     * @notice Returns the total supply of the staking token.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Returns the total invested amount for an account.
     * @param _account The participant's address.
     */
    function balanceOf(
        address _account
    ) external view returns (uint256);

    /**
     * @notice Returns the last time rewards were applicable.
     */
    function lastTimeRewardApplicable() external view returns (uint256);

    /**
     * @notice Returns rewards per token.
     */
    function rewardPerToken() external view returns (uint256);

    /**
     * @notice Returns accrued rewards for an account.
     * @param _account The participant's address.
     */
    function earned(
        address _account
    ) external view returns (uint256);

    /**
     * @notice Returns the reward amount for a specific time range.
     */
    function getRewardForDuration() external view returns (uint256);
}
```

## File: src/interfaces/core/IStrategy.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IReceiptToken } from "../core/IReceiptToken.sol";

/**
 * @title IStrategy
 * @notice Interface for a Strategies.
 *
 * @dev This interface defines the standard functions and events for a strategy contract.
 * @dev The strategy allows for the deposit, withdrawal, and reward claiming functionalities.
 * @dev It also provides views for essential information about the strategy's token and rewards.
 */
interface IStrategy {
    // -- Custom types --

    /**
     * @notice Struct containing parameters for a withdrawal operation.
     * @param shares The number of shares to withdraw.
     * @param totalShares The total shares owned by the user.
     * @param shareRatio The ratio of the shares to withdraw relative to the total shares owned by the user.
     * @param shareDecimals The number of decimals of the strategy's shares.
     * @param investment The amount of initial investment corresponding to the shares being withdrawn.
     * @param assetsToWithdraw The underlying assets withdrawn by the user, including yield and excluding fee.
     * @param balanceBefore The user's `tokenOut` balance before the withdrawal transaction.
     * @param withdrawnAmount The amount of underlying assets withdrawn by the user, excluding fee.
     * @param yield The yield generated by the strategy excluding fee, as fee are taken from the yield.
     * @param fee The amount of fee taken by the protocol.
     */
    struct WithdrawParams {
        uint256 shares;
        uint256 totalShares;
        uint256 shareRatio;
        uint256 shareDecimals;
        uint256 investment;
        uint256 assetsToWithdraw;
        uint256 balanceBefore;
        uint256 withdrawnAmount;
        int256 yield;
        uint256 fee;
    }

    /**
     * @notice Emitted when funds are deposited.
     *
     * @param asset The address of the asset.
     * @param tokenIn The address of the input token.
     * @param assetAmount The amount of the asset.
     * @param tokenInAmount The amount of the input token.
     * @param shares The number of shares received.
     * @param recipient The address of the recipient.
     */
    event Deposit(
        address indexed asset,
        address indexed tokenIn,
        uint256 assetAmount,
        uint256 tokenInAmount,
        uint256 shares,
        address indexed recipient
    );

    /**
     * @notice Emitted when funds are withdrawn.
     *
     * @param asset The address of the asset.
     * @param recipient The address of the recipient.
     * @param shares The number of shares withdrawn.
     * @param withdrawnAmount The amount of the asset withdrawn.
     * @param yield The amount of yield generated by the user beyond their initial investment.
     */
    event Withdraw(
        address indexed asset,
        address indexed recipient,
        uint256 shares,
        uint256 withdrawnAmount,
        uint256 initialInvestment,
        int256 yield
    );

    /**
     * @notice Emitted when rewards are claimed.
     *
     * @param recipient The address of the recipient.
     * @param rewards The array of reward amounts.
     * @param rewardTokens The array of reward token addresses.
     */
    event Rewards(address indexed recipient, uint256[] rewards, address[] rewardTokens);

    /**
     * @notice Returns investments details.
     * @param _recipient The address of the recipient.
     * @return investedAmount The amount invested.
     * @return totalShares The total shares.
     */
    function recipients(
        address _recipient
    ) external view returns (uint256 investedAmount, uint256 totalShares);

    /**
     * @notice Returns the address of the token accepted by the strategy's underlying protocol as input.
     * @return tokenIn The address of the tokenIn.
     */
    function tokenIn() external view returns (address);

    /**
     * @notice Returns the address of token issued by the strategy's underlying protocol after deposit.
     * @return tokenOut The address of the tokenOut.
     */
    function tokenOut() external view returns (address);

    /**
     * @notice Returns the address of the strategy's main reward token.
     * @return rewardToken The address of the reward token.
     */
    function rewardToken() external view returns (address);

    /**
     * @notice Returns the address of the receipt token minted by the strategy itself.
     * @return receiptToken The address of the receipt token.
     */
    function receiptToken() external view returns (IReceiptToken);

    /**
     * @notice Returns the number of decimals of the strategy's shares.
     * @return sharesDecimals The number of decimals.
     */
    function sharesDecimals() external view returns (uint256);

    /**
     * @notice Returns the address of the receipt token.
     * @return receiptTokenAddress The address of the receipt token.
     */
    function getReceiptTokenAddress() external view returns (address receiptTokenAddress);

    /**
     * @notice Deposits funds into the strategy.
     *
     * @dev Some strategies won't give back any receipt tokens; in this case 'tokenOutAmount' will be 0.
     * 'tokenInAmount' will be equal to '_amount' in case the '_asset' is the same as strategy 'tokenIn()'.
     *
     * @param _asset The token to be invested.
     * @param _amount The token's amount.
     * @param _recipient The address of the recipient.
     * @param _data Extra data.
     *
     * @return tokenOutAmount The receipt tokens amount/obtained shares.
     * @return tokenInAmount The returned token in amount.
     */
    function deposit(
        address _asset,
        uint256 _amount,
        address _recipient,
        bytes calldata _data
    ) external returns (uint256 tokenOutAmount, uint256 tokenInAmount);

    /**
     * @notice Withdraws deposited funds.
     *
     * @param _shares The amount to withdraw.
     * @param _recipient The address of the recipient.
     * @param _asset The token to be withdrawn.
     * @param _data Extra data.
     *
     * @return withdrawnAmount The actual amount of asset withdrawn from the strategy.
     * @return initialInvestment The amount of initial investment.
     * @return yield The amount of yield generated by the user beyond their initial investment.
     * @return fee The amount of fee charged by the strategy.
     */
    function withdraw(
        uint256 _shares,
        address _recipient,
        address _asset,
        bytes calldata _data
    ) external returns (uint256 withdrawnAmount, uint256 initialInvestment, int256 yield, uint256 fee);

    /**
     * @notice Claims rewards from the strategy.
     *
     * @param _recipient The address of the recipient.
     * @param _data Extra data.
     *
     * @return amounts The reward tokens amounts.
     * @return tokens The reward tokens addresses.
     */
    function claimRewards(
        address _recipient,
        bytes calldata _data
    ) external returns (uint256[] memory amounts, address[] memory tokens);

    /**
     * @notice Participants info.
     */
    struct RecipientInfo {
        uint256 investedAmount;
        uint256 totalShares;
    }
}
```

## File: src/interfaces/core/IStrategyManagerMin.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStrategyManagerMin {
    /**
     * @notice Returns the strategy info.
     */
    function strategyInfo(
        address _strategy
    ) external view returns (uint256, bool, bool);
}
```

## File: src/interfaces/oracle/IOracle.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOracle {
    // -- State variables --

    /**
     * @notice Returns the address of the token the oracle is for.
     */
    function underlying() external view returns (address);

    // -- Functions --

    /**
     * @notice Returns a human readable name of the underlying of the oracle.
     */
    function name() external view returns (string memory);

    /**
     * @notice Returns a human readable symbol of the underlying of the oracle.
     */
    function symbol() external view returns (string memory);

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
```

## File: src/interfaces/IWETH.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IWETH {
    function deposit() external payable;

    function withdraw(
        uint256
    ) external;
}
```

## File: src/oracles/chronicle/interfaces/IChronicleMinimal.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @title IChronicle
 *
 * @notice Minimal interface for Chronicle Protocol's oracle products
 */
interface IChronicleMinimal {
    /**
     * @notice Returns the oracle's current value and its age.
     * @dev Reverts if no value set.
     * @return value The oracle's current value.
     * @return age The value's age.
     */
    function readWithAge() external view returns (uint256 value, uint256 age);
}
```

## File: src/oracles/chronicle/interfaces/IChronicleOracleFactory.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IChronicleOracleFactory
 * @dev Interface for the ChronicleOracleFactory contract.
 */
interface IChronicleOracleFactory {
    // -- Events --

    /**
     * @notice Emitted when the reference implementation is updated.
     * @param newImplementation Address of the new reference implementation.
     */
    event ChronicleOracleImplementationUpdated(address indexed newImplementation);

    // -- State variables --

    /**
     * @notice Gets the address of the reference implementation.
     * @return Address of the reference implementation.
     */
    function referenceImplementation() external view returns (address);

    // -- Administration --

    /**
     * @notice Sets the reference implementation address.
     * @param _referenceImplementation Address of the new reference implementation contract.
     */
    function setReferenceImplementation(
        address _referenceImplementation
    ) external;

    // -- Chronicle oracle creation --

    /**
     * @notice Creates a new Chronicle oracle by cloning the reference implementation.
     *
     * @param _initialOwner The address of the initial owner of the contract.
     * @param _underlying The address of the token the oracle is for.
     * @param _chronicle The Address of the Chronicle Oracle.
     * @param _ageValidityPeriod The Age in seconds after which the price is considered invalid.
     *
     * @return newChronicleOracleAddress Address of the newly created Chronicle oracle.
     */
    function createChronicleOracle(
        address _initialOwner,
        address _underlying,
        address _chronicle,
        uint256 _ageValidityPeriod
    ) external returns (address newChronicleOracleAddress);
}
```

## File: src/oracles/genesis/GenesisOracle.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title GenesisOracle
 *
 * @notice A mock oracle contract for the jUSD token.
 *
 * @dev This contract provides a fixed exchange rate of 1:1 for jUSD and includes basic metadata functions.
 * @dev It serves as a temporary solution during the initial phase of the protocol and must be replaced by a real
 * on-chain oracle as soon as one becomes available.
 *
 * @author Hovooo (@hovooo)
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract GenesisOracle {
    /**
     * @notice Always returns a fixed exchange rate of 1e18 (1:1).
     * @return success Boolean indicating whether a valid rate is available.
     * @return rate The exchange rate of the underlying asset.
     */
    function peek(
        bytes calldata
    ) external pure returns (bool success, uint256 rate) {
        rate = 1e18; // Fixed rate of 1 jUSD = 1 USD
        success = true;
    }

    /**
     * @notice Retrieves the name of the underlying token.
     * @return The human-readable name of the jUSD token.
     */
    function name() external pure returns (string memory) {
        return "Jigsaw USD";
    }

    /**
     * @notice Retrieves the symbol of the underlying token.
     * @return The human-readable symbol of the jUSD token.
     */
    function symbol() external pure returns (string memory) {
        return "jUSD";
    }
}
```

## File: src/oracles/uniswap/interfaces/IUniswapV3Oracle.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IOracle } from "../../../interfaces/oracle/IOracle.sol";

interface IUniswapV3Oracle is IOracle {
    // -- Events --

    /**
     * @notice Emitted when the list of UniswapV3 pools is updated.
     * @param oldPoolsHash The hash of the old list of pools before the update.
     * @param newPoolsHash The hash of the new list of pools after the update.
     */
    event PoolsUpdated(bytes32 oldPoolsHash, bytes32 newPoolsHash);

    /**
     * @notice Emitted when the quote token oracle is updated.
     * @param oldOracle The address of the old oracle before the update.
     * @param newOracle The address of the new oracle after the update.
     */
    event QuoteTokenOracleUpdated(address oldOracle, address newOracle);

    // -- Errors --

    /**
     * @notice Thrown when an invalid address is provided.
     * @dev This error is thrown when any of the provided contract addresses (such as jUSD, quoteToken, or UniswapV3
     * pool) are the zero address (address(0)), which is not a valid address for contract interactions.
     */
    error InvalidAddress();

    /**
     * @notice Thrown when the provided list of UniswapV3 pools has zero length.
     */
    error InvalidPoolsLength();

    /**
     * @notice Thrown when the provided list of UniswapV3 pools is identical to the existing list.
     */
    error InvalidPools();

    /**
     * @notice Error thrown when there are no defined UniswapV3 pools for price calculation.
     */
    error NoDefinedPools();

    /**
     * @notice Error thrown when attempting to query an offsetted spot quote with invalid parameters.
     * @dev This error is triggered when an attempt is made to query a spot price with an offset but no valid period is
     * specified.
     */
    error OffsettedSpotQuote();

    // -- State variables --

    /**
     * @notice Amount of tokens used to determine jUSD's price.
     * @return The base amount used for price calculations.
     */
    function baseAmount() external view returns (uint128);

    /**
     * @notice Address of the ERC20 token used as the quote currency.
     * @return The address of the quote token.
     */
    function quoteToken() external view returns (address);

    /**
     * @notice Decimals of the ERC20 token used as the quote currency.
     * @return The decimals of the quote token.
     */
    function quoteTokenDecimals() external view returns (uint256);

    /**
     * @notice Oracle used to convert price denominated in quote token to USD value
     * @return The oracle contract used for quote token to USD conversion
     */
    function quoteTokenOracle() external view returns (IOracle);

    // -- Getters --

    /**
     * @notice Returns the list of UniswapV3 pool addresses used for price calculations.
     * @return An array of UniswapV3 pool addresses stored in the contract.
     */
    function getPools() external view returns (address[] memory);

    // -- Administration --

    /**
     * @notice Updates the UniswapV3 pools used for price calculations.
     * @dev Only callable by the contract owner.
     * @param _newPools The new list of UniswapV3 pool addresses.
     */
    function updatePools(
        address[] memory _newPools
    ) external;
}
```

## File: src/oracles/uniswap/UniswapV3Oracle.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { OracleLibrary } from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

import { IOracle, IUniswapV3Oracle } from "./interfaces/IUniswapV3Oracle.sol";

/**
 * @title UniswapV3Oracle
 *
 * @notice Fetches and processes Uniswap V3 TWAP (Time-Weighted Average Price) data for a given token.
 * @notice This contract is designed to provide jUSD price data quoted in USDC from Uniswap V3 pools.
 *
 * @dev Implements IUniswapV3Oracle interface and uses UniswapV3 pools as price feed source.
 * @dev This contract inherits functionalities from `Ownable2Step`.
 *
 * @author Hovooo (@hovooo)
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract UniswapV3Oracle is IUniswapV3Oracle, Ownable2Step {
    // -- State variables --

    /**
     * @notice Returns the address of the token the oracle is for.
     * @dev Is used as a `baseToken` for UniswapV3 TWAP.
     */
    address public override underlying;

    /**
     * @notice Amount of tokens used to determine jUSD's price.
     * @dev Should be equal to 1 * 10^(jUSD decimals) to always get the price for one jUSD token.
     */
    uint128 public override baseAmount;

    /**
     * @notice Address of the ERC20 token used as the quote currency.
     */
    address public override quoteToken;

    /**
     * @notice Decimals of the ERC20 token used as the quote currency.
     */
    uint256 public override quoteTokenDecimals;

    /**
     * @notice The standard decimal precision (18) used for price normalization across the protocol.
     */
    uint256 private constant ALLOWED_DECIMALS = 18;

    /**
     * @notice Oracle used to convert price denominated in quote token to USD value
     */
    IOracle public override quoteTokenOracle;

    /**
     * @notice List of UniswapV3 pool addresses used for price calculations.
     */
    address[] private pools;

    // -- Constructor --

    /**
     * @notice Initializes key parameters.
     * @param _initialOwner Address of the contract owner.
     * @param _jUSD Address of the jUSD token contract.
     * @param _quoteToken Address of the quote token (USDC) contract.
     * @param _uniswapV3Pools Array of UniswapV3 pool addresses used for pricing.
     */
    constructor(
        address _initialOwner,
        address _jUSD,
        address _quoteToken,
        address _quoteTokenOracle,
        address[] memory _uniswapV3Pools
    ) Ownable(_initialOwner) {
        if (_jUSD == address(0)) revert InvalidAddress();
        if (_quoteToken == address(0)) revert InvalidAddress();

        // Initialize oracle configuration parameters
        baseAmount = uint128(10 ** IERC20Metadata(_jUSD).decimals());
        underlying = _jUSD;
        quoteToken = _quoteToken;
        quoteTokenDecimals = IERC20Metadata(_quoteToken).decimals();

        _updateQuoteTokenOracle(_quoteTokenOracle);
        _updatePools(_uniswapV3Pools);
    }

    // -- Getters --

    /**
     * @notice Check the last exchange rate without any state changes.
     * @return success If no valid (recent) rate is available, returns false else true.
     * @return rate The rate of the requested asset.
     */
    function peek(
        bytes calldata
    ) external view returns (bool success, uint256 rate) {
        // Query three different TWAPs (Time-Weighted Average Prices) from different time periods and take the median of
        // these prices to reduce the impact of sudden price fluctuations or manipulation.
        uint256 median = _getMedian(
            _quote({ _period: 1800, _offset: 3600 }), // Query the TWAP from the last 90-60 minutes (oldest time period)
            _quote({ _period: 1800, _offset: 1800 }), // Query the TWAP from the last 60-30 minutes (middle time period)
            _quote({ _period: 1800, _offset: 0 }) // Query the TWAP from the last 30-0 minutes (most recent time period)
        );

        // Normalize the price to ALLOWED_DECIMALS (e.g., 18 decimals)
        uint256 medianWithDecimals = quoteTokenDecimals == ALLOWED_DECIMALS
            ? median
            : quoteTokenDecimals < ALLOWED_DECIMALS
                ? median * 10 ** (ALLOWED_DECIMALS - quoteTokenDecimals)
                : median / 10 ** (quoteTokenDecimals - ALLOWED_DECIMALS);

        // As the median price is denominated in quote token, convert that price to USD value
        rate = _convertToUsd({ _price: medianWithDecimals });
        // If a valid price has been retrieved from the queries, return success as true
        success = true;
    }

    /**
     * @notice Returns a human readable name of the underlying of the oracle.
     */
    function name() external view override returns (string memory) {
        return IERC20Metadata(underlying).name();
    }

    /**
     * @notice Returns a human readable symbol of the underlying of the oracle.
     */
    function symbol() external view override returns (string memory) {
        return IERC20Metadata(underlying).symbol();
    }

    /**
     * @notice Returns the list of UniswapV3 pool addresses used for price calculations.
     * @return An array of UniswapV3 pool addresses stored in the contract.
     */
    function getPools() external view override returns (address[] memory) {
        return pools;
    }

    // -- Administration --

    /**
     * @notice Updates the UniswapV3 pools used for price calculations.
     * @dev Only callable by the contract owner.
     * @param _newPools The new list of UniswapV3 pool addresses.
     */
    function updatePools(
        address[] memory _newPools
    ) external onlyOwner {
        _updatePools(_newPools);
    }

    function updateQuoteTokenOracle(
        address _newOracle
    ) external onlyOwner {
        _updateQuoteTokenOracle(_newOracle);
    }

    /**
     * @dev Renounce ownership override to avoid losing contract's ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }

    // -- Utility functions --

    /**
     * @notice Fetches a time-weighted average price (TWAP) from Uniswap V3.
     * @param _period The length of the TWAP period in seconds.
     * @param _offset The offset (delay) for the TWAP calculation.
     */
    function _quote(uint32 _period, uint32 _offset) internal view returns (uint256) {
        uint256 length = pools.length;

        if (length == 0) revert NoDefinedPools();
        if (_offset > 0 && _period == 0) revert OffsettedSpotQuote();

        OracleLibrary.WeightedTickData[] memory _tickData = new OracleLibrary.WeightedTickData[](length);

        for (uint256 i; i < length; i++) {
            (_tickData[i].tick, _tickData[i].weight) = _period > 0
                ? consultOffsetted(pools[i], _period, _offset)
                : OracleLibrary.getBlockStartingTickAndLiquidity(pools[i]);
        }

        int24 _weightedTick =
            _tickData.length == 1 ? _tickData[0].tick : OracleLibrary.getWeightedArithmeticMeanTick(_tickData);

        return OracleLibrary.getQuoteAtTick(_weightedTick, baseAmount, underlying, quoteToken);
    }

    /**
     * @notice Calculates time-weighted means of tick and liquidity for a given Uniswap V3 pool.
     *
     * @param _pool Address of the pool that to observe.
     * @param _twapLength Length in seconds of the TWAP calculation length.
     * @param _offset Number of seconds ago to start the TWAP calculation.
     *
     * @return _arithmeticMeanTick The arithmetic mean tick from _secondsAgos[0] to _secondsAgos[1].
     * @return _harmonicMeanLiquidity The harmonic mean liquidity from _secondsAgos[0] to _secondsAgos[1].
     */
    function consultOffsetted(
        address _pool,
        uint32 _twapLength,
        uint32 _offset
    ) internal view returns (int24 _arithmeticMeanTick, uint128 _harmonicMeanLiquidity) {
        uint32[] memory _secondsAgos = new uint32[](2);
        _secondsAgos[0] = _twapLength + _offset;
        _secondsAgos[1] = _offset;

        (int56[] memory _tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) =
            IUniswapV3Pool(_pool).observe(_secondsAgos);

        int56 _tickCumulativesDelta = _tickCumulatives[1] - _tickCumulatives[0];
        uint160 _secondsPerLiquidityCumulativesDelta =
            secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0];

        _arithmeticMeanTick = int24(_tickCumulativesDelta / int56(int32(_twapLength)));

        // Always round to negative infinity
        if (_tickCumulativesDelta < 0 && (_tickCumulativesDelta % int56(int32((_twapLength))) != 0)) {
            _arithmeticMeanTick--;
        }

        // We are multiplying here instead of shifting to ensure that _harmonicMeanLiquidity doesn't overflow uint128
        uint192 _secondsAgoX160 = uint192(_twapLength) * type(uint160).max;
        _harmonicMeanLiquidity = uint128(_secondsAgoX160 / (uint192(_secondsPerLiquidityCumulativesDelta) << 32));
    }

    /**
     * @notice Computes a median value from three numbers.
     */
    function _getMedian(uint256 _a, uint256 _b, uint256 _c) internal pure returns (uint256) {
        if ((_a >= _b && _a <= _c) || (_a >= _c && _a <= _b)) return _a;
        if ((_b >= _a && _b <= _c) || (_b >= _c && _b <= _a)) return _b;
        return _c;
    }

    /**
     * @notice Converts a price denominated in quote token to its USD value.
     * @dev Uses the quote token's oracle to get the USD exchange rate.
     *
     * @notice Requirements:
     * - Oracle must provide an updated rate.
     * - Rate must be greater than zero.
     *
     * @param _price The price denominated in quote token to convert to USD.
     * @return The USD value of the given price.
     */
    function _convertToUsd(
        uint256 _price
    ) internal view returns (uint256) {
        // Query the quote token's oracle for its current USD exchange rate
        (bool updated, uint256 rate) = quoteTokenOracle.peek("");

        // Ensure the oracle provided an updated rate
        require(updated, "3037"); // ERR: FAILED

        // Ensure the rate is valid (greater than zero)
        require(rate > 0, "2100"); // ERR: INVALID MIN_AMOUNT

        // Convert the price denominated in quote token to USD value using quote token's USD oracle
        // Note: It's safe to use ALLOWED_DECIMALS as it's guaranteed that oracles implementing IOracle interface always
        // return prices with 18 decimals
        return _price * rate / 10 ** ALLOWED_DECIMALS;
    }

    /**
     * @notice Updates the oracle used for the quote token's USD price.
     * @dev This function is used to change the oracle that provides the USD exchange rate for the quote token.
     *
     * @notice Requirements:
     * - `_newOracle` must not be the zero address.
     * - `_newOracle` must be different from the current oracle address.
     *
     * @notice Effects:
     * - Updates the `quoteTokenOracle` state variable to the new oracle.
     *
     * @notice Emits:
     * - `QuoteTokenOracleUpdated` event indicating the change from old to new oracle.
     *
     * @param _newOracle The address of the new oracle to be used for the quote token.
     */
    function _updateQuoteTokenOracle(
        address _newOracle
    ) private {
        address oldOracle = address(quoteTokenOracle);

        if (_newOracle == address(0)) revert InvalidAddress();
        if (_newOracle == oldOracle) revert InvalidAddress();

        emit QuoteTokenOracleUpdated(oldOracle, _newOracle);
        quoteTokenOracle = IOracle(_newOracle);
    }

    /**
     * @notice Updates the UniswapV3 pools used for price calculations.
     * @param _newPools The new list of UniswapV3 pool addresses.
     */
    function _updatePools(
        address[] memory _newPools
    ) private {
        uint256 length = _newPools.length;

        // Ensure that the provided pool list is not empty
        if (length == 0) revert InvalidPoolsLength();

        // Compute hashes of the old and new pools to compare if they are identical
        bytes32 oldPoolsHash = keccak256(abi.encode(pools));
        bytes32 newPoolsHash = keccak256(abi.encode(_newPools));

        // Revert if the new pool list is the same as the existing one
        if (oldPoolsHash == newPoolsHash) revert InvalidPools();

        // Iterate through the new pool list to check for invalid addresses
        for (uint256 i = 0; i < length; i++) {
            if (_newPools[i] == address(0)) revert InvalidPools(); // Ensure no zero-address pools
        }

        // Emit an event to log the update of pools
        emit PoolsUpdated(oldPoolsHash, newPoolsHash);

        // Update the pools storage variable with the new pool list
        pools = _newPools;
    }
}
```

## File: src/ReceiptTokenFactory.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";

import { IReceiptToken } from "./interfaces/core/IReceiptToken.sol";
import { IReceiptTokenFactory } from "./interfaces/core/IReceiptTokenFactory.sol";

/**
 * @title ReceiptTokenFactory
 * @dev This contract is used to create new instances of receipt tokens for strategies using the clone factory pattern.
 */
contract ReceiptTokenFactory is IReceiptTokenFactory, Ownable2Step {
    /**
     * @notice Address of the reference implementation of the receipt token contract.
     */
    address public referenceImplementation;

    // -- Constructor --

    /**
     * @notice Creates a new ReceiptTokenFactory contract.
     * @param _initialOwner The initial owner of the contract.
     * @notice Sets the reference implementation address for the receipt token.
     */
    constructor(address _initialOwner, address _referenceImplementation) Ownable(_initialOwner) {
        // Assert that referenceImplementation has code in it to protect the system from cloning invalid implementation.
        require(_referenceImplementation.code.length > 0, "3096");

        emit ReceiptTokenImplementationUpdated(_referenceImplementation);
        referenceImplementation = _referenceImplementation;
    }

    // -- Administration --

    /**
     * @notice Sets the reference implementation address for the receipt token.
     * @param _referenceImplementation Address of the new reference implementation contract.
     */
    function setReceiptTokenReferenceImplementation(
        address _referenceImplementation
    ) external override onlyOwner {
        // Assert that referenceImplementation has code in it to protect the system from cloning invalid implementation.
        require(_referenceImplementation.code.length > 0, "3096");
        require(_referenceImplementation != referenceImplementation, "3062");

        emit ReceiptTokenImplementationUpdated(_referenceImplementation);
        referenceImplementation = _referenceImplementation;
    }

    // -- Receipt token creation --

    /**
     * @notice Creates a new receipt token by cloning the reference implementation.
     *
     * @param _name Name of the new receipt token.
     * @param _symbol Symbol of the new receipt token.
     * @param _minter Address of the account that will have the minting rights.
     * @param _owner Address of the owner of the new receipt token.
     *
     * @return newReceiptTokenAddress Address of the newly created receipt token.
     */
    function createReceiptToken(
        string memory _name,
        string memory _symbol,
        address _minter,
        address _owner
    ) external override returns (address newReceiptTokenAddress) {
        // Clone the Receipt Token implementation for the new receipt token.
        newReceiptTokenAddress = Clones.cloneDeterministic({
            implementation: referenceImplementation,
            salt: bytes32(uint256(uint160(msg.sender)))
        });

        // Emit the event indicating the successful Receipt Token creation.
        emit ReceiptTokenCreated({
            newReceiptTokenAddress: newReceiptTokenAddress,
            creator: msg.sender,
            name: _name,
            symbol: _symbol
        });

        // Initialize the new receipt token's contract.
        IReceiptToken(newReceiptTokenAddress).initialize({
            __name: _name,
            __symbol: _symbol,
            __minter: _minter,
            __owner: _owner
        });
    }

    /**
     * @dev Renounce ownership override to avoid losing contract's ownership.
     */
    function renounceOwnership() public pure virtual override {
        revert("1000");
    }
}
```

## File: src/Staker.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { IStaker } from "./interfaces/core/IStaker.sol";

/**
 * @title Staker
 * @notice Staker is a synthetix based contract responsible for distributing rewards.
 *
 * @dev This contract inherits functionalities from `Ownable2Step` and `ReentrancyGuard`, `Pausable`.
 *
 * @author Hovooo (@hovooo)
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract Staker is IStaker, Ownable2Step, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    /**
     * @notice Address of the staking token.
     */
    address public immutable override tokenIn;

    /**
     * @notice Address of the reward token.
     */
    address public immutable override rewardToken;

    /**
     * @notice Timestamp indicating when the current reward distribution ends.
     */
    uint256 public override periodFinish = 0;

    /**
     * @notice Rate of rewards per second.
     */
    uint256 public override rewardRate = 0;

    /**
     * @notice Duration of current reward period.
     */
    uint256 public override rewardsDuration;

    /**
     * @notice Timestamp of the last update time.
     */
    uint256 public override lastUpdateTime;

    /**
     * @notice Stored rewards per token.
     */
    uint256 public override rewardPerTokenStored;

    /**
     * @notice Mapping of user addresses to the amount of rewards already paid to them.
     */
    mapping(address => uint256) public override userRewardPerTokenPaid;

    /**
     * @notice Mapping of user addresses to their accrued rewards.
     */
    mapping(address => uint256) public override rewards;

    /**
     * @notice Total supply limit of the staking token.
     */
    uint256 public constant override totalSupplyLimit = 1e34;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    // --- Constructor ---

    /**
     * @notice Constructor function for initializing the Staker contract.
     *
     * @param _initialOwner The initial owner of the contract.
     * @param _tokenIn The address of the token to be staked
     * @param _rewardToken The address of the reward token
     * @param _rewardsDuration The duration of the rewards period, in seconds
     */
    constructor(
        address _initialOwner,
        address _tokenIn,
        address _rewardToken,
        uint256 _rewardsDuration
    ) Ownable(_initialOwner) validAddress(_tokenIn) validAddress(_rewardToken) validAmount(_rewardsDuration) {
        tokenIn = _tokenIn;
        rewardToken = _rewardToken;
        rewardsDuration = _rewardsDuration;
        periodFinish = block.timestamp + rewardsDuration;
    }

    // -- User specific methods  --

    /**
     * @notice Performs a deposit operation for `msg.sender`.
     * @dev Updates participants' rewards.
     *
     * @param _amount to deposit.
     */
    function deposit(
        uint256 _amount
    ) external override nonReentrant whenNotPaused updateReward(msg.sender) validAmount(_amount) {
        uint256 rewardBalance = IERC20(rewardToken).balanceOf(address(this));
        require(rewardBalance != 0, "3090");

        // Ensure that deposit operation will never surpass supply limit
        require(_totalSupply + _amount <= totalSupplyLimit, "3091");
        _totalSupply += _amount;

        _balances[msg.sender] += _amount;
        IERC20(tokenIn).safeTransferFrom({ from: msg.sender, to: address(this), value: _amount });
        emit Staked({ user: msg.sender, amount: _amount });
    }

    /**
     * @notice Withdraws investment from staking.
     * @dev Updates participants' rewards.
     *
     * @param _amount to withdraw.
     */
    function withdraw(
        uint256 _amount
    ) public override nonReentrant whenNotPaused updateReward(msg.sender) validAmount(_amount) {
        _totalSupply -= _amount;
        _balances[msg.sender] = _balances[msg.sender] - _amount;
        emit Withdrawn({ user: msg.sender, amount: _amount });
        IERC20(tokenIn).safeTransfer({ to: msg.sender, value: _amount });
    }

    /**
     * @notice Claims the rewards for the caller.
     * @dev This function allows the caller to claim their earned rewards.
     */
    function claimRewards() public override whenNotPaused nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        require(reward != 0, "3092");

        rewards[msg.sender] = 0;
        emit RewardPaid({ user: msg.sender, reward: reward });
        IERC20(rewardToken).safeTransfer({ to: msg.sender, value: reward });
    }

    /**
     * @notice Withdraws the entire investment and claims rewards for `msg.sender`.
     */
    function exit() external override {
        withdraw(_balances[msg.sender]);

        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            claimRewards();
        }
    }

    // -- Administration --

    /**
     * @notice Sets the duration of each reward period.
     * @param _rewardsDuration The new rewards duration.
     */
    function setRewardsDuration(
        uint256 _rewardsDuration
    ) external onlyOwner {
        require(block.timestamp > periodFinish, "3087");
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    /**
     * @notice Adds more rewards to the contract.
     *
     * @dev Prior approval is required for this contract to transfer rewards from `_from` address.
     *
     * @param _from address to transfer rewards from.
     * @param _amount The amount of new rewards.
     */
    function addRewards(
        address _from,
        uint256 _amount
    ) external override onlyOwner validAmount(_amount) updateReward(address(0)) {
        // Transfer assets from the `_from`'s address to this contract.
        IERC20(rewardToken).safeTransferFrom({ from: _from, to: address(this), value: _amount });

        require(rewardsDuration > 0, "3089");
        if (block.timestamp >= periodFinish) {
            rewardRate = _amount / rewardsDuration;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (_amount + leftover) / rewardsDuration;
        }

        // Prevent setting rewardRate to 0 because of precision loss.
        require(rewardRate != 0, "3088");

        // Prevent overflows.
        uint256 balance = IERC20(rewardToken).balanceOf(address(this));
        require(rewardRate <= (balance / rewardsDuration), "2003");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAdded(_amount);
    }

    /**
     * @notice Triggers stopped state.
     */
    function pause() external override onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     */
    function unpause() external override onlyOwner whenPaused {
        _unpause();
    }

    /**
     * @notice Renounce ownership override to prevent accidental loss of contract ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }

    // -- Getters --

    /**
     * @notice Returns the total supply of the staking token.
     */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @notice Returns the total invested amount for an account.
     * @param _account The participant's address.
     */
    function balanceOf(
        address _account
    ) external view override returns (uint256) {
        return _balances[_account];
    }

    /**
     * @notice Returns the last time rewards were applicable.
     */
    function lastTimeRewardApplicable() public view override returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    /**
     * @notice Returns rewards per token.
     */
    function rewardPerToken() public view override returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored + (((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18) / _totalSupply);
    }

    /**
     * @notice Returns accrued rewards for an account.
     * @param _account The participant's address.
     */
    function earned(
        address _account
    ) public view override returns (uint256) {
        return
            ((_balances[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) + rewards[_account];
    }

    /**
     * @notice Returns the reward amount for a specific time range.
     */
    function getRewardForDuration() external view override returns (uint256) {
        return rewardRate * rewardsDuration;
    }

    // -- Modifiers --

    /**
     * @notice Modifier to update the reward for a specified account.
     * @param account The account for which the reward needs to be updated.
     */
    modifier updateReward(
        address account
    ) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /**
     * @notice Modifier to check if the provided address is valid.
     * @param _address to be checked for validity.
     */
    modifier validAddress(
        address _address
    ) {
        require(_address != address(0), "3000");
        _;
    }

    /**
     * @notice Modifier to check if the provided amount is valid.
     * @param _amount to be checked for validity.
     */
    modifier validAmount(
        uint256 _amount
    ) {
        require(_amount > 0, "2001");
        _;
    }
}
```

## File: src/interfaces/core/IHolding.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IManager } from "./IManager.sol";

/**
 * @title IHolding
 * @dev Interface for the Holding Contract.
 */
interface IHolding {
    // -- Events --

    /**
     * @notice Emitted when the emergency invoker is set.
     */
    event EmergencyInvokerSet(address indexed oldInvoker, address indexed newInvoker);

    // -- State variables --

    /**
     * @notice Returns the emergency invoker address.
     * @return The address of the emergency invoker.
     */
    function emergencyInvoker() external view returns (address);

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     */
    function manager() external view returns (IManager);

    // -- User specific methods --

    /**
     * @notice Sets the emergency invoker address for this holding.
     *
     * @notice Requirements:
     * - The caller must be the owner of this holding.
     *
     * @notice Effects:
     * - Updates the emergency invoker address to the provided value.
     * - Emits an event to track the change for off-chain monitoring.
     *
     * @param _emergencyInvoker The address to set as the emergency invoker.
     */
    function setEmergencyInvoker(
        address _emergencyInvoker
    ) external;

    /**
     * @notice Approves an `_amount` of a specified token to be spent on behalf of the `msg.sender` by `_destination`.
     *
     * @notice Requirements:
     * - The caller must be allowed to make this call.
     *
     * @notice Effects:
     * - Safe approves the `_amount` of `_tokenAddress` to `_destination`.
     *
     * @param _tokenAddress Token user to be spent.
     * @param _destination Destination address of the approval.
     * @param _amount Withdrawal amount.
     */
    function approve(address _tokenAddress, address _destination, uint256 _amount) external;

    /**
     * @notice Transfers `_token` from the holding contract to `_to` address.
     *
     * @notice Requirements:
     * - The caller must be allowed.
     *
     * @notice Effects:
     * - Safe transfers `_amount` of `_token` to `_to`.
     *
     * @param _token Token address.
     * @param _to Address to move token to.
     * @param _amount Transfer amount.
     */
    function transfer(address _token, address _to, uint256 _amount) external;

    /**
     * @notice Executes generic call on the `contract`.
     *
     * @notice Requirements:
     * - The caller must be allowed.
     *
     * @notice Effects:
     * - Makes a low-level call to the `_contract` with the provided `_call` data.
     *
     * @param _contract The contract address for which the call will be invoked.
     * @param _call Abi.encodeWithSignature data for the call.
     *
     * @return success Indicates if the call was successful.
     * @return result The result returned by the call.
     */
    function genericCall(
        address _contract,
        bytes calldata _call
    ) external payable returns (bool success, bytes memory result);

    /**
     * @notice Executes an emergency generic call on the specified contract.
     *
     * @notice Requirements:
     * - The caller must be the designated emergency invoker.
     * - The emergency invoker must be an allowed invoker in the Manager contract.
     * - Protected by nonReentrant modifier to prevent reentrancy attacks.
     *
     * @notice Effects:
     * - Makes a low-level call to the `_contract` with the provided `_call` data.
     * - Forwards any ETH value sent with the transaction.
     *
     * @param _contract The contract address for which the call will be invoked.
     * @param _call Abi.encodeWithSignature data for the call.
     *
     * @return success Indicates if the call was successful.
     * @return result The result returned by the call.
     */
    function emergencyGenericCall(
        address _contract,
        bytes calldata _call
    ) external payable returns (bool success, bytes memory result);
}
```

## File: src/interfaces/core/IJigsawUSD.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IManager } from "./IManager.sol";

/**
 * @title IJigsawUSD
 * @dev Interface for the Jigsaw Stablecoin Contract.
 */
interface IJigsawUSD is IERC20 {
    /**
     * @notice event emitted when the mint limit is updated
     */
    event MintLimitUpdated(uint256 oldLimit, uint256 newLimit);

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     * @return The manager contract.
     */
    function manager() external view returns (IManager);

    /**
     * @notice Returns the max mint limit.
     */
    function mintLimit() external view returns (uint256);

    /**
     * @notice Sets the maximum mintable amount.
     *
     * @notice Requirements:
     * - Must be called by the contract owner.
     *
     * @notice Effects:
     * - Updates the `mintLimit` state variable.
     *
     * @notice Emits:
     * - `MintLimitUpdated` event indicating mint limit update operation.
     * @param _limit The new mint limit.
     */
    function updateMintLimit(
        uint256 _limit
    ) external;

    /**
     * @notice Mints tokens.
     *
     * @notice Requirements:
     * - Must be called by the Stables Manager Contract
     *  .
     * @notice Effects:
     * - Mints the specified amount of tokens to the given address.
     *
     * @param _to Address of the user receiving minted tokens.
     * @param _amount The amount to be minted.
     */
    function mint(address _to, uint256 _amount) external;

    /**
     * @notice Burns tokens from the `msg.sender`.
     *
     * @notice Requirements:
     * - Must be called by the token holder.
     *
     * @notice Effects:
     * - Burns the specified amount of tokens from the caller's balance.
     *
     * @param _amount The amount of tokens to be burnt.
     */
    function burn(
        uint256 _amount
    ) external;

    /**
     * @notice Burns tokens from an address.
     *
     * - Must be called by the Stables Manager Contract
     *
     * @notice Effects: Burns the specified amount of tokens from the specified address.
     *
     * @param _user The user to burn it from.
     * @param _amount The amount of tokens to be burnt.
     */
    function burnFrom(address _user, uint256 _amount) external;
}
```

## File: src/interfaces/core/ISharesRegistry.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IOracle } from "../oracle/IOracle.sol";
import { IManager } from "./IManager.sol";

/**
 * @title ISharesRegistry
 * @dev Interface for the Shares Registry Contract.
 * @dev Based on MIM CauldraonV2 contract.
 */
interface ISharesRegistry {
    /**
     * @notice Configuration struct for registry parameters.
     * @dev Used to store key parameters that control collateral and liquidation behavior.
     *
     * @param collateralizationRate The minimum collateral ratio required, expressed as a percentage with precision.
     * @param liquidationBuffer Is a value, that represents the buffer between the collateralization rate and the
     * liquidation threshold, upon which the liquidation is allowed.
     * @param liquidatorBonus The bonus percentage given to liquidators as incentive, expressed with precision.
     */
    struct RegistryConfig {
        uint256 collateralizationRate;
        uint256 liquidationBuffer;
        uint256 liquidatorBonus;
    }

    /**
     * @notice Event emitted when borrowed amount is set.
     * @param _holding The address of the holding.
     * @param oldVal The old value.
     * @param newVal The new value.
     */
    event BorrowedSet(address indexed _holding, uint256 oldVal, uint256 newVal);

    /**
     * @notice Event emitted when collateral is registered.
     * @param user The address of the user.
     * @param share The amount of shares.
     */
    event CollateralAdded(address indexed user, uint256 share);

    /**
     * @notice Event emitted when collateral was unregistered.
     * @param user The address of the user.
     * @param share The amount of shares.
     */
    event CollateralRemoved(address indexed user, uint256 share);

    /**
     * @notice Event emitted when the collateralization rate is updated.
     * @param oldVal The old value.
     * @param newVal The new value.
     */
    event CollateralizationRateUpdated(uint256 oldVal, uint256 newVal);

    /**
     * @notice Event emitted when a new oracle is requested.
     * @param newOracle The new oracle address.
     */
    event NewOracleRequested(address newOracle);

    /**
     * @notice Event emitted when the oracle is updated.
     */
    event OracleUpdated();

    /**
     * @notice Event emitted when new oracle data is requested.
     * @param newData The new data.
     */
    event NewOracleDataRequested(bytes newData);

    /**
     * @notice Event emitted when oracle data is updated.
     */
    event OracleDataUpdated();

    /**
     * @notice Event emitted when a new timelock amount is requested.
     * @param oldVal The old value.
     * @param newVal The new value.
     */
    event TimelockAmountUpdateRequested(uint256 oldVal, uint256 newVal);

    /**
     * @notice Event emitted when timelock amount is updated.
     * @param oldVal The old value.
     * @param newVal The new value.
     */
    event TimelockAmountUpdated(uint256 oldVal, uint256 newVal);

    /**
     * @notice Event emitted when the config is updated.
     * @param token The token address.
     * @param oldVal The old config.
     * @param newVal The new config.
     */
    event ConfigUpdated(address indexed token, RegistryConfig oldVal, RegistryConfig newVal);

    /**
     * @notice Returns holding's borrowed amount.
     * @param _holding The address of the holding.
     * @return The borrowed amount.
     */
    function borrowed(
        address _holding
    ) external view returns (uint256);

    /**
     * @notice Returns holding's available collateral amount.
     * @param _holding The address of the holding.
     * @return The collateral amount.
     */
    function collateral(
        address _holding
    ) external view returns (uint256);

    /**
     * @notice Returns the token address for which this registry was created.
     * @return The token address.
     */
    function token() external view returns (address);

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     * @return The manager contract.
     */
    function manager() external view returns (IManager);

    /**
     * @notice Oracle contract associated with this share registry.
     * @return The oracle contract.
     */
    function oracle() external view returns (IOracle);

    /**
     * @notice Extra oracle data if needed.
     * @return The oracle data.
     */
    function oracleData() external view returns (bytes calldata);

    /**
     * @notice Current timelock amount.
     * @return The timelock amount.
     */
    function timelockAmount() external view returns (uint256);

    // -- User specific methods --

    /**
     * @notice Updates `_holding`'s borrowed amount.
     *
     * @notice Requirements:
     * - `msg.sender` must be the Stables Manager Contract.
     * - `_newVal` must be greater than or equal to the minimum debt amount.
     *
     * @notice Effects:
     * - Updates `borrowed` mapping.
     *
     * @notice Emits:
     * - `BorrowedSet` indicating holding's borrowed amount update operation.
     *
     * @param _holding The address of the user's holding.
     * @param _newVal The new borrowed amount.
     */
    function setBorrowed(address _holding, uint256 _newVal) external;

    /**
     * @notice Registers collateral for user's `_holding`.
     *
     * @notice Requirements:
     * - `msg.sender` must be the Stables Manager Contract.
     *
     * @notice Effects:
     * - Updates `collateral` mapping.
     *
     * @notice Emits:
     * - `CollateralAdded` event indicating collateral addition operation.
     *
     * @param _holding The address of the user's holding.
     * @param _share The new collateral shares.
     */
    function registerCollateral(address _holding, uint256 _share) external;

    /**
     * @notice Registers a collateral removal operation for user's `_holding`.
     *
     * @notice Requirements:
     * - `msg.sender` must be the Stables Manager Contract.
     *
     * @notice Effects:
     * - Updates `collateral` mapping.
     *
     * @notice Emits:
     * - `CollateralRemoved` event indicating collateral removal operation.
     *
     * @param _holding The address of the user's holding.
     * @param _share The new collateral shares.
     */
    function unregisterCollateral(address _holding, uint256 _share) external;

    // -- Administration --

    /**
     * @notice Updates the registry configuration parameters.
     *
     * @notice Effects:
     * - Updates `config` state variable.
     *
     * @notice Emits:
     * - `ConfigUpdated` event indicating config update operation.
     *
     * @param _newConfig The new configuration parameters.
     */
    function updateConfig(
        RegistryConfig memory _newConfig
    ) external;

    /**
     * @notice Requests a change for the oracle address.
     *
     * @notice Requirements:
     * - Previous oracle change request must have expired or been accepted.
     * - No timelock or oracle data change requests should be active.
     * - `_oracle` must not be the zero address.
     *
     * @notice Effects:
     * - Updates `_isOracleActiveChange` state variable.
     * - Updates `_newOracle` state variable.
     * - Updates `_newOracleTimestamp` state variable.
     *
     * @notice Emits:
     * - `NewOracleRequested` event indicating new oracle request.
     *
     * @param _oracle The new oracle address.
     */
    function requestNewOracle(
        address _oracle
    ) external;

    /**
     * @notice Updates the oracle.
     *
     * @notice Requirements:
     * - Oracle change must have been requested and the timelock must have passed.
     *
     * @notice Effects:
     * - Updates `oracle` state variable.
     * - Updates `_isOracleActiveChange` state variable.
     * - Updates `_newOracle` state variable.
     * - Updates `_newOracleTimestamp` state variable.
     *
     * @notice Emits:
     * - `OracleUpdated` event indicating oracle update.
     */
    function setOracle() external;

    /**
     * @notice Requests a change for oracle data.
     *
     * @notice Requirements:
     * - Previous oracle data change request must have expired or been accepted.
     * - No timelock or oracle change requests should be active.
     *
     * @notice Effects:
     * - Updates `_isOracleDataActiveChange` state variable.
     * - Updates `_newOracleData` state variable.
     * - Updates `_newOracleDataTimestamp` state variable.
     *
     * @notice Emits:
     * - `NewOracleDataRequested` event indicating new oracle data request.
     *
     * @param _data The new oracle data.
     */
    function requestNewOracleData(
        bytes calldata _data
    ) external;

    /**
     * @notice Updates the oracle data.
     *
     * @notice Requirements:
     * - Oracle data change must have been requested and the timelock must have passed.
     *
     * @notice Effects:
     * - Updates `oracleData` state variable.
     * - Updates `_isOracleDataActiveChange` state variable.
     * - Updates `_newOracleData` state variable.
     * - Updates `_newOracleDataTimestamp` state variable.
     *
     * @notice Emits:
     * - `OracleDataUpdated` event indicating oracle data update.
     */
    function setOracleData() external;

    /**
     * @notice Requests a timelock update.
     *
     * @notice Requirements:
     * - `_newVal` must not be zero.
     * - Previous timelock change request must have expired or been accepted.
     * - No oracle or oracle data change requests should be active.
     *
     * @notice Effects:
     * - Updates `_isTimelockActiveChange` state variable.
     * - Updates `_oldTimelock` state variable.
     * - Updates `_newTimelock` state variable.
     * - Updates `_newTimelockTimestamp` state variable.
     *
     * @notice Emits:
     * - `TimelockAmountUpdateRequested` event indicating timelock change request.
     *
     * @param _newVal The new value in seconds.
     */
    function requestTimelockAmountChange(
        uint256 _newVal
    ) external;

    /**
     * @notice Updates the timelock amount.
     *
     * @notice Requirements:
     * - Timelock change must have been requested and the timelock must have passed.
     * - The timelock for timelock change must have already expired.
     *
     * @notice Effects:
     * - Updates `timelockAmount` state variable.
     * - Updates `_oldTimelock` state variable.
     * - Updates `_newTimelock` state variable.
     * - Updates `_newTimelockTimestamp` state variable.
     *
     * @notice Emits:
     * - `TimelockAmountUpdated` event indicating timelock amount change operation.
     */
    function acceptTimelockAmountChange() external;

    // -- Getters --

    /**
     * @notice Returns the up to date exchange rate of the `token`.
     *
     * @notice Requirements:
     * - Oracle must provide an updated rate.
     *
     * @return The updated exchange rate.
     */
    function getExchangeRate() external view returns (uint256);

    /**
     * @notice Returns the configuration parameters for the registry.
     * @return The RegistryConfig struct containing the parameters.
     */
    function getConfig() external view returns (RegistryConfig memory);
}
```

## File: src/interfaces/core/IStrategyManager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IStrategy } from ".//IStrategy.sol";
import { IManager } from "./IManager.sol";
import { IStrategyManagerMin } from "./IStrategyManagerMin.sol";

/**
 * @title IStrategyManager
 * @dev Interface for the StrategyManager contract.
 */
interface IStrategyManager is IStrategyManagerMin {
    // -- Custom Types --

    /**
     * @notice Contains details about a specific strategy, such as its performance fee, active status, and whitelisted
     * status.
     * @param performanceFee fee charged as a percentage of the profits generated by the strategy.
     * @param active flag indicating whether the strategy is active.
     * @param whitelisted flag indicating whether strategy is approved for investment.
     */
    struct StrategyInfo {
        uint256 performanceFee;
        bool active;
        bool whitelisted;
    }

    /**
     * @notice Contains data required for moving investment from one strategy to another.
     * @param strategyFrom strategy's address where investment is taken from.
     * @param strategyTo strategy's address where to invest.
     * @param shares investment amount.
     * @param dataFrom data required by `strategyFrom` to perform `_claimInvestment`.
     * @param dataTo data required by `strategyTo` to perform `_invest`.
     * @param strategyToMinSharesAmountOut minimum amount of shares to receive.
     */
    struct MoveInvestmentData {
        address strategyFrom;
        address strategyTo;
        uint256 shares;
        bytes dataFrom;
        bytes dataTo;
        uint256 strategyToMinSharesAmountOut;
    }

    /**
     * @dev Struct used for _claimInvestment function
     * @param strategyContract The strategy contract instance being interacted with
     * @param withdrawnAmount The amount of the asset withdrawn from the strategy
     * @param initialInvestment The amount of initial investment
     * @param yield The yield amount (positive for profit, negative for loss)
     * @param fee The amount of fee charged by the strategy
     * @param remainingShares The number of shares remaining after the withdrawal
     */
    struct ClaimInvestmentData {
        IStrategy strategyContract;
        uint256 withdrawnAmount;
        uint256 initialInvestment;
        int256 yield;
        uint256 fee;
        uint256 remainingShares;
    }

    // -- Events --

    /**
     * @notice Emitted when a new strategy is added to the whitelist.
     * @param strategy The address of the strategy that was added.
     */
    event StrategyAdded(address indexed strategy);

    /**
     * @notice Emitted when an existing strategy is removed from the whitelist.
     * @param strategy The address of the strategy that was removed.
     */
    event StrategyRemoved(address indexed strategy);

    /**
     * @notice Emitted when an existing strategy info is updated.
     * @param strategy The address of the strategy that was updated.
     * @param active Indicates if the strategy is active.
     * @param fee The fee associated with the strategy.
     */
    event StrategyUpdated(address indexed strategy, bool active, uint256 fee);

    /**
     * @notice Emitted when an investment is created.
     * @param holding The address of the holding.
     * @param user The address of the user.
     * @param token The address of the token invested.
     * @param strategy The address of the strategy used for investment.
     * @param amount The amount of tokens invested.
     * @param tokenOutResult The result amount of the output token.
     * @param tokenInResult The result amount of the input token.
     */
    event Invested(
        address indexed holding,
        address indexed user,
        address indexed token,
        address strategy,
        uint256 amount,
        uint256 tokenOutResult,
        uint256 tokenInResult
    );

    /**
     * @notice Emitted when an investment is moved between strategies.
     * @param holding The address of the holding.
     * @param user The address of the user.
     * @param token The address of the token invested.
     * @param strategyFrom The address of the strategy from which the investment is moved.
     * @param strategyTo The address of the strategy to which the investment is moved.
     * @param shares The amount of shares moved.
     * @param tokenOutResult The result amount of the output token.
     * @param tokenInResult The result amount of the input token.
     */
    event InvestmentMoved(
        address indexed holding,
        address indexed user,
        address indexed token,
        address strategyFrom,
        address strategyTo,
        uint256 shares,
        uint256 tokenOutResult,
        uint256 tokenInResult
    );

    /**
     * @notice Emitted when collateral is adjusted from a claim investment or claim rewards operation.
     * @param holding The address of the holding.
     * @param token The address of the token.
     * @param value The value of the collateral adjustment.
     * @param add Indicates if the collateral is added (true) or removed (false).
     */
    event CollateralAdjusted(address indexed holding, address indexed token, uint256 value, bool add);

    /**
     * @notice Emitted when an investment is withdrawn.
     * @param holding The address of the holding.
     * @param user The address of the user.
     * @param token The address of the token withdrawn.
     * @param strategy The address of the strategy from which the investment is withdrawn.
     * @param shares The amount of shares withdrawn.
     * @param withdrawnAmount The amount of tokens withdrawn.
     * @param initialInvestment The amount of initial investment.
     * @param yield The yield amount (positive for profit, negative for loss)
     * @param fee The amount of fee charged by the strategy
     */
    event StrategyClaim(
        address indexed holding,
        address indexed user,
        address indexed token,
        address strategy,
        uint256 shares,
        uint256 withdrawnAmount,
        uint256 initialInvestment,
        int256 yield,
        uint256 fee
    );

    /**
     * @notice Emitted when rewards are claimed.
     * @param token The address of the token rewarded.
     * @param holding The address of the holding.
     * @param amount The amount of rewards claimed.
     */
    event RewardsClaimed(address indexed token, address indexed holding, uint256 amount);

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     * @return The manager contract.
     */
    function manager() external view returns (IManager);

    // -- User specific methods --

    /**
     * @notice Invests `_token` into `_strategy`.
     *
     * @notice Requirements:
     * - Strategy must be whitelisted.
     * - Amount must be non-zero.
     * - Token specified for investment must be whitelisted.
     * - Msg.sender must have holding.
     *
     * @notice Effects:
     * - Performs investment to the specified `_strategy`.
     * - Deposits holding's collateral to the specified `_strategy`.
     * - Adds `_strategy` used for investment to the holdingToStrategy data structure.
     *
     * @notice Emits:
     * - Invested event indicating successful investment operation.
     *
     * @param _token address.
     * @param _strategy address.
     * @param _amount to be invested.
     * @param _minSharesAmountOut minimum amount of shares to receive.
     * @param _data needed by each individual strategy.
     *
     * @return tokenOutAmount receipt tokens amount.
     * @return tokenInAmount tokenIn amount.
     */
    function invest(
        address _token,
        address _strategy,
        uint256 _amount,
        uint256 _minSharesAmountOut,
        bytes calldata _data
    ) external returns (uint256 tokenOutAmount, uint256 tokenInAmount);

    /**
     * @notice Claims investment from one strategy and invests it into another.
     *
     * @notice Requirements:
     * - The `strategyFrom` and `strategyTo` must be valid and active.
     * - The `strategyFrom` and `strategyTo` must be different.
     * - Msg.sender must have a holding.
     *
     * @notice Effects:
     * - Claims the investment from `strategyFrom`.
     * - Invests the claimed amount into `strategyTo`.
     *
     * @notice Emits:
     * - InvestmentMoved event indicating successful investment movement operation.
     *
     * @dev Some strategies won't give back any receipt tokens; in this case 'tokenOutAmount' will be 0.
     * @dev 'tokenInAmount' will be equal to '_amount' in case the '_asset' is the same as strategy 'tokenIn()'.
     *
     * @param _token The address of the token.
     * @param _data The MoveInvestmentData object containing strategy and amount details.
     *
     * @return tokenOutAmount The amount of receipt tokens returned.
     * @return tokenInAmount The amount of tokens invested in the new strategy.
     */
    function moveInvestment(
        address _token,
        MoveInvestmentData calldata _data
    ) external returns (uint256 tokenOutAmount, uint256 tokenInAmount);

    /**
     * @notice Claims a strategy investment.
     *
     * @notice Requirements:
     * - The `_strategy` must be valid.
     * - Msg.sender must be allowed to execute the call.
     * - `_shares` must be of valid amount.
     * - Specified `_holding` must exist within protocol.
     *
     * @notice Effects:
     * - Withdraws investment from `_strategy`.
     * - Updates `holdingToStrategy` if needed.
     *
     * @notice Emits:
     * - StrategyClaim event indicating successful claim operation.
     *
     * @dev Withdraws investment from a strategy.
     * @dev Some strategies will allow only the tokenIn to be withdrawn.
     * @dev 'AssetAmount' will be equal to 'tokenInAmount' in case the '_asset' is the same as strategy 'tokenIn()'.
     *
     * @param _holding holding's address.
     * @param _token address to be received.
     * @param _strategy strategy to invest into.
     * @param _shares shares amount.
     * @param _data extra data.
     *
     * @return withdrawnAmount The amount of tokens withdrawn.
     * @return initialInvestment The amount of initial investment.
     * @return yield The yield amount (positive for profit, negative for loss)
     * @return fee The amount of fee charged by the strategy
     */
    function claimInvestment(
        address _holding,
        address _token,
        address _strategy,
        uint256 _shares,
        bytes calldata _data
    ) external returns (uint256 withdrawnAmount, uint256 initialInvestment, int256 yield, uint256 fee);

    /**
     * @notice Claims rewards from strategy.
     *
     * @notice Requirements:
     * - The `_strategy` must be valid.
     * - Msg.sender must have valid holding within protocol.
     *
     * @notice Effects:
     * - Claims rewards from strategies.
     * - Adds accrued rewards as a collateral for holding.
     *
     * @param _strategy strategy to invest into.
     * @param _data extra data.
     *
     * @return rewards reward amounts.
     * @return tokens reward tokens.
     */
    function claimRewards(
        address _strategy,
        bytes calldata _data
    ) external returns (uint256[] memory rewards, address[] memory tokens);

    // -- Administration --

    /**
     * @notice Adds a new strategy to the whitelist.
     * @param _strategy strategy's address.
     */
    function addStrategy(
        address _strategy
    ) external;

    /**
     * @notice Updates an existing strategy info.
     * @param _strategy strategy's address.
     * @param _info info.
     */
    function updateStrategy(address _strategy, StrategyInfo calldata _info) external;

    /**
     * @notice Triggers stopped state.
     */
    function pause() external;

    /**
     * @notice Returns to normal state.
     */
    function unpause() external;

    // -- Getters --

    /**
     * @notice Returns all the strategies holding has invested in.
     * @dev Should be only called off-chain as can be high gas consuming.
     * @param _holding address for which the strategies are requested.
     */
    function getHoldingToStrategy(
        address _holding
    ) external view returns (address[] memory);

    /**
     * @notice Returns the number of strategies the holding has invested in.
     * @param _holding address for which the strategy count is requested.
     * @return uint256 The number of strategies the holding has invested in.
     */
    function getHoldingToStrategyLength(
        address _holding
    ) external view returns (uint256);
}
```

## File: src/interfaces/core/ISwapManager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IManager } from "./IManager.sol";

/**
 * @title ISwapManager
 * @dev Interface for the SwapManager Contract.
 */
interface ISwapManager {
    // -- Events --

    /**
     * @notice Emitted when when the Swap Router is updated
     * @param oldAddress The old UniswapV3 Swap Router address.
     * @param newAddress The new UniswapV3 Swap Router address.
     */
    event SwapRouterUpdated(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Emitted when exact output swap is executed on UniswapV3 Pool.
     * @param holding The holding address associated with the user.
     * @param path The optimal path for the multi-hop swap.
     * @param amountIn The amount of the input token used for the swap.
     * @param amountOut The amount of the output token received after the swap.
     */
    event exactOutputSwap(address indexed holding, bytes path, uint256 amountIn, uint256 amountOut);

    /**
     * @notice Returns the address of the UniswapV3 Swap Router.
     */
    function swapRouter() external view returns (address);

    /**
     * @notice Returns the address of the UniswapV3 Factory.
     */
    function uniswapFactory() external view returns (address);

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     * @return The manager contract.
     */
    function manager() external view returns (IManager);

    // -- User specific methods --

    /**
     * @notice Swaps a minimum possible amount of `_tokenIn` for a fixed amount of `tokenOut` via `_swapPath`.
     *
     * @notice Requirements:
     * - The jUSD UniswapV3 Pool must be valid.
     * - The caller must be Liquidation Manager Contract.
     *
     * @notice Effects:
     * - Approves and transfers `tokenIn` from the `_userHolding`.
     * - Approves UniswapV3 Router to transfer `tokenIn` from address(this) to perform the `exactOutput` swap.
     * - Executes the `exactOutput` swap
     * - Handles any excess tokens.
     *
     * @param _tokenIn The address of the inbound asset.
     * @param _swapPath The optimal path for the multi-hop swap.
     * @param _userHolding The holding address associated with the user.
     * @param _deadline The timestamp representing the latest time by which the swap operation must be completed.
     * @param _amountOut The desired amount of `tokenOut`.
     * @param _amountInMaximum The maximum amount of `_tokenIn` to be swapped for the specified `_amountOut`.
     *
     * @return amountIn The amount of `_tokenIn` spent to receive the desired `amountOut` of `tokenOut`.
     */
    function swapExactOutputMultihop(
        address _tokenIn,
        bytes calldata _swapPath,
        address _userHolding,
        uint256 _deadline,
        uint256 _amountOut,
        uint256 _amountInMaximum
    ) external returns (uint256 amountIn);

    // -- Administration --

    /**
     * @notice Updates the Swap Router address.
     *
     * @notice Requirements:
     * - The new `_swapRouter` address must be valid and different from the current one.
     *
     * @notice Effects:
     * - Updates the `swapRouter` state variable.
     *
     * @notice Emits:
     * - `SwapRouterUpdated` event indicating successful swap router update operation.
     *
     * @param _swapRouter Swap Router's new address.
     */
    function setSwapRouter(
        address _swapRouter
    ) external;

    /**
     * @notice This struct stores temporary data required for a token swap
     */
    struct SwapTempData {
        address tokenIn; // The address of the token to be swapped
        bytes swapPath; // The swap path to be used for swap
        address userHolding; // User's holding address
        uint256 deadline; // The latest time by which the swap operation must be completed.
        uint256 amountOut; // The exact amount to be received after the swap
        uint256 amountInMaximum; // The maximum amount of `tokenIn` to be swapped
        address router; // The address of the UniswapV3 Swap Router to be used for the swap
    }

    /**
     * @notice This struct stores temporary data for the validPool modifier
     */
    struct ValidPoolTempData {
        IERC20 jUsd; // The interface the jUSD token
        address tokenA; // The address of the token A
        uint24 fee; // The fee for of the UniswapV3 Pool
        address tokenB; // The address of token B
    }
}
```

## File: src/oracles/chronicle/ChronicleOracleFactory.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";

import { IChronicleOracle } from "./interfaces/IChronicleOracle.sol";
import { IChronicleOracleFactory } from "./interfaces/IChronicleOracleFactory.sol";
/**
 * @title ChronicleOracleFactory
 * @dev This contract creates new instances of Chronicle oracles for Jigsaw Protocol using the clone factory pattern.
 */

contract ChronicleOracleFactory is IChronicleOracleFactory, Ownable2Step {
    /**
     * @notice Address of the reference implementation.
     */
    address public override referenceImplementation;

    /**
     * @notice Creates a new ChronicleOracleFactory contract.
     * @param _initialOwner The initial owner of the contract.
     * @param _referenceImplementation The reference implementation address.
     */
    constructor(address _initialOwner, address _referenceImplementation) Ownable(_initialOwner) {
        // Assert that `referenceImplementation` have code to protect the system.
        require(_referenceImplementation.code.length > 0, "3096");

        // Save the referenceImplementation for cloning.
        emit ChronicleOracleImplementationUpdated(_referenceImplementation);
        referenceImplementation = _referenceImplementation;
    }

    // -- Administration --

    /**
     * @notice Sets the reference implementation address.
     * @param _referenceImplementation Address of the new reference implementation contract.
     */
    function setReferenceImplementation(
        address _referenceImplementation
    ) external override onlyOwner {
        // Assert that referenceImplementation has code in it to protect the system from cloning invalid implementation.
        require(_referenceImplementation.code.length > 0, "3096");
        require(_referenceImplementation != referenceImplementation, "3062");

        emit ChronicleOracleImplementationUpdated(_referenceImplementation);
        referenceImplementation = _referenceImplementation;
    }

    // -- Chronicle oracle creation --

    /**
     * @notice Creates a new Chronicle oracle by cloning the reference implementation.
     *
     * @param _initialOwner The address of the initial owner of the contract.
     * @param _underlying The address of the token the oracle is for.
     * @param _chronicle The Address of the Chronicle Oracle.
     * @param _ageValidityPeriod The Age in seconds after which the price is considered invalid.
     *
     * @return newChronicleOracleAddress Address of the newly created Chronicle oracle.
     */
    function createChronicleOracle(
        address _initialOwner,
        address _underlying,
        address _chronicle,
        uint256 _ageValidityPeriod
    ) external override returns (address newChronicleOracleAddress) {
        require(_chronicle.code.length > 0, "3096");
        require(_ageValidityPeriod > 0, "Zero age");

        // Clone the Chronicle oracle implementation.
        newChronicleOracleAddress = Clones.cloneDeterministic({
            implementation: referenceImplementation,
            salt: keccak256(abi.encodePacked(_initialOwner, _underlying, _chronicle))
        });

        // Initialize the new Chronicle oracle's contract.
        IChronicleOracle(newChronicleOracleAddress).initialize({
            _initialOwner: _initialOwner,
            _underlying: _underlying,
            _chronicle: _chronicle,
            _ageValidityPeriod: _ageValidityPeriod
        });
    }

    /**
     * @dev Renounce ownership override to avoid losing contract's ownership.
     */
    function renounceOwnership() public pure virtual override {
        revert("1000");
    }
}
```

## File: src/ReceiptToken.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import { IReceiptToken } from "./interfaces/core/IReceiptToken.sol";

/**
 * @title ReceiptToken
 * @dev Token minted when users invest into strategies based on Curve LP Token.
 *
 * @dev This contract inherits functionalities from `OwnableUpgradeable` and `ReentrancyGuardUpgradeable`.
 *
 * @author Hovooo (@hovooo).
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract ReceiptToken is IReceiptToken, ERC20Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    address public minter;

    // --- Constructor ---

    /**
     * @dev To prevent the implementation contract from being used, the _disableInitializers function is invoked
     * in the constructor to automatically lock it when it is deployed.
     */
    constructor() {
        _disableInitializers();
    }

    // --- Initialization ---

    /**
     * @notice This function initializes the contract (instead of a constructor) to be cloned.
     *
     * @notice Requirements:
     * - Sets the owner of the contract.
     * - The contract must not be already initialized.
     * - The `__minter` must not be the zero address.
     *
     * @notice Effects:
     * - Updates `_name`, `_symbol`, `minter` state variables.
     * - Stores `__owner` as owner.
     *
     * @param __name Receipt token name.
     * @param __symbol Receipt token symbol.
     * @param __minter Receipt token minter.
     * @param __owner Receipt token owner.
     */
    function initialize(
        string memory __name,
        string memory __symbol,
        address __minter,
        address __owner
    ) external override initializer {
        require(__minter != address(0), "3000");
        minter = __minter;

        // Initialize OwnableUpgradeable contract.
        __Ownable_init(__owner);
        // Initialize ERC20Upgradeable contract.
        __ERC20_init(__name, __symbol);
        //@audit reentrancy guard not initialized?
    }

    /**
     * @notice Mints receipt tokens.
     *
     * @notice Requirements:
     * - Must be called by the Minter or Owner of the Contract.
     *
     * @notice Effects:
     * - Mints the specified amount of tokens to the given address.
     *
     * @param _user Address of the user receiving minted tokens.
     * @param _amount The amount to be minted.
     */
    function mint(address _user, uint256 _amount) external override nonReentrant onlyMinterOrOwner {
        _mint(_user, _amount);
    }

    /**
     * @notice Burns tokens from an address.
     *
     * @notice Requirements:
     * - Must be called by the Minter or Owner of the Contract.
     *
     * @notice Effects:
     * - Burns the specified amount of tokens from the specified address.
     *
     * @param _user The user to burn it from.
     * @param _amount The amount of tokens to be burnt.
     */
    function burnFrom(address _user, uint256 _amount) external override nonReentrant onlyMinterOrOwner {
        _burn(_user, _amount);
    }

    /**
     * @notice Sets minter.
     *
     * @notice Requirements:
     * - Must be called by the Minter or Owner of the Contract.
     * - The `_minter` must be different from `minter`.
     *
     * @notice Effects:
     * - Updates minter state variable.
     *
     * @notice Emits:
     * - `MinterUpdated` event indicating minter update operation.
     *
     * @param _minter The user to burn it from.
     */
    function setMinter(
        address _minter
    ) external override nonReentrant onlyMinterOrOwner {
        require(_minter != minter, "3062");
        emit MinterUpdated({ oldMinter: minter, newMinter: _minter });
        minter = _minter;
    }

    /**
     * @dev Renounce ownership override to avoid losing contract's ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }

    // -- Modifiers --

    modifier onlyMinterOrOwner() {
        require(msg.sender == minter || msg.sender == owner(), "1000");
        _;
    }
}
```

## File: src/StrategyManager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20, IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { SignedMath } from "@openzeppelin/contracts/utils/math/SignedMath.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { OperationsLib } from "./libraries/OperationsLib.sol";

import { IHolding } from "./interfaces/core/IHolding.sol";
import { IHoldingManager } from "./interfaces/core/IHoldingManager.sol";
import { IManager } from "./interfaces/core/IManager.sol";

import { ISharesRegistry } from "./interfaces/core/ISharesRegistry.sol";
import { IStablesManager } from "./interfaces/core/IStablesManager.sol";
import { IStrategy } from "./interfaces/core/IStrategy.sol";
import { IStrategyManager } from "./interfaces/core/IStrategyManager.sol";

/**
 * @title StrategyManager
 *
 * @notice Manages investments of the user's assets into the whitelisted strategies to generate applicable revenue.
 *
 * @dev This contract inherits functionalities from  `Ownable2Step`, `ReentrancyGuard`, and `Pausable`.
 *
 * @author Hovooo (@hovooo), Cosmin Grigore (@gcosmintech).
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract StrategyManager is IStrategyManager, Ownable2Step, ReentrancyGuard, Pausable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using SignedMath for int256;

    /**
     * @notice Returns whitelisted Strategies' info.
     */
    mapping(address strategy => StrategyInfo info) public override strategyInfo;

    /**
     * @notice Stores the strategies holding has invested in.
     */
    mapping(address holding => EnumerableSet.AddressSet strategies) private holdingToStrategy;

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     */
    IManager public immutable override manager;

    /**
     * @notice Creates a new StrategyManager contract.
     * @param _initialOwner The initial owner of the contract.
     * @param _manager Contract that holds all the necessary configs of the protocol.
     */
    constructor(address _initialOwner, address _manager) Ownable(_initialOwner) {
        require(_manager != address(0), "3065");
        manager = IManager(_manager);
    }

    // -- User specific methods --

    /**
     * @notice Invests `_token` into `_strategy`.
     *
     * @notice Requirements:
     * - Strategy must be whitelisted.
     * - Amount must be non-zero.
     * - Token specified for investment must be whitelisted.
     * - Msg.sender must have holding.
     *
     * @notice Effects:
     * - Performs investment to the specified `_strategy`.
     * - Deposits holding's collateral to the specified `_strategy`.
     * - Adds `_strategy` used for investment to the holdingToStrategy data structure.
     *
     * @notice Emits:
     * - Invested event indicating successful investment operation.
     *
     * @param _token address.
     * @param _strategy address.
     * @param _amount to be invested.
     * @param _minSharesAmountOut minimum amount of shares to receive.
     * @param _data needed by each individual strategy.
     *
     * @return tokenOutAmount receipt tokens amount.
     * @return tokenInAmount tokenIn amount.
     */
    function invest(
        address _token,
        address _strategy,
        uint256 _amount,
        uint256 _minSharesAmountOut,
        bytes calldata _data
    )
        external
        override
        validStrategy(_strategy)
        validAmount(_amount)
        validToken(_token)
        whenNotPaused
        nonReentrant
        returns (uint256 tokenOutAmount, uint256 tokenInAmount)
    {
        address _holding = _getHoldingManager().userHolding(msg.sender);
        require(_getHoldingManager().isHolding(_holding), "3002");
        require(strategyInfo[_strategy].active, "1202");
        require(IStrategy(_strategy).tokenIn() == _token, "3085");

        (tokenOutAmount, tokenInAmount) = _invest({
            _holding: _holding,
            _token: _token,
            _strategy: _strategy,
            _amount: _amount,
            _minSharesAmountOut: _minSharesAmountOut,
            _data: _data
        });

        emit Invested(_holding, msg.sender, _token, _strategy, _amount, tokenOutAmount, tokenInAmount);
        return (tokenOutAmount, tokenInAmount);
    }

    /**
     * @notice Claims investment from one strategy and invests it into another.
     *
     * @notice Requirements:
     * - The `strategyTo` must be valid and active.
     * - The `strategyFrom` and `strategyTo` must be different.
     * - Msg.sender must have a holding.
     *
     * @notice Effects:
     * - Claims the investment from `strategyFrom`.
     * - Invests the claimed amount into `strategyTo`.
     *
     * @notice Emits:
     * - InvestmentMoved event indicating successful investment movement operation.
     *
     * @dev Some strategies won't give back any receipt tokens; in this case 'tokenOutAmount' will be 0.
     * @dev 'tokenInAmount' will be equal to '_amount' in case the '_asset' is the same as strategy 'tokenIn()'.
     *
     * @param _token The address of the token.
     * @param _data The MoveInvestmentData object containing strategy and amount details.
     *
     * @return tokenOutAmount The amount of receipt tokens returned.
     * @return tokenInAmount The amount of tokens invested in the new strategy.
     */
    function moveInvestment(
        address _token,
        MoveInvestmentData calldata _data
    )
        external
        override
        validStrategy(_data.strategyFrom)
        validStrategy(_data.strategyTo)
        nonReentrant
        whenNotPaused
        returns (uint256 tokenOutAmount, uint256 tokenInAmount)
    {
        address _holding = _getHoldingManager().userHolding(msg.sender);
        require(_getHoldingManager().isHolding(_holding), "3002");
        require(_data.strategyFrom != _data.strategyTo, "3086");
        require(strategyInfo[_data.strategyTo].active, "1202");
        require(IStrategy(_data.strategyFrom).tokenIn() == _token, "3001");
        require(IStrategy(_data.strategyTo).tokenIn() == _token, "3085");

        (uint256 claimResult,,,) = _claimInvestment({
            _holding: _holding,
            _token: _token,
            _strategy: _data.strategyFrom,
            _shares: _data.shares,
            _data: _data.dataFrom
        });
        (tokenOutAmount, tokenInAmount) = _invest({
            _holding: _holding,
            _token: _token,
            _strategy: _data.strategyTo,
            _amount: claimResult,
            _minSharesAmountOut: _data.strategyToMinSharesAmountOut,
            _data: _data.dataTo
        });

        emit InvestmentMoved(
            _holding,
            msg.sender,
            _token,
            _data.strategyFrom,
            _data.strategyTo,
            _data.shares,
            tokenOutAmount,
            tokenInAmount
        );

        return (tokenOutAmount, tokenInAmount);
    }

    /**
     * @notice Claims a strategy investment.
     *
     * @notice Requirements:
     * - The `_strategy` must be valid.
     * - Msg.sender must be allowed to execute the call.
     * - `_shares` must be of valid amount.
     * - Specified `_holding` must exist within protocol.
     *
     * @notice Effects:
     * - Withdraws investment from `_strategy`.
     * - Updates `holdingToStrategy` if needed.
     *
     * @notice Emits:
     * - StrategyClaim event indicating successful claim operation.
     *
     * @dev Withdraws investment from a strategy.
     * @dev Some strategies will allow only the tokenIn to be withdrawn.
     * @dev 'AssetAmount' will be equal to 'tokenInAmount' in case the '_asset' is the same as strategy 'tokenIn()'.
     *
     * @param _holding holding's address.
     * @param _token address to be received.
     * @param _strategy strategy to invest into.
     * @param _shares shares amount.
     * @param _data extra data.
     *
     * @return withdrawnAmount returned asset amount obtained from the operation.
     * @return initialInvestment returned token in amount.
     * @return yield The yield amount (positive for profit, negative for loss)
     * @return fee The amount of fee charged by the strategy
     */
    function claimInvestment(
        address _holding,
        address _token,
        address _strategy,
        uint256 _shares,
        bytes calldata _data
    )
        external
        override
        validStrategy(_strategy)
        onlyAllowed(_holding)
        validAmount(_shares)
        nonReentrant
        whenNotPaused
        returns (uint256 withdrawnAmount, uint256 initialInvestment, int256 yield, uint256 fee)
    {
        require(_getHoldingManager().isHolding(_holding), "3002");
        (withdrawnAmount, initialInvestment, yield, fee) = _claimInvestment({
            _holding: _holding,
            _token: _token,
            _strategy: _strategy,
            _shares: _shares,
            _data: _data
        });

        emit StrategyClaim({
            holding: _holding,
            user: msg.sender,
            token: _token,
            strategy: _strategy,
            shares: _shares,
            withdrawnAmount: withdrawnAmount,
            initialInvestment: initialInvestment,
            yield: yield,
            fee: fee
        });
    }

    /**
     * @notice Claims rewards from strategy.
     *
     * @notice Requirements:
     * - The `_strategy` must be valid.
     * - Msg.sender must have valid holding within protocol.
     *
     * @notice Effects:
     * - Claims rewards from strategies.
     * - Adds accrued rewards as a collateral for holding.
     *
     * @param _strategy strategy to invest into.
     * @param _data extra data.
     *
     * @return rewards reward amounts.
     * @return tokens reward tokens.
     */
    function claimRewards(
        address _strategy,
        bytes calldata _data
    )
        external
        override
        validStrategy(_strategy)
        nonReentrant
        whenNotPaused
        returns (uint256[] memory rewards, address[] memory tokens)
    {
        address _holding = _getHoldingManager().userHolding(msg.sender);
        require(_getHoldingManager().isHolding(_holding), "3002");

        (rewards, tokens) = IStrategy(_strategy).claimRewards({ _recipient: _holding, _data: _data });

        for (uint256 i = 0; i < rewards.length; i++) {
            _accrueRewards({ _token: tokens[i], _amount: rewards[i], _holding: _holding });
        }
    }

    // -- Administration --

    /**
     * @notice Adds a new strategy to the whitelist.
     * @param _strategy strategy's address.
     */
    function addStrategy(
        address _strategy
    ) public override onlyOwner validAddress(_strategy) {
        require(!strategyInfo[_strategy].whitelisted, "3014");
        StrategyInfo memory info = StrategyInfo(0, false, false);
        info.performanceFee = manager.performanceFee();
        info.active = true;
        info.whitelisted = true;

        strategyInfo[_strategy] = info;

        emit StrategyAdded(_strategy);
    }

    /**
     * @notice Updates an existing strategy info.
     * @param _strategy strategy's address.
     * @param _info info.
     */
    function updateStrategy(
        address _strategy,
        StrategyInfo calldata _info
    ) external override onlyOwner validStrategy(_strategy) {
        require(_info.whitelisted, "3104");
        require(_info.performanceFee <= OperationsLib.FEE_FACTOR, "3105");
        strategyInfo[_strategy] = _info;
        emit StrategyUpdated(_strategy, _info.active, _info.performanceFee);
    }

    /**
     * @notice Triggers stopped state.
     */
    function pause() external override onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     */
    function unpause() external override onlyOwner whenPaused {
        _unpause();
    }

    /**
     * @notice Override to avoid losing contract ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }

    // -- Getters --

    /**
     * @notice Returns all the strategies holding has invested in.
     * @dev Should be only called off-chain as can be high gas consuming.
     * @param _holding address for which the strategies are requested.
     */
    function getHoldingToStrategy(
        address _holding
    ) external view returns (address[] memory) {
        return holdingToStrategy[_holding].values();
    }

    /**
     * @notice Returns the number of strategies the holding has invested in.
     * @param _holding address for which the strategy count is requested.
     * @return uint256 The number of strategies the holding has invested in.
     */
    function getHoldingToStrategyLength(
        address _holding
    ) external view returns (uint256) {
        return holdingToStrategy[_holding].length();
    }

    // -- Private methods --

    /**
     * @notice Accrues rewards for a specific token and amount to a holding address.
     *
     * @notice Effects:
     * - Adds collateral to the holding if the amount is greater than 0 and the share registry address is not zero.
     *
     * @notice Emits:
     * - CollateralAdjusted event indicating successful collateral adjustment operation.
     *
     * @param _token address for which rewards are being accrued.
     * @param _amount of the token to accrue as rewards.
     * @param _holding address to which the rewards are accrued.
     */
    function _accrueRewards(address _token, uint256 _amount, address _holding) private {
        if (_amount > 0) {
            (bool active, address shareRegistry) = _getStablesManager().shareRegistryInfo(_token);

            if (shareRegistry != address(0) && active) {
                //add collateral
                emit CollateralAdjusted(_holding, _token, _amount, true);
                _getStablesManager().addCollateral(_holding, _token, _amount);
            }
        }
    }

    /**
     * @notice Invests a specified amount of a token from a holding into a strategy.
     *
     * @notice Effects:
     * - Deposits the specified amount of the token into the given strategy.
     * - Updates the holding's invested strategies set.
     *
     * @param _holding address from which the investment is made.
     * @param _token address to be invested.
     * @param _strategy address into which the token is invested.
     * @param _amount token to invest.
     * @param _minSharesAmountOut minimum amount of shares to receive.
     * @param _data required by the strategy's deposit function.
     *
     * @return tokenOutAmount The amount of tokens received from the strategy.
     * @return tokenInAmount The amount of tokens invested into the strategy.
     */
    function _invest(
        address _holding,
        address _token,
        address _strategy,
        uint256 _amount,
        uint256 _minSharesAmountOut,
        bytes calldata _data
    ) private returns (uint256 tokenOutAmount, uint256 tokenInAmount) {
        (tokenOutAmount, tokenInAmount) = IStrategy(_strategy).deposit(_token, _amount, _holding, _data);
        require(tokenOutAmount != 0 && tokenOutAmount >= _minSharesAmountOut, "3030");

        // Ensure holding is not liquidatable after investment
        require(!_getStablesManager().isLiquidatable(_token, _holding), "3103");

        // Add strategy to the set, which stores holding's all invested strategies
        holdingToStrategy[_holding].add(_strategy);
    }

    /**
     * @notice Withdraws invested amount from a strategy.
     *
     * @notice Effects:
     * - Withdraws investment from `_strategy`.
     * - Removes strategy from holding's invested strategies set if `remainingShares` == 0.
     *
     * @param _holding address from which the investment is being claimed.
     * @param _token address to be withdrawn from the strategy.
     * @param _strategy address from which the investment is being claimed.
     * @param _shares number to be withdrawn from the strategy.
     * @param _data data required by the strategy's withdraw function.
     *
     * @return assetResult The amount of the asset withdrawn from the strategy.
     * @return tokenInResult The amount of tokens received in exchange for the withdrawn asset.
     */
    function _claimInvestment(
        address _holding,
        address _token,
        address _strategy,
        uint256 _shares,
        bytes calldata _data
    ) private returns (uint256, uint256, int256, uint256) {
        ClaimInvestmentData memory tempData = ClaimInvestmentData({
            strategyContract: IStrategy(_strategy),
            withdrawnAmount: 0,
            initialInvestment: 0,
            yield: 0,
            fee: 0,
            remainingShares: 0
        });

        // First check if holding has enough receipt tokens to burn.
        _checkReceiptTokenAvailability({ _strategy: tempData.strategyContract, _shares: _shares, _holding: _holding });

        (tempData.withdrawnAmount, tempData.initialInvestment, tempData.yield, tempData.fee) =
            tempData.strategyContract.withdraw({ _shares: _shares, _recipient: _holding, _asset: _token, _data: _data });
        require(tempData.withdrawnAmount > 0, "3016");

        if (tempData.yield > 0) {
            _getStablesManager().addCollateral({ _holding: _holding, _token: _token, _amount: uint256(tempData.yield) });
        }
        if (tempData.yield < 0) {
            _getStablesManager().removeCollateral({ _holding: _holding, _token: _token, _amount: tempData.yield.abs() });
        }

        // Ensure user doesn't harm themselves by becoming liquidatable after claiming investment.
        // If function is called by liquidation manager, we don't need to check if holding is liquidatable,
        // as we need to save as much collateral as possible.
        if (manager.liquidationManager() != msg.sender) {
            require(!_getStablesManager().isLiquidatable(_token, _holding), "3103");
        }

        // If after the claim holding no longer has shares in the strategy remove that strategy from the set.
        (, tempData.remainingShares) = tempData.strategyContract.recipients(_holding);
        if (0 == tempData.remainingShares) holdingToStrategy[_holding].remove(_strategy);

        return (tempData.withdrawnAmount, tempData.initialInvestment, tempData.yield, tempData.fee);
    }

    /**
     * @notice Checks the availability of receipt tokens in the holding.
     *
     * @notice Requirements:
     * - Holding must have enough receipt tokens for the specified number of shares.
     *
     * @param _strategy contract's instance.
     * @param _shares number being checked for receipt token availability.
     * @param _holding address for which the receipt token availability is being checked.
     */
    function _checkReceiptTokenAvailability(IStrategy _strategy, uint256 _shares, address _holding) private view {
        uint256 tokenDecimals = _strategy.sharesDecimals();
        (, uint256 totalShares) = _strategy.recipients(_holding);
        uint256 rtAmount = _shares > totalShares ? totalShares : _shares;

        if (tokenDecimals > 18) {
            rtAmount = rtAmount / (10 ** (tokenDecimals - 18));
        } else {
            rtAmount = rtAmount * (10 ** (18 - tokenDecimals));
        }

        require(IERC20(_strategy.getReceiptTokenAddress()).balanceOf(_holding) >= rtAmount);
    }

    /**
     * @notice Retrieves the instance of the Holding Manager contract.
     * @return IHoldingManager contract's instance.
     */
    function _getHoldingManager() private view returns (IHoldingManager) {
        return IHoldingManager(manager.holdingManager());
    }

    /**
     * @notice Retrieves the instance of the Stables Manager contract.
     * @return IStablesManager contract's instance.
     */
    function _getStablesManager() private view returns (IStablesManager) {
        return IStablesManager(manager.stablesManager());
    }

    // -- Modifiers --

    /**
     * @dev Modifier to check if the address is valid (not zero address).
     * @param _address being checked.
     */
    modifier validAddress(
        address _address
    ) {
        require(_address != address(0), "3000");
        _;
    }

    /**
     * @dev Modifier to check if the strategy address is valid (whitelisted).
     * @param _strategy address being checked.
     */
    modifier validStrategy(
        address _strategy
    ) {
        require(strategyInfo[_strategy].whitelisted, "3029");
        _;
    }

    /**
     * @dev Modifier to check if the amount is valid (greater than zero).
     * @param _amount being checked.
     */
    modifier validAmount(
        uint256 _amount
    ) {
        require(_amount > 0, "2001");
        _;
    }

    /**
     * @dev Modifier to check if the sender is allowed to perform the action.
     * @param _holding address being accessed.
     */
    modifier onlyAllowed(
        address _holding
    ) {
        require(
            manager.liquidationManager() == msg.sender || _getHoldingManager().holdingUser(_holding) == msg.sender,
            "1000"
        );
        _;
    }

    /**
     * @dev Modifier to check if the token is valid (whitelisted).
     * @param _token address being checked.
     */
    modifier validToken(
        address _token
    ) {
        require(manager.isTokenWhitelisted(_token), "3001");
        _;
    }
}
```

## File: src/SwapManager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import { Ownable, Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { IHolding } from "./interfaces/core/IHolding.sol";
import { IManager } from "./interfaces/core/IManager.sol";
import { IStablesManager } from "./interfaces/core/IStablesManager.sol";
import { ISwapManager } from "./interfaces/core/ISwapManager.sol";

/**
 * @title Swap Manager
 *
 * @notice This contract implements Uniswap's exact output multihop swap, for more information please refer to
 * https://docs.uniswap.org/contracts/v3/guides/swaps/multihop-swaps.
 *
 * @dev This contract inherits functionalities from `Ownable2Step`.
 *
 * @author Hovooo (@hovooo).
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract SwapManager is ISwapManager, Ownable2Step {
    using SafeERC20 for IERC20;

    /**
     * @notice Returns the address of the UniswapV3 Swap Router.
     */
    address public override swapRouter;

    /**
     * @notice Returns the address of the UniswapV3 Factory.
     */
    address public immutable override uniswapFactory;

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     */
    IManager public immutable override manager;

    /**
     * @notice Returns UniswapV3 pool initialization code hash used to deterministically compute the pool address.
     */
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    /**
     * @notice Creates a new SwapManager contract.
     *
     * @param _initialOwner The initial owner of the contract.
     * @param _uniswapFactory the address of the UniswapV3 Factory.
     * @param _swapRouter the address of the UniswapV3 Swap Router.
     * @param _manager contract that contains all the necessary configs of the protocol.
     */
    constructor(
        address _initialOwner,
        address _uniswapFactory,
        address _swapRouter,
        address _manager
    ) Ownable(_initialOwner) {
        require(_uniswapFactory != address(0), "3000");
        require(_swapRouter != address(0), "3000");
        require(_manager != address(0), "3000");

        uniswapFactory = _uniswapFactory;
        swapRouter = _swapRouter;
        manager = IManager(_manager);
    }

    // -- User specific methods --

    /**
     * @notice Swaps a minimum possible amount of `_tokenIn` for a fixed amount of `tokenOut` via `_swapPath`.
     *
     * @notice Requirements:
     * - The jUSD UniswapV3 Pool must be valid.
     * - The caller must be Liquidation Manager Contract.
     *
     * @notice Effects:
     * - Approves and transfers `tokenIn` from the `_userHolding`.
     * - Approves UniswapV3 Router to transfer `tokenIn` from address(this) to perform the `exactOutput` swap.
     * - Executes the `exactOutput` swap
     * - Handles any excess tokens.
     *
     * @param _tokenIn The address of the inbound asset.
     * @param _swapPath The optimal path for the multi-hop swap.
     * @param _userHolding The holding address associated with the user.
     * @param _deadline The timestamp representing the latest time by which the swap operation must be completed.
     * @param _amountOut The desired amount of `tokenOut`.
     * @param _amountInMaximum The maximum amount of `_tokenIn` to be swapped for the specified `_amountOut`.
     *
     * @return amountIn The amount of `_tokenIn` spent to receive the desired `amountOut` of `tokenOut`.
     */
    function swapExactOutputMultihop(
        address _tokenIn,
        bytes calldata _swapPath,
        address _userHolding,
        uint256 _deadline,
        uint256 _amountOut,
        uint256 _amountInMaximum
    ) external override validPool(_swapPath, _amountOut) returns (uint256 amountIn) {
        // Ensure the caller is Liquidation Manager Contract.
        require(msg.sender == manager.liquidationManager(), "1000");

        // Initialize tempData struct.
        SwapTempData memory tempData = SwapTempData({
            tokenIn: _tokenIn,
            swapPath: _swapPath,
            userHolding: _userHolding,
            deadline: _deadline,
            amountOut: _amountOut,
            amountInMaximum: _amountInMaximum,
            router: swapRouter
        });

        // Transfer the specified `amountInMaximum` to this contract.
        IHolding(tempData.userHolding).transfer(tempData.tokenIn, address(this), tempData.amountInMaximum);

        // Approve the Router to spend `amountInMaximum` from address(this).
        IERC20(tempData.tokenIn).forceApprove({ spender: tempData.router, value: tempData.amountInMaximum });

        // The parameter path is encoded as (tokenOut, fee, tokenIn/tokenOut, fee, tokenIn).
        ISwapRouter.ExactOutputParams memory params = ISwapRouter.ExactOutputParams({
            path: tempData.swapPath,
            recipient: tempData.userHolding,
            deadline: tempData.deadline,
            amountOut: tempData.amountOut,
            amountInMaximum: tempData.amountInMaximum
        });

        // Execute the swap, returning the amountIn actually spent.
        try ISwapRouter(tempData.router).exactOutput(params) returns (uint256 _amountIn) {
            amountIn = _amountIn;
        } catch {
            revert("3084");
        }

        // Emit event indicating successful exact output swap.
        emit exactOutputSwap({
            holding: tempData.userHolding,
            path: tempData.swapPath,
            amountIn: amountIn,
            amountOut: tempData.amountOut
        });

        // If the swap did not require the full amountInMaximum to achieve the exact amountOut make a refund.
        if (amountIn < tempData.amountInMaximum) {
            // Decrease allowance of the router.
            IERC20(tempData.tokenIn).forceApprove({ spender: address(tempData.router), value: 0 });
            // Make the refund.
            IERC20(tempData.tokenIn).safeTransfer(tempData.userHolding, tempData.amountInMaximum - amountIn);
        }
    }

    // -- Administration --

    /**
     * @notice Updates the Swap Router address.
     *
     * @notice Requirements:
     * - The new `_swapRouter` address must be valid and different from the current one.
     *
     * @notice Effects:
     * - Updates the `swapRouter` state variable.
     *
     * @notice Emits:
     * - `SwapRouterUpdated` event indicating successful swap router update operation.
     *
     * @param _swapRouter Swap Router's new address.
     */
    function setSwapRouter(
        address _swapRouter
    ) external override onlyOwner validAddress(_swapRouter) {
        require(swapRouter != _swapRouter, "3017");
        emit SwapRouterUpdated(swapRouter, _swapRouter);
        swapRouter = _swapRouter;
    }

    /**
     * @notice Override to avoid losing contract ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }

    // -- Private methods --

    /**
     * @notice Computes the pool address given the tokens of the pool and its fee.
     * @param tokenA The address of the first token of the UniswapV3 Pool.
     * @param tokenB The address of the second token of the UniswapV3 Pool.
     * @param fee The fee amount of the UniswapV3 Pool.
     */
    function _getPool(address tokenA, address tokenB, uint24 fee) private view returns (address) {
        // The address of the first token of the pool has to be smaller than the address of the second one.
        (tokenA, tokenB) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        // Compute the pool address.
        return address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff", uniswapFactory, keccak256(abi.encode(tokenA, tokenB, fee)), POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }

    // -- Modifiers --

    /**
     * @notice Validates that the address is not zero.
     * @param _address The address to validate.
     */
    modifier validAddress(
        address _address
    ) {
        require(_address != address(0), "3000");
        _;
    }

    /**
     * @notice Validates that jUSD UniswapV3 Pool is valid for the swap.
     *
     *   @notice Requirements:
     *  - `_path` must be of correct length.
     *  - jUSD UniswapV3 Pool specified in the `_path` has enough liquidity.
     */
    modifier validPool(bytes calldata _path, uint256 _amount) {
        // The shortest possible path is of 43 bytes, as an address takes 20 bytes and uint24 takes 3 bytes.
        require(_path.length >= 43, "3077");

        // Initialize tempData struct.
        ValidPoolTempData memory tempData = ValidPoolTempData({
            jUsd: IStablesManager(manager.stablesManager()).jUSD(),
            tokenA: address(bytes20(_path[0:20])),
            fee: uint24(bytes3(_path[20:23])),
            tokenB: address(bytes20(_path[23:43]))
        });

        // The first address in the path must be jUsd
        require(tempData.tokenA == address(tempData.jUsd), "3077");
        // There should be enough jUsd in the pool to perform self-liquidation.
        require(tempData.jUsd.balanceOf(_getPool(tempData.tokenA, tempData.tokenB, tempData.fee)) >= _amount, "3083");

        _;
    }
}
```

## File: src/interfaces/core/ILiquidationManager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IHoldingManager } from "./IHoldingManager.sol";
import { IManager } from "./IManager.sol";
import { IStablesManager } from "./IStablesManager.sol";
import { ISwapManager } from "./ISwapManager.sol";

/**
 * @title ILiquidationManager
 * @dev Interface for the LiquidationManager contract.
 */
interface ILiquidationManager {
    // -- Events --

    /**
     * @notice Emitted when self-liquidation occurs.
     * @param holding address involved in the self-liquidation.
     * @param token address of the collateral used for the self-liquidation.
     * @param amount of the `token` used for the self-liquidation.
     * @param collateralUsed amount used for the self-liquidation.
     */
    event SelfLiquidated(address indexed holding, address indexed token, uint256 amount, uint256 collateralUsed);

    /**
     * @notice Emitted when liquidation occurs.
     * @param holding address involved in the liquidation.
     * @param token address of the collateral used for the liquidation.
     * @param amount of the `token` used for the liquidation.
     * @param collateralUsed amount used for the liquidation.
     */
    event Liquidated(address indexed holding, address indexed token, uint256 amount, uint256 collateralUsed);

    /**
     * @notice Emitted when liquidation of bad debt occurs.
     * @param holding address involved in the liquidation of bad debt.
     * @param token address of the collateral used for the liquidation of bad debt.
     * @param amount of the `token` used for the liquidation of bad debt.
     * @param collateralUsed amount used for the liquidation of bad debt.
     */
    event BadDebtLiquidated(address indexed holding, address indexed token, uint256 amount, uint256 collateralUsed);

    /**
     * @notice Emitted when collateral is retrieved from a strategy.
     * @param token address retrieved as collateral.
     * @param holding address from which collateral is retrieved.
     * @param strategy address from which collateral is retrieved.
     * @param collateralRetrieved amount of collateral retrieved.
     */
    event CollateralRetrieved(
        address indexed token, address indexed holding, address indexed strategy, uint256 collateralRetrieved
    );

    /**
     * @notice Emitted when the self-liquidation fee is updated.
     * @param oldAmount The previous amount of the self-liquidation fee.
     * @param newAmount The new amount of the self-liquidation fee.
     */
    event SelfLiquidationFeeUpdated(uint256 oldAmount, uint256 newAmount);

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     * @return The manager contract.
     */
    function manager() external view returns (IManager);

    /**
     * @notice The max % amount the protocol gets when a self-liquidation operation happens.
     * @dev Uses 3 decimal precision, where 1% is represented as 1000.//@audit differences in precision
     * @dev 8% is the default self-liquidation fee.
     */
    function selfLiquidationFee() external view returns (uint256);

    /**
     * @notice The max % amount the protocol gets when a self-liquidation operation happens.
     * @dev Uses 3 decimal precision, where 1% is represented as 1000.
     * @dev 10% is the max self-liquidation fee.
     */
    function MAX_SELF_LIQUIDATION_FEE() external view returns (uint256);

    /**
     * @notice returns utility variable used for preciser computations
     */
    function LIQUIDATION_PRECISION() external view returns (uint256);

    // -- User specific methods --

    /**
     * @notice This function allows a user to self-liquidate by repaying their jUSD debt using their own collateral. The
     * function ensures the user is solvent, calculates the required collateral, handles collateral retrieval from
     * strategies if needed, and performs the necessary swaps and transfers.
     *
     * @notice Requirements:
     * - `msg.sender` must have holding.
     * - `msg.sender` must be solvent.
     * - There should be enough liquidity in jUSD pool.
     * - `_jUsdAmount` must be <= user's borrowed amount.
     *
     * @notice Effects:
     * - Retrieves collateral from specified strategies if needed.
     * - Swaps user's collateral to required `_jUsdAmount`.
     * - Sends fees to `feeAddress`.
     * - Repays user's debt in the amount of `jUsdAmountRepaid`.
     * - Removes used `collateralUsed` from `holding`.
     *
     * @notice Emits:
     * - `SelfLiquidated` event indicating self-liquidation.
     *
     * @param _collateral address of the token used as collateral for borrowing
     * @param _jUsdAmount to repay
     * @param _swapParams used for the swap operation: swap path, maximum input amount, and slippage percentage
     * @param _strategiesParams data for strategies to retrieve collateral from
     *
     * @return collateralUsed for self-liquidation
     * @return jUsdAmountRepaid amount repaid
     */
    function selfLiquidate(
        address _collateral,
        uint256 _jUsdAmount,
        SwapParamsCalldata calldata _swapParams,
        StrategiesParamsCalldata calldata _strategiesParams
    ) external returns (uint256 collateralUsed, uint256 jUsdAmountRepaid);

    /**
     * @notice Method used to liquidate stablecoin debt if a user is no longer solvent.
     *
     * @notice Requirements:
     * - `_user` must have holding.
     * - `_user` must be insolvent.
     * - `msg.sender` must have jUSD.
     * - `_jUsdAmount` must be <= user's borrowed amount
     *
     * @notice Effects:
     * - Retrieves collateral from specified strategies if needed.
     * - Sends the liquidator their bonus and underlying collateral.
     * - Repays user's debt in the amount of `_jUsdAmount`.
     * - Removes used `collateralUsed` from `holding`.
     *
     * @notice Emits:
     * - `Liquidated` event indicating liquidation.
     *
     * @param _user address whose holding is to be liquidated.
     * @param _collateral token used for borrowing.
     * @param _jUsdAmount to repay.
     * @param _minCollateralReceive amount of collateral the liquidator wants to get.
     * @param _data for strategies to retrieve collateral from in case the Holding balance is not enough.
     *
     * @return collateralUsed The amount of collateral used for liquidation.
     */
    function liquidate(
        address _user,
        address _collateral,
        uint256 _jUsdAmount,
        uint256 _minCollateralReceive,
        LiquidateCalldata calldata _data
    ) external returns (uint256 collateralUsed);

    /**
     * @notice Method used to liquidate positions with bad debt (where collateral value is less than borrowed amount).
     *
     * @notice Requirements:
     * - Only owner can call this function.
     * - `_user` must have holding.
     * - Holding must have bad debt (collateral value < borrowed amount).
     * - All strategies associated with the holding must be provided.
     *
     * @notice Effects:
     * - Retrieves collateral from specified strategies.
     * - Repays user's total debt with jUSD from msg.sender.
     * - Removes all remaining collateral from holding.
     * - Transfers all remaining collateral to msg.sender.
     *
     * @notice Emits:
     * - `CollateralRetrieved` event for each strategy collateral is retrieved from.
     *
     * @param _user Address whose holding is to be liquidated.
     * @param _collateral Token used for borrowing.
     * @param _data Struct containing arrays of strategies and their associated data for retrieving collateral.
     */
    function liquidateBadDebt(address _user, address _collateral, LiquidateCalldata calldata _data) external;

    // -- Administration --

    /**
     * @notice Sets a new value for the self-liquidation fee.
     * @dev The value must be less than MAX_SELF_LIQUIDATION_FEE.
     * @param _val The new value for the self-liquidation fee.
     */
    function setSelfLiquidationFee(
        uint256 _val
    ) external;

    /**
     * @notice Triggers stopped state.
     */
    function pause() external;

    /**
     * @notice Returns to normal state.
     */
    function unpause() external;

    // -- Structs --

    /**
     * @notice Temporary data structure used in the self-liquidation process.
     */
    struct SelfLiquidateTempData {
        IHoldingManager holdingManager; // Address of the Holding Manager contract
        IStablesManager stablesManager; // Address of the Stables Manager contract
        ISwapManager swapManager; // Address of the Swap Manager contract
        address holding; // Address of the user's Holding involved in self-liquidation
        bool isRegistryActive; // Flag indicating if the Registry is active
        address registryAddress; // Address of the Registry contract
        uint256 totalBorrowed; //  Total amount borrowed by user from the system
        uint256 totalAvailableCollateral; // Total available collateral in the Holding
        uint256 totalRequiredCollateral; // Total required collateral for self-liquidation
        uint256 totalSelfLiquidatableCollateral; // Total self-liquidatable collateral in the holding
        uint256 totalFeeCollateral; // Total fee collateral to be deducted
        uint256 jUsdAmountToBurn; // Amount of jUSD to burn during self-liquidation
        uint256 exchangeRate; // Current exchange rate.
        uint256 collateralInStrategies; // Total collateral locked in strategies
        bytes swapPath; // Path for token swapping
        uint256 deadline; // The latest time by which the swap operation must be completed.
        uint256 amountInMaximum; // Maximum amount to swap
        uint256 slippagePercentage; // Slippage percentage for token swapping
        bool useHoldingBalance; // Flag indicating whether to use Holding balance
        address[] strategies; // Array of strategy addresses
        bytes[] strategiesData; // Array of data associated with each strategy
    }

    /**
     * @notice Defines the necessary properties for self-liquidation for collateral swap.
     * @notice For optimal results, provide `_swapPath` and `_amountInMaximum` following the Uniswap Auto Router
     * guidelines. Refer to: https://blog.uniswap.org/auto-router.
     * @dev `_deadline` is a timestamp representing the latest time by which the swap operation must be completed.
     * @dev `slippagePercentage` represents the acceptable deviation percentage of `_amountInMaximum` from the
     * `totalSelfLiquidatableCollateral`.
     * @dev `slippagePercentage` is denominated in 5, where 100% is represented as 1e5.
     */
    struct SwapParamsCalldata {
        bytes swapPath;
        uint256 deadline;
        uint256 amountInMaximum;
        uint256 slippagePercentage;
    }

    /**
     * @notice Defines the necessary properties for self-liquidation using strategies, user has invested in.
     * @dev Set `useHoldingBalance` to true if user wishes to use holding's balance and strategies for self-liquidation.
     * `strategies` is an array of addresses of the strategies, in which the user has invested collateral in and wishes
     * to withdraw it from to perform a self-liquidation.
     * `strategiesData` is extra data used within each strategy to execute withdrawal
     */
    struct StrategiesParamsCalldata {
        bool useHoldingBalance;
        address[] strategies;
        bytes[] strategiesData;
    }

    /**
     * @notice Properties used for liquidation
     */
    struct LiquidateCalldata {
        address[] strategies;
        bytes[] strategiesData;
    }

    /**
     * @notice Properties used for collateral retrieval
     */
    struct CollateralRetrievalData {
        uint256 retrievedCollateral;
        uint256 shares;
        uint256 withdrawResult;
    }
}
```

## File: src/libraries/OperationsLib.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Operations Library
 * @notice A library containing common mathematical operations used throughout the protocol
 */
library OperationsLib {
    /**
     * @notice The denominator used for fee calculations (10,000 = 100%)
     * @dev Fees are expressed in basis points, where 1 basis point = 0.01%
     *      For example, 100 = 1%, 500 = 5%, 1000 = 10%
     */
    uint256 internal constant FEE_FACTOR = 10_000;

    /**
     * @notice Calculates the absolute fee amount based on the input amount and fee rate
     * @dev The calculation rounds up to ensure the protocol always collects the full fee
     * @param amount The base amount on which the fee is calculated
     * @param fee The fee rate in basis points (e.g., 100 = 1%)
     * @return The absolute fee amount, rounded up if there's any remainder
     */
    function getFeeAbsolute(uint256 amount, uint256 fee) internal pure returns (uint256) {
        // Calculate fee amount with rounding up to avoid precision loss
        return (amount * fee) / FEE_FACTOR + (amount * fee % FEE_FACTOR == 0 ? 0 : 1);
    }
}
```

## File: src/oracles/chronicle/interfaces/IChronicleOracle.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IOracle } from "../../../interfaces/oracle/IOracle.sol";

interface IChronicleOracle is IOracle {
    // -- Events --

    /**
     * @notice Emitted when a new Chronicle Oracle is created.
     *
     * @dev Tracks the underlying asset, its associated price ID, and the oracle's age.
     *
     * @param underlying The address of the underlying asset for which the oracle is created.
     * @param chronicle The address of the Chronicle Oracle.
     * @param ageValidityPeriod Age in seconds after which the price is considered invalid.
     */
    event ChronicleOracleCreated(address indexed underlying, address indexed chronicle, uint256 ageValidityPeriod);

    /**
     * @notice Emitted when the age for the price is updated.
     *
     * @dev Provides details about the previous and updated age values.
     *
     * @param oldValue The previous age value of the oracle.
     * @param newValue The updated age value of the oracle.
     */
    event AgeValidityPeriodUpdated(uint256 oldValue, uint256 newValue);

    /**
     * @notice Emitted when the age for the price is updated.
     *
     * @dev Provides details about the previous and updated age values.
     *
     * @param oldValue The previous age value of the oracle.
     * @param newValue The updated age value of the oracle.
     */
    event AgeValidityBufferUpdated(uint256 oldValue, uint256 newValue);

    // -- Errors --

    /**
     * @notice Thrown when Chronicle oracle returns a zero price.
     * @dev Zero prices are not valid for the standard token price feeds.
     */
    error ZeroPrice();

    /**
     * @notice Thrown when an invalid age value is provided.
     * @dev This error is used to signal that the age value does not meet the required constraints.
     */
    error InvalidAgeValidityPeriod();

    /**
     * @notice Thrown when an invalid age value is provided.
     * @dev This error is used to signal that the age value does not meet the required constraints.
     */
    error InvalidAgeValidityBuffer();

    /**
     * @notice Thrown when the price is outdated.
     * @dev This error is used to signal that the price is outdated.
     * @param minAllowedAge The minimum allowed age of the price based on the current timestamp.
     * @param actualAge The actual age of the price.
     */
    error OutdatedPrice(uint256 minAllowedAge, uint256 actualAge);

    // -- State variables --

    /**
     * @notice Returns the Chronicle Oracle address.
     * @return The address of the Chronicle Oracle.
     */
    function chronicle() external view returns (address);

    /**
     * @notice Returns the allowed age of the returned price in seconds.
     * @return The allowed age in seconds as a uint256 value.
     */
    function ageValidityPeriod() external view returns (uint256);

    /**
     * @notice Returns the buffer to account for the age of the price.
     * @return The buffer in seconds as a uint256 value.
     */
    function ageValidityBuffer() external view returns (uint256);

    // -- Initialization --

    /**
     * @notice Initializes the Oracle contract with necessary parameters.
     *
     * @param _initialOwner The address of the initial owner of the contract.
     * @param _underlying The address of the token the oracle is for.
     * @param _chronicle The Address of the Chronicle Oracle.
     * @param _ageValidityPeriod The Age in seconds after which the price is considered invalid.
     */
    function initialize(
        address _initialOwner,
        address _underlying,
        address _chronicle,
        uint256 _ageValidityPeriod
    ) external;

    // -- Administration --

    /**
     * @notice Updates the age validity period to a new value.
     * @dev Only the contract owner can call this function.
     * @param _newAgeValidityPeriod The new age validity period to be set.
     */
    function updateAgeValidityPeriod(
        uint256 _newAgeValidityPeriod
    ) external;

    /**
     * @notice Updates the age validity buffer to a new value.
     * @dev Only the contract owner can call this function.
     * @param _newAgeValidityBuffer The new age validity buffer to be set.
     */
    function updateAgeValidityBuffer(
        uint256 _newAgeValidityBuffer
    ) external;
}
```

## File: src/oracles/uniswap/GenericUniswapV3Oracle.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { OracleLibrary } from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

import { IOracle, IUniswapV3Oracle } from "./interfaces/IUniswapV3Oracle.sol";

/**
 * @title UniswapV3Oracle
 *
 * @notice Fetches and processes Uniswap V3 TWAP (Time-Weighted Average Price) data for a given token.
 *
 * @dev Implements IUniswapV3Oracle interface and uses UniswapV3 pools as price feed source.
 * @dev This contract inherits functionalities from `Ownable2Step`.
 *
 * @author Hovooo (@hovooo)
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract GenericUniswapV3Oracle is IUniswapV3Oracle, Ownable2Step {
    // -- State variables --

    /**
     * @notice Returns the address of the token the oracle is for.
     * @dev Is used as a `baseToken` for UniswapV3 TWAP.
     */
    address public override underlying;

    /**
     * @notice Amount of tokens used to determine underlying token's price.
     * @dev Should be equal to 1 * 10^(underlying token decimals) to always get the price for one underlying token.
     */
    uint128 public override baseAmount;

    /**
     * @notice Address of the ERC20 token used as the quote currency.
     */
    address public override quoteToken;

    /**
     * @notice Decimals of the ERC20 token used as the quote currency.
     */
    uint256 public override quoteTokenDecimals;

    /**
     * @notice The standard decimal precision (18) used for price normalization across the protocol.
     */
    uint256 private constant ALLOWED_DECIMALS = 18;

    /**
     * @notice Oracle used to convert price denominated in quote token to USD value
     */
    IOracle public override quoteTokenOracle;

    /**
     * @notice List of UniswapV3 pool addresses used for price calculations.
     */
    address[] private pools;

    // -- Constructor --

    /**
     * @notice Initializes key parameters.
     * @param _initialOwner Address of the contract owner.
     * @param _underlying Address of the underlying token contract.
     * @param _quoteToken Address of the quote token (USDC) contract.
     * @param _uniswapV3Pools Array of UniswapV3 pool addresses used for pricing.
     */
    constructor(
        address _initialOwner,
        address _underlying,
        address _quoteToken,
        address _quoteTokenOracle,
        address[] memory _uniswapV3Pools
    ) Ownable(_initialOwner) {
        if (_underlying == address(0)) revert InvalidAddress();
        if (_quoteToken == address(0)) revert InvalidAddress();

        // Initialize oracle configuration parameters
        baseAmount = uint128(10 ** IERC20Metadata(_underlying).decimals());
        underlying = _underlying;
        quoteToken = _quoteToken;
        quoteTokenDecimals = IERC20Metadata(_quoteToken).decimals();

        _updateQuoteTokenOracle(_quoteTokenOracle);
        _updatePools(_uniswapV3Pools);
    }

    // -- Getters --

    /**
     * @notice Check the last exchange rate without any state changes.
     * @return success If no valid (recent) rate is available, returns false else true.
     * @return rate The rate of the requested asset.
     */
    function peek(
        bytes calldata
    ) external view returns (bool success, uint256 rate) {
        // Query three different TWAPs (Time-Weighted Average Prices) from different time periods and take the median of
        // these prices to reduce the impact of sudden price fluctuations or manipulation.
        uint256 median = _getMedian(
            _quote({ _period: 1800, _offset: 3600 }), // Query the TWAP from the last 90-60 minutes (oldest time period)
            _quote({ _period: 1800, _offset: 1800 }), // Query the TWAP from the last 60-30 minutes (middle time period)
            _quote({ _period: 1800, _offset: 0 }) // Query the TWAP from the last 30-0 minutes (most recent time period)
        );

        // Normalize the price to ALLOWED_DECIMALS (e.g., 18 decimals)
        uint256 medianWithDecimals = quoteTokenDecimals == ALLOWED_DECIMALS
            ? median
            : quoteTokenDecimals < ALLOWED_DECIMALS
                ? median * 10 ** (ALLOWED_DECIMALS - quoteTokenDecimals)
                : median / 10 ** (quoteTokenDecimals - ALLOWED_DECIMALS);

        // As the median price is denominated in quote token, convert that price to USD value
        rate = _convertToUsd({ _price: medianWithDecimals });
        // If a valid price has been retrieved from the queries, return success as true
        success = true;
    }

    /**
     * @notice Returns a human readable name of the underlying of the oracle.
     */
    function name() external view override returns (string memory) {
        return IERC20Metadata(underlying).name();
    }

    /**
     * @notice Returns a human readable symbol of the underlying of the oracle.
     */
    function symbol() external view override returns (string memory) {
        return IERC20Metadata(underlying).symbol();
    }

    /**
     * @notice Returns the list of UniswapV3 pool addresses used for price calculations.
     * @return An array of UniswapV3 pool addresses stored in the contract.
     */
    function getPools() external view override returns (address[] memory) {
        return pools;
    }

    // -- Administration --

    /**
     * @notice Updates the UniswapV3 pools used for price calculations.
     * @dev Only callable by the contract owner.
     * @param _newPools The new list of UniswapV3 pool addresses.
     */
    function updatePools(
        address[] memory _newPools
    ) external onlyOwner {
        _updatePools(_newPools);
    }

    function updateQuoteTokenOracle(
        address _newOracle
    ) external onlyOwner {
        _updateQuoteTokenOracle(_newOracle);
    }

    /**
     * @dev Renounce ownership override to avoid losing contract's ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }

    // -- Utility functions --

    /**
     * @notice Fetches a time-weighted average price (TWAP) from Uniswap V3.
     * @param _period The length of the TWAP period in seconds.
     * @param _offset The offset (delay) for the TWAP calculation.
     */
    function _quote(uint32 _period, uint32 _offset) internal view returns (uint256) {
        uint256 length = pools.length;

        if (length == 0) revert NoDefinedPools();
        if (_offset > 0 && _period == 0) revert OffsettedSpotQuote();

        OracleLibrary.WeightedTickData[] memory _tickData = new OracleLibrary.WeightedTickData[](length);

        for (uint256 i; i < length; i++) {
            (_tickData[i].tick, _tickData[i].weight) = _period > 0
                ? consultOffsetted(pools[i], _period, _offset)
                : OracleLibrary.getBlockStartingTickAndLiquidity(pools[i]);
        }

        int24 _weightedTick =
            _tickData.length == 1 ? _tickData[0].tick : OracleLibrary.getWeightedArithmeticMeanTick(_tickData);

        return OracleLibrary.getQuoteAtTick(_weightedTick, baseAmount, underlying, quoteToken);
    }

    /**
     * @notice Calculates time-weighted means of tick and liquidity for a given Uniswap V3 pool.
     *
     * @param _pool Address of the pool that to observe.
     * @param _twapLength Length in seconds of the TWAP calculation length.
     * @param _offset Number of seconds ago to start the TWAP calculation.
     *
     * @return _arithmeticMeanTick The arithmetic mean tick from _secondsAgos[0] to _secondsAgos[1].
     * @return _harmonicMeanLiquidity The harmonic mean liquidity from _secondsAgos[0] to _secondsAgos[1].
     */
    function consultOffsetted(
        address _pool,
        uint32 _twapLength,
        uint32 _offset
    ) internal view returns (int24 _arithmeticMeanTick, uint128 _harmonicMeanLiquidity) {
        uint32[] memory _secondsAgos = new uint32[](2);
        _secondsAgos[0] = _twapLength + _offset;
        _secondsAgos[1] = _offset;

        (int56[] memory _tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) =
            IUniswapV3Pool(_pool).observe(_secondsAgos);

        int56 _tickCumulativesDelta = _tickCumulatives[1] - _tickCumulatives[0];
        uint160 _secondsPerLiquidityCumulativesDelta =
            secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0];

        _arithmeticMeanTick = int24(_tickCumulativesDelta / int56(int32(_twapLength)));

        // Always round to negative infinity
        if (_tickCumulativesDelta < 0 && (_tickCumulativesDelta % int56(int32((_twapLength))) != 0)) {
            _arithmeticMeanTick--;
        }

        // We are multiplying here instead of shifting to ensure that _harmonicMeanLiquidity doesn't overflow uint128
        uint192 _secondsAgoX160 = uint192(_twapLength) * type(uint160).max;
        _harmonicMeanLiquidity = uint128(_secondsAgoX160 / (uint192(_secondsPerLiquidityCumulativesDelta) << 32));
    }

    /**
     * @notice Computes a median value from three numbers.
     */
    function _getMedian(uint256 _a, uint256 _b, uint256 _c) internal pure returns (uint256) {
        if ((_a >= _b && _a <= _c) || (_a >= _c && _a <= _b)) return _a;
        if ((_b >= _a && _b <= _c) || (_b >= _c && _b <= _a)) return _b;
        return _c;
    }

    /**
     * @notice Converts a price denominated in quote token to its USD value.
     * @dev Uses the quote token's oracle to get the USD exchange rate.
     *
     * @notice Requirements:
     * - Oracle must provide an updated rate.
     * - Rate must be greater than zero.
     *
     * @param _price The price denominated in quote token to convert to USD.
     * @return The USD value of the given price.
     */
    function _convertToUsd(
        uint256 _price
    ) internal view returns (uint256) {
        // Query the quote token's oracle for its current USD exchange rate
        (bool updated, uint256 rate) = quoteTokenOracle.peek("");

        // Ensure the oracle provided an updated rate
        require(updated, "3037"); // ERR: FAILED

        // Ensure the rate is valid (greater than zero)
        require(rate > 0, "2100"); // ERR: INVALID MIN_AMOUNT

        // Convert the price denominated in quote token to USD value using quote token's USD oracle
        // Note: It's safe to use ALLOWED_DECIMALS as it's guaranteed that oracles implementing IOracle interface always
        // return prices with 18 decimals
        return _price * rate / 10 ** ALLOWED_DECIMALS;
    }

    /**
     * @notice Updates the oracle used for the quote token's USD price.
     * @dev This function is used to change the oracle that provides the USD exchange rate for the quote token.
     *
     * @notice Requirements:
     * - `_newOracle` must not be the zero address.
     * - `_newOracle` must be different from the current oracle address.
     *
     * @notice Effects:
     * - Updates the `quoteTokenOracle` state variable to the new oracle.
     *
     * @notice Emits:
     * - `QuoteTokenOracleUpdated` event indicating the change from old to new oracle.
     *
     * @param _newOracle The address of the new oracle to be used for the quote token.
     */
    function _updateQuoteTokenOracle(
        address _newOracle
    ) private {
        address oldOracle = address(quoteTokenOracle);

        if (_newOracle == address(0)) revert InvalidAddress();
        if (_newOracle == oldOracle) revert InvalidAddress();

        emit QuoteTokenOracleUpdated(oldOracle, _newOracle);
        quoteTokenOracle = IOracle(_newOracle);
    }

    /**
     * @notice Updates the UniswapV3 pools used for price calculations.
     * @param _newPools The new list of UniswapV3 pool addresses.
     */
    function _updatePools(
        address[] memory _newPools
    ) private {
        uint256 length = _newPools.length;

        // Ensure that the provided pool list is not empty
        if (length == 0) revert InvalidPoolsLength();

        // Compute hashes of the old and new pools to compare if they are identical
        bytes32 oldPoolsHash = keccak256(abi.encode(pools));
        bytes32 newPoolsHash = keccak256(abi.encode(_newPools));

        // Revert if the new pool list is the same as the existing one
        if (oldPoolsHash == newPoolsHash) revert InvalidPools();

        // Iterate through the new pool list to check for invalid addresses
        for (uint256 i = 0; i < length; i++) {
            if (_newPools[i] == address(0)) revert InvalidPools(); // Ensure no zero-address pools
        }

        // Emit an event to log the update of pools
        emit PoolsUpdated(oldPoolsHash, newPoolsHash);

        // Update the pools storage variable with the new pool list
        pools = _newPools;
    }
}
```

## File: src/JigsawUSD.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

import { IJigsawUSD } from "./interfaces/core/IJigsawUSD.sol";
import { IManager } from "./interfaces/core/IManager.sol";
import { IStablesManager } from "./interfaces/core/IStablesManager.sol";

/**
 * @title Jigsaw Stablecoin
 * @notice This contract implements a stablecoin named Jigsaw USD.
 *
 * @dev This contract inherits functionalities from `ERC20`, `Ownable2Step`, and `ERC20Permit`.
 *
 * It has additional features such as minting and burning, and specific roles for the owner and the Stables Manager.
 */
contract JigsawUSD is IJigsawUSD, ERC20, Ownable2Step, ERC20Permit {
    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     */
    IManager public immutable override manager;

    /**
     * @notice Returns the max mint limit.
     */
    uint256 public override mintLimit;

    /**
     * @notice Creates the JigsawUSD Contract.
     * @param _initialOwner The initial owner of the contract
     * @param _manager Contract that holds all the necessary configs of the protocol.
     */
    constructor(
        address _initialOwner,
        address _manager
    ) Ownable(_initialOwner) ERC20("Jigsaw USD", "jUSD") ERC20Permit("Jigsaw USD") {
        require(_manager != address(0), "3065"); 
        manager = IManager(_manager);
        mintLimit = 15e6 * (10 ** decimals()); // initial 15M limit //@audit 18 decimals stable?
    }

    // -- Owner specific methods --

    /**
     * @notice Sets the maximum mintable amount.
     *
     * @notice Requirements:
     * - Must be called by the contract owner.
     *
     * @notice Effects:
     * - Updates the `mintLimit` state variable.
     *
     * @notice Emits:
     * - `MintLimitUpdated` event indicating mint limit update operation.
     * @param _limit The new mint limit.
     */
    function updateMintLimit(
        uint256 _limit
    ) external override onlyOwner validAmount(_limit) {
        emit MintLimitUpdated(mintLimit, _limit);
        mintLimit = _limit;
    }

    // -- Write type methods --

    /**
     * @notice Mints tokens.
     *
     * @notice Requirements:
     * - Must be called by the Stables Manager Contract.
     *  .
     * @notice Effects:
     * - Mints the specified amount of tokens to the given address.
     *
     * @param _to Address of the user receiving minted tokens.
     * @param _amount The amount to be minted.
     */
    function mint(address _to, uint256 _amount) external override onlyStablesManager validAmount(_amount) {
        require(totalSupply() + _amount <= mintLimit, "2007");
        _mint(_to, _amount);
    }

    /**
     * @notice Burns tokens from the `msg.sender`.
     *
     * @notice Requirements:
     * - Must be called by the token holder.
     *
     * @notice Effects:
     * - Burns the specified amount of tokens from the caller's balance.
     *
     * @param _amount The amount of tokens to be burnt.
     */
    function burn(
        uint256 _amount
    ) external override validAmount(_amount) {
        _burn(msg.sender, _amount);
    }

    /**
     * @notice Burns tokens from an address.
     *
     * @notice Requirements:
     * - Must be called by the Stables Manager Contract
     *
     * @notice Effects:
     *   - Burns the specified amount of tokens from the specified address.
     *
     * @param _user The user to burn it from.
     * @param _amount The amount of tokens to be burnt.
     */
    function burnFrom(address _user, uint256 _amount) external override validAmount(_amount) onlyStablesManager {
        _burn(_user, _amount);
    }

    // -- Modifiers --

    /**
     * @notice Ensures that the value is greater than 0.
     */
    modifier validAmount(
        uint256 _val
    ) {
        require(_val > 0, "2001");
        _;
    }

    /**
     * @notice Ensures that the caller is the Stables Manager
     */
    modifier onlyStablesManager() {
        require(msg.sender == manager.stablesManager(), "1000");
        _;
    }
}
```

## File: src/interfaces/core/IHoldingManager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IManager } from "./IManager.sol";

/**
 * @title IHoldingManager
 * @notice Interface for the Holding Manager.
 */
interface IHoldingManager {
    // -- Custom types --

    /**
     * @notice Data used for multiple borrow.
     */
    struct BorrowData {
        address token;
        uint256 amount;
        uint256 minJUsdAmountOut;
    }

    /**
     * @notice Data used for multiple repay.
     */
    struct RepayData {
        address token;
        uint256 amount;
    }

    // -- Events --

    /**
     * @notice Emitted when a new Holding is created.
     * @param user The address of the user.
     * @param holdingAddress The address of the created holding.
     */
    event HoldingCreated(address indexed user, address indexed holdingAddress);

    /**
     * @notice Emitted when a deposit is made.
     * @param holding The address of the holding.
     * @param token The address of the token.
     * @param amount The amount deposited.
     */
    event Deposit(address indexed holding, address indexed token, uint256 amount);

    /**
     * @notice Emitted when a borrow action is performed.
     * @param holding The address of the holding.
     * @param token The address of the token.
     * @param jUsdMinted The amount of jUSD minted.
     * @param mintToUser Indicates if the amount is minted directly to the user.
     */
    event Borrowed(address indexed holding, address indexed token, uint256 jUsdMinted, bool mintToUser);

    /**
     * @notice Emitted when a borrow event happens using multiple collateral types.
     * @param holding The address of the holding.
     * @param length The number of borrow operations.
     * @param mintedToUser Indicates if the amounts are minted directly to the users.
     */
    event BorrowedMultiple(address indexed holding, uint256 length, bool mintedToUser);

    /**
     * @notice Emitted when a repay action is performed.
     * @param holding The address of the holding.
     * @param token The address of the token.
     * @param amount The amount repaid.
     * @param repayFromUser Indicates if the repayment is from the user's wallet.
     */
    event Repaid(address indexed holding, address indexed token, uint256 amount, bool repayFromUser);

    /**
     * @notice Emitted when a multiple repay operation happens.
     * @param holding The address of the holding.
     * @param length The number of repay operations.
     * @param repaidFromUser Indicates if the repayments are from the users' wallets.
     */
    event RepaidMultiple(address indexed holding, uint256 length, bool repaidFromUser);

    /**
     * @notice Emitted when the user wraps native coin.
     * @param user The address of the user.
     * @param amount The amount wrapped.
     */
    event NativeCoinWrapped(address user, uint256 amount);

    /**
     * @notice Emitted when the user unwraps into native coin.
     * @param user The address of the user.
     * @param amount The amount unwrapped.
     */
    event NativeCoinUnwrapped(address user, uint256 amount);

    /**
     * @notice Emitted when tokens are withdrawn from the holding.
     * @param holding The address of the holding.
     * @param token The address of the token.
     * @param totalAmount The total amount withdrawn.
     * @param feeAmount The fee amount.
     */
    event Withdrawal(address indexed holding, address indexed token, uint256 totalAmount, uint256 feeAmount);

    /**
     * @notice Emitted when the contract receives ETH.
     * @param from The address of the sender.
     * @param amount The amount received.
     */
    event Received(address indexed from, uint256 amount);

    // -- State variables --

    /**
     * @notice Returns the holding for a user.
     * @param _user The address of the user.
     * @return The address of the holding.
     */
    function userHolding(
        address _user
    ) external view returns (address);

    /**
     * @notice Returns the user for a holding.
     * @param holding The address of the holding.
     * @return The address of the user.
     */
    function holdingUser(
        address holding
    ) external view returns (address);

    /**
     * @notice Returns true if the holding was created.
     * @param _holding The address of the holding.
     * @return True if the holding was created, false otherwise.
     */
    function isHolding(
        address _holding
    ) external view returns (bool);

    /**
     * @notice Returns the address of the holding implementation to be cloned from.
     * @return The address of the current holding implementation.
     */
    function holdingImplementationReference() external view returns (address);

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     * @return The manager contract.
     */
    function manager() external view returns (IManager);

    /**
     * @notice Returns the address of the WETH contract to save on `manager.WETH()` calls.
     * @return The address of the WETH contract.
     */
    function WETH() external view returns (address);

    // -- User specific methods --

    /**
     * @notice Creates holding for the msg.sender.
     *
     * @notice Requirements:
     * - `msg.sender` must not have a holding within the protocol, as only one holding is allowed per address.
     * - Must be called from an EOA or whitelisted contract.
     *
     * @notice Effects:
     * - Clones `holdingImplementationReference`.
     * - Updates `userHolding` and `holdingUser` mappings with newly deployed `newHoldingAddress`.
     * - Initiates the `newHolding`.
     *
     * @notice Emits:
     * - `HoldingCreated` event indicating successful Holding creation.
     *
     * @return The address of the new holding.
     */
    function createHolding() external returns (address);

    /**
     * @notice Deposits a whitelisted token into the Holding.
     *
     * @notice Requirements:
     * - `_token` must be a whitelisted token.
     * - `_amount` must be greater than zero.
     * - `msg.sender` must have a valid holding.
     *
     * @param _token Token's address.
     * @param _amount Amount to deposit.
     */
    function deposit(address _token, uint256 _amount) external;

    /**
     * @notice Wraps native coin and deposits WETH into the holding.
     *
     * @dev This function must receive ETH in the transaction.
     *
     * @notice Requirements:
     *  - WETH must be whitelisted within protocol.
     * - `msg.sender` must have a valid holding.
     */
    function wrapAndDeposit() external payable;

    /**
     * @notice Withdraws a token from a Holding to a user.
     *
     * @notice Requirements:
     * - `_token` must be a valid address.
     * - `_amount` must be greater than zero.
     * - `msg.sender` must have a valid holding.
     *
     * @notice Effects:
     * - Withdraws the `_amount` of `_token` from the holding.
     * - Transfers the `_amount` of `_token` to `msg.sender`.
     * - Deducts any applicable fees.
     *
     * @param _token Token user wants to withdraw.
     * @param _amount Withdrawal amount.
     */
    function withdraw(address _token, uint256 _amount) external;

    /**
     * @notice Withdraws WETH from holding and unwraps it before sending it to the user.
     *
     * @notice Requirements:
     * - `_amount` must be greater than zero.
     * - `msg.sender` must have a valid holding.
     * - The low level native coin transfers must succeed.
     *
     * @notice Effects
     * - Transfers WETH from Holding address to address(this).
     * - Unwraps the WETH into native coin.
     * - Withdraws the `_amount` of WETH from the holding.
     * - Deducts any applicable fees.
     * - Transfers the unwrapped amount to `msg.sender`.
     *
     * @param _amount Withdrawal amount.
     */
    function withdrawAndUnwrap(
        uint256 _amount
    ) external;

    /**
     * @notice Borrows jUSD stablecoin to the user or to the holding contract.
     *
     * @dev The _amount does not account for the collateralization ratio and is meant to represent collateral's amount
     * equivalent to jUSD's value the user wants to receive.
     * @dev Ensure that the user will not become insolvent after borrowing before calling this function, as this
     * function will revert ("3009") if the supplied `_amount` does not adhere to the collateralization ratio set in
     * the registry for the specific collateral.
     *
     * @notice Requirements:
     * - `msg.sender` must have a valid holding.
     *
     * @notice Effects:
     * - Calls borrow function on `Stables Manager` Contract resulting in minting stablecoin based on the `_amount` of
     * `_token` collateral.
     *
     * @notice Emits:
     * - `Borrowed` event indicating successful borrow operation.
     *
     * @param _token Collateral token.
     * @param _amount The collateral amount equivalent for borrowed jUSD.
     * @param _mintDirectlyToUser If true, mints to user instead of holding.
     * @param _minJUsdAmountOut The minimum amount of jUSD that is expected to be received.
     *
     * @return jUsdMinted The amount of jUSD minted.
     */
    function borrow(
        address _token,
        uint256 _amount,
        uint256 _minJUsdAmountOut,
        bool _mintDirectlyToUser
    ) external returns (uint256 jUsdMinted);

    /**
     * @notice Borrows jUSD stablecoin to the user or to the holding contract using multiple collaterals.
     *
     * @dev This function will fail if any `amount` supplied in the `_data` does not adhere to the collateralization
     * ratio set in the registry for the specific collateral. For instance, if the collateralization ratio is 200%, the
     * maximum `_amount` that can be used to borrow is half of the user's free collateral, otherwise the user's holding
     * will become insolvent after borrowing.
     *
     * @notice Requirements:
     * - `msg.sender` must have a valid holding.
     * - `_data` must contain at least one entry.
     *
     * @notice Effects:
     * - Mints jUSD stablecoin for each entry in `_data` based on the collateral amounts.
     *
     * @notice Emits:
     * - `Borrowed` event for each entry indicating successful borrow operation.
     * - `BorrowedMultiple` event indicating successful multiple borrow operation.
     *
     * @param _data Struct containing data for each collateral type.
     * @param _mintDirectlyToUser If true, mints to user instead of holding.
     *
     * @return  The amount of jUSD minted for each collateral type.
     */
    function borrowMultiple(
        BorrowData[] calldata _data,
        bool _mintDirectlyToUser
    ) external returns (uint256[] memory);

    /**
     * @notice Repays jUSD stablecoin debt from the user's or to the holding's address and frees up the locked
     * collateral.
     *
     * @notice Requirements:
     * - `msg.sender` must have a valid holding.
     *
     * @notice Effects:
     * - Repays `_amount` jUSD stablecoin.
     *
     * @notice Emits:
     * - `Repaid` event indicating successful debt repayment operation.
     *
     * @param _token Collateral token.
     * @param _amount The repaid amount.
     * @param _repayFromUser If true, Stables Manager will burn jUSD from the msg.sender, otherwise user's holding.
     */
    function repay(address _token, uint256 _amount, bool _repayFromUser) external;

    /**
     * @notice Repays multiple jUSD stablecoin debts from the user's or to the holding's address and frees up the locked
     * collateral assets.
     *
     * @notice Requirements:
     * - `msg.sender` must have a valid holding.
     * - `_data` must contain at least one entry.
     *
     * @notice Effects:
     * - Repays stablecoin for each entry in `_data.
     *
     * @notice Emits:
     * - `Repaid` event indicating successful debt repayment operation.
     * - `RepaidMultiple` event indicating successful multiple repayment operation.
     *
     * @param _data Struct containing data for each collateral type.
     * @param _repayFromUser If true, it will burn from user's wallet, otherwise from user's holding.
     */
    function repayMultiple(RepayData[] calldata _data, bool _repayFromUser) external;

    // -- Administration --

    /**
     * @notice Triggers stopped state.
     */
    function pause() external;

    /**
     * @notice Returns to normal state.
     */
    function unpause() external;
}
```

## File: src/interfaces/core/IManager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IOracle } from "../oracle/IOracle.sol";

/**
 * @title IManager.
 * @dev Interface for the Manager Contract.
 */
interface IManager {
    // -- Events --

    /**
     * @notice Emitted when a new contract is whitelisted.
     * @param contractAddress The address of the contract that is whitelisted.
     */
    event ContractWhitelisted(address indexed contractAddress);

    /**
     * @notice Emitted when a contract is removed from the whitelist.
     * @param contractAddress The address of the contract that is removed from the whitelist.
     */
    event ContractBlacklisted(address indexed contractAddress);

    /**
     * @notice Emitted when a new token is whitelisted.
     * @param token The address of the token that is whitelisted.
     */
    event TokenWhitelisted(address indexed token);

    /**
     * @notice Emitted when a new token is removed from the whitelist.//@audit token has to be there to be removable
     * @param token The address of the token that is removed from the whitelist.
     */
    event TokenRemoved(address indexed token);

    /**
     * @notice Emitted when a withdrawable token is added.
     * @param token The address of the withdrawable token.
     */
    event WithdrawableTokenAdded(address indexed token);

    /**
     * @notice Emitted when a withdrawable token is removed.
     * @param token The address of the withdrawable token.
     */
    event WithdrawableTokenRemoved(address indexed token);

    /**
     * @notice Emitted when invoker is updated.
     * @param component The address of the invoker component.
     * @param allowed Boolean indicating if the invoker is allowed or not.
     */
    event InvokerUpdated(address indexed component, bool allowed);

    /**
     * @notice Emitted when the holding manager is set.
     * @param oldAddress The previous address of the holding manager.
     * @param newAddress The new address of the holding manager.
     */
    event HoldingManagerUpdated(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Emitted when a new liquidation manager is requested.
     * @param oldAddress The previous address of the liquidation manager.
     * @param newAddress The new address of the liquidation manager.
     */
    event NewLiquidationManagerRequested(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Emitted when the liquidation manager is set.
     * @param oldAddress The previous address of the liquidation manager.
     * @param newAddress The new address of the liquidation manager.
     */
    event LiquidationManagerUpdated(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Emitted when the stablecoin manager is set.
     * @param oldAddress The previous address of the stablecoin manager.
     * @param newAddress The new address of the stablecoin manager.
     */
    event StablecoinManagerUpdated(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Emitted when the strategy manager is set.
     * @param oldAddress The previous address of the strategy manager.
     * @param newAddress The new address of the strategy manager.
     */
    event StrategyManagerUpdated(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Emitted when a new swap manager is requested.
     * @param oldAddress The previous address of the swap manager.
     * @param newAddress The new address of the swap manager.
     */
    event NewSwapManagerRequested(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Emitted when the swap manager is set.
     * @param oldAddress The previous address of the swap manager.
     * @param newAddress The new address of the swap manager.
     */
    event SwapManagerUpdated(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Emitted when the default fee is updated.
     * @param oldFee The previous fee.
     * @param newFee The new fee.
     */
    event PerformanceFeeUpdated(uint256 indexed oldFee, uint256 indexed newFee);

    /**
     * @notice Emitted when the withdraw fee is updated.
     * @param oldFee The previous withdraw fee.
     * @param newFee The new withdraw fee.
     */
    event WithdrawalFeeUpdated(uint256 indexed oldFee, uint256 indexed newFee);

    /**
     * @notice Emitted when the liquidator's bonus is updated.
     * @param oldAmount The previous amount of the liquidator's bonus.
     * @param newAmount The new amount of the liquidator's bonus.
     */
    event LiquidatorBonusUpdated(uint256 oldAmount, uint256 newAmount);

    /**
     * @notice Emitted when the fee address is changed.
     * @param oldAddress The previous fee address.
     * @param newAddress The new fee address.
     */
    event FeeAddressUpdated(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Emitted when the receipt token factory is updated.
     * @param oldAddress The previous address of the receipt token factory.
     * @param newAddress The new address of the receipt token factory.
     */
    event ReceiptTokenFactoryUpdated(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Emitted when the liquidity gauge factory is updated.
     * @param oldAddress The previous address of the liquidity gauge factory.
     * @param newAddress The new address of the liquidity gauge factory.
     */
    event LiquidityGaugeFactoryUpdated(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Emitted when new oracle is requested.
     * @param newOracle The address of the new oracle.
     */
    event NewOracleRequested(address newOracle);

    /**
     * @notice Emitted when the oracle is updated.
     * @param oldOracle The address of the old oracle.
     * @param newOracle The address of the new oracle.
     */
    event OracleUpdated(address indexed oldOracle, address indexed newOracle);

    /**
     * @notice Emitted when oracle data is updated.
     * @param oldData The address of the old oracle data.
     * @param newData The address of the new oracle data.
     */
    event OracleDataUpdated(bytes indexed oldData, bytes indexed newData);

    /**
     * @notice Emitted when a new timelock amount is requested.
     * @param oldVal The previous timelock amount.
     * @param newVal The new timelock amount.
     */
    event TimelockAmountUpdateRequested(uint256 oldVal, uint256 newVal);

    /**
     * @notice Emitted when timelock amount is updated.
     * @param oldVal The previous timelock amount.
     * @param newVal The new timelock amount.
     */
    event TimelockAmountUpdated(uint256 oldVal, uint256 newVal);

    // -- Mappings --

    /**
     * @notice Returns true/false for contracts' whitelist status.
     * @param _contract The address of the contract.
     */
    function isContractWhitelisted(
        address _contract
    ) external view returns (bool);

    /**
     * @notice Returns true if token is whitelisted.
     * @param _token The address of the token.
     */
    function isTokenWhitelisted(
        address _token
    ) external view returns (bool);

    /**
     * @notice Returns true if the token can be withdrawn from a holding.
     * @param _token The address of the token.
     */
    function isTokenWithdrawable(
        address _token
    ) external view returns (bool);

    /**
     * @notice Returns true if caller is allowed invoker.
     * @param _invoker The address of the invoker.
     */
    function allowedInvokers(
        address _invoker
    ) external view returns (bool);

    // -- Essential tokens --

    /**
     * @notice WETH address.
     */
    function WETH() external view returns (address);

    // -- Protocol's stablecoin oracle config --

    /**
     * @notice Oracle contract associated with protocol's stablecoin.
     */
    function jUsdOracle() external view returns (IOracle);

    /**
     * @notice Extra oracle data if needed.
     */
    function oracleData() external view returns (bytes calldata);

    // -- Managers --

    /**
     * @notice Returns the address of the HoldingManager Contract.
     */
    function holdingManager() external view returns (address);

    /**
     * @notice Returns the address of the LiquidationManager Contract.
     */
    function liquidationManager() external view returns (address);

    /**
     * @notice Returns the address of the StablesManager Contract.
     */
    function stablesManager() external view returns (address);

    /**
     * @notice Returns the address of the StrategyManager Contract.
     */
    function strategyManager() external view returns (address);

    /**
     * @notice Returns the address of the SwapManager Contract.
     */
    function swapManager() external view returns (address);

    // -- Fees --

    /**
     * @notice Returns the default performance fee.
     * @dev Uses 2 decimal precision, where 1% is represented as 100.
     */
    function performanceFee() external view returns (uint256);

    /**
     * @notice Returns the maximum performance fee.
     * @dev Uses 2 decimal precision, where 1% is represented as 100.
     */
    function MAX_PERFORMANCE_FEE() external view returns (uint256);

    /**
     * @notice Fee for withdrawing from a holding.
     * @dev Uses 2 decimal precision, where 1% is represented as 100.
     */
    function withdrawalFee() external view returns (uint256);

    /**
     * @notice Returns the maximum withdrawal fee.
     * @dev Uses 2 decimal precision, where 1% is represented as 100.
     */
    function MAX_WITHDRAWAL_FEE() external view returns (uint256);

    /**
     * @notice Returns the fee address, where all the fees are collected.
     */
    function feeAddress() external view returns (address);

    // -- Factories --

    /**
     * @notice Returns the address of the ReceiptTokenFactory.
     */
    function receiptTokenFactory() external view returns (address);

    // -- Utility values --

    /**
     * @notice Minimum allowed jUSD debt amount for a holding to ensure successful liquidation.
     */
    function minDebtAmount() external view returns (uint256);

    /**
     * @notice Returns the collateral rate precision.
     * @dev Should be less than exchange rate precision due to optimization in math.
     */
    function PRECISION() external view returns (uint256);

    /**
     * @notice Returns the exchange rate precision.
     */
    function EXCHANGE_RATE_PRECISION() external view returns (uint256);

    /**
     * @notice Timelock amount in seconds for changing the oracle data.
     */
    function timelockAmount() external view returns (uint256);

    /**
     * @notice Returns the old timelock value for delayed timelock update.
     */
    function oldTimelock() external view returns (uint256);

    /**
     * @notice Returns the new timelock value for delayed timelock update.
     */
    function newTimelock() external view returns (uint256);

    /**
     * @notice Returns the timestamp when the new timelock was requested.
     */
    function newTimelockTimestamp() external view returns (uint256);

    /**
     * @notice Returns the new oracle address for delayed oracle update.
     */
    function newOracle() external view returns (address);

    /**
     * @notice Returns the timestamp when the new oracle was requested.
     */
    function newOracleTimestamp() external view returns (uint256);

    /**
     * @notice Returns the new swap manager address for delayed swap manager update.
     */
    function newSwapManager() external view returns (address);

    /**
     * @notice Returns the timestamp when the new swap manager was requested.
     */
    function newSwapManagerTimestamp() external view returns (uint256);

    /**
     * @notice Returns the new liquidation manager address for delayed liquidation manager update.
     */
    function newLiquidationManager() external view returns (address);

    /**
     * @notice Returns the timestamp when the new liquidation manager was requested.
     */
    function newLiquidationManagerTimestamp() external view returns (uint256);

    // -- Setters --

    /**
     * @notice Whitelists a contract.
     *
     * @notice Requirements:
     * - `_contract` must not be whitelisted.
     *
     * @notice Effects:
     * - Updates the `isContractWhitelisted` mapping.
     *
     * @notice Emits:
     * - `ContractWhitelisted` event indicating successful contract whitelist operation.
     *
     * @param _contract The address of the contract to be whitelisted.
     */
    function whitelistContract(
        address _contract
    ) external;

    /**
     * @notice Blacklists a contract.
     *
     * @notice Requirements:
     * - `_contract` must be whitelisted.
     *
     * @notice Effects:
     * - Updates the `isContractWhitelisted` mapping.
     *
     * @notice Emits:
     * - `ContractBlacklisted` event indicating successful contract blacklist operation.
     *
     * @param _contract The address of the contract to be blacklisted.
     */
    function blacklistContract(
        address _contract
    ) external;

    /**
     * @notice Whitelists a token.
     *
     * @notice Requirements:
     * - `_token` must not be whitelisted.
     *
     * @notice Effects:
     * - Updates the `isTokenWhitelisted` mapping.
     *
     * @notice Emits:
     * - `TokenWhitelisted` event indicating successful token whitelist operation.
     *
     * @param _token The address of the token to be whitelisted.
     */
    function whitelistToken(
        address _token
    ) external;

    /**
     * @notice Removes a token from whitelist.
     *
     * @notice Requirements:
     * - `_token` must be whitelisted.
     *
     * @notice Effects:
     * - Updates the `isTokenWhitelisted` mapping.
     *
     * @notice Emits:
     * - `TokenRemoved` event indicating successful token removal operation.
     *
     * @param _token The address of the token to be whitelisted.
     */
    function removeToken(
        address _token
    ) external;

    /**
     * @notice Registers the `_token` as withdrawable.
     *
     * @notice Requirements:
     * - `msg.sender` must be owner or `strategyManager`.
     * - `_token` must not be withdrawable.
     *
     * @notice Effects:
     * - Updates the `isTokenWithdrawable` mapping.
     *
     * @notice Emits:
     * - `WithdrawableTokenAdded` event indicating successful withdrawable token addition operation.
     *
     * @param _token The address of the token to be added as withdrawable.
     */
    function addWithdrawableToken(
        address _token
    ) external;

    /**
     * @notice Unregisters the `_token` as withdrawable.
     *
     * @notice Requirements:
     * - `_token` must be withdrawable.//@audit can be called by who?
     *
     * @notice Effects:
     * - Updates the `isTokenWithdrawable` mapping.
     *
     * @notice Emits:
     * - `WithdrawableTokenRemoved` event indicating successful withdrawable token removal operation.
     *
     * @param _token The address of the token to be removed as withdrawable.
     */
    function removeWithdrawableToken(
        address _token
    ) external;

    /**
     * @notice Sets invoker as allowed or forbidden.
     *
     * @notice Effects:
     * - Updates the `allowedInvokers` mapping.//@audit who calls it?
     *
     * @notice Emits:
     * - `InvokerUpdated` event indicating successful invoker update operation.
     *
     * @param _component Invoker's address.
     * @param _allowed True/false.
     */
    function updateInvoker(address _component, bool _allowed) external;

    /**
     * @notice Sets the Holding Manager Contract's address.
     *
     * @notice Requirements:
     * - `_val` must be different from previous `holdingManager` address.//@audit who calls it?
     *
     * @notice Effects:
     * - Updates the `holdingManager` state variable.
     *
     * @notice Emits:
     * - `HoldingManagerUpdated` event indicating the successful setting of the Holding Manager's address.
     *
     * @param _val The holding manager's address.
     */
    function setHoldingManager(
        address _val
    ) external;

    /**
     * @notice Sets the Liquidation Manager Contract's address.
     *
     * @notice Requirements:
     * - Can only be called once.
     * - `_val` must be non-zero address.
     *
     * @notice Effects:
     * - Updates the `liquidationManager` state variable.
     *
     * @notice Emits:
     * - `LiquidationManagerUpdated` event indicating the successful setting of the Liquidation Manager's address.
     *
     * @param _val The liquidation manager's address.
     */
    function setLiquidationManager(
        address _val
    ) external;

    /**
     * @notice Initiates the process to update the Liquidation Manager Contract's address.
     *
     * @notice Requirements:
     * - `_val` must be non-zero address.
     * - `_val` must be different from previous `liquidationManager` address.
     *
     * @notice Effects:
     * - Updates the the `_newLiquidationManager` state variable.
     * - Updates the the `_newLiquidationManagerTimestamp` state variable.
     *
     * @notice Emits:
     * - `LiquidationManagerUpdateRequested` event indicating successful liquidation manager change request.
     *
     * @param _val The new liquidation manager's address.
     */
    function requestNewLiquidationManager(
        address _val
    ) external;

    /**
     * @notice Sets the Liquidation Manager Contract's address.
     *
     * @notice Requirements:
     * - `_val` must be different from previous `liquidationManager` address.
     * - Timelock must expire.
     *
     * @notice Effects:
     * - Updates the `liquidationManager` state variable.
     * - Updates the the `_newLiquidationManager` state variable.
     * - Updates the the `_newLiquidationManagerTimestamp` state variable.//@audit discrepancies between request and accept timestamp
     *
     * @notice Emits:
     * - `LiquidationManagerUpdated` event indicating the successful setting of the Liquidation Manager's address.
     */
    function acceptNewLiquidationManager() external;

    /**
     * @notice Sets the Stablecoin Manager Contract's address.
     *
     * @notice Requirements:
     * - `_val` must be different from previous `stablesManager` address.
     *
     * @notice Effects:
     * - Updates the `stablesManager` state variable.
     *
     * @notice Emits:
     * - `StablecoinManagerUpdated` event indicating the successful setting of the Stablecoin Manager's address.
     *
     * @param _val The Stablecoin manager's address.
     */
    function setStablecoinManager(
        address _val
    ) external;

    /**
     * @notice Sets the Strategy Manager Contract's address.
     *
     * @notice Requirements:
     * - `_val` must be different from previous `strategyManager` address.
     *
     * @notice Effects:
     * - Updates the `strategyManager` state variable.
     *
     * @notice Emits:
     * - `StrategyManagerUpdated` event indicating the successful setting of the Strategy Manager's address.
     *
     * @param _val The Strategy manager's address.
     */
    function setStrategyManager(
        address _val
    ) external;

    /**
     * @notice Sets the Swap Manager Contract's address.
     *
     * @notice Requirements:
     * - Can only be called once.
     * - `_val` must be non-zero address.
     *
     * @notice Effects:
     * - Updates the `swapManager` state variable.
     *
     * @notice Emits:
     * - `SwapManagerUpdated` event indicating the successful setting of the Swap Manager's address.
     *
     * @param _val The Swap manager's address.
     */
    function setSwapManager(
        address _val
    ) external;

    /**
     * @notice Initiates the process to update the Swap Manager Contract's address.
     *
     * @notice Requirements:
     * - `_val` must be non-zero address.
     * - `_val` must be different from previous `swapManager` address.
     *
     * @notice Effects:
     * - Updates the the `_newSwapManager` state variable.
     * - Updates the the `_newSwapManagerTimestamp` state variable.
     *
     * @notice Emits:
     * - `NewSwapManagerRequested` event indicating successful swap manager change request.
     *
     * @param _val The new swap manager's address.
     */
    function requestNewSwapManager(
        address _val
    ) external;

    /**
     * @notice Updates the Swap Manager Contract    .
     *
     * @notice Requirements:
     * - Timelock must expire.
     *
     * @notice Effects:
     * - Updates the `swapManager` state variable.
     * - Resets `_newSwapManager` to address(0).
     * - Resets `_newSwapManagerTimestamp` to 0.
     *
     * @notice Emits:
     * - `SwapManagerUpdated` event indicating the successful setting of the Swap Manager's address.
     */
    function acceptNewSwapManager() external;

    /**
     * @notice Sets the performance fee.
     *
     * @notice Requirements:
     * - `_val` must be smaller than `FEE_FACTOR` to avoid wrong computations.
     *
     * @notice Effects:
     * - Updates the `performanceFee` state variable.
     *
     * @notice Emits:
     * - `PerformanceFeeUpdated` event indicating successful performance fee update operation.
     *
     * @dev `_val` uses 2 decimal precision, where 1% is represented as 100.
     *
     * @param _val The new performance fee value.
     */
    function setPerformanceFee(
        uint256 _val
    ) external;

    /**
     * @notice Sets the withdrawal fee.
     *
     * @notice Requirements:
     * - `_val` must be smaller than `FEE_FACTOR` to avoid wrong computations.
     *
     * @notice Effects:
     * - Updates the `withdrawalFee` state variable.
     *
     * @notice Emits:
     * - `WithdrawalFeeUpdated` event indicating successful withdrawal fee update operation.
     *
     * @dev `_val` uses 2 decimal precision, where 1% is represented as 100.
     *
     * @param _val The new withdrawal fee value.
     */
    function setWithdrawalFee(
        uint256 _val
    ) external;

    /**
     * @notice Sets the global fee address.
     *
     * @notice Requirements:
     * - `_val` must be different from previous `holdingManager` address.
     *
     * @notice Effects:
     * - Updates the `feeAddress` state variable.
     *
     * @notice Emits:
     * - `FeeAddressUpdated` event indicating successful setting of the global fee address.
     *
     * @param _val The new fee address.
     */
    function setFeeAddress(
        address _val
    ) external;

    /**
     * @notice Sets the receipt token factory's address.
     *
     * @notice Requirements:
     * - `_val` must be different from previous `receiptTokenFactory` address.
     *
     * @notice Effects:
     * - Updates the `receiptTokenFactory` state variable.
     *
     * @notice Emits:
     * - `ReceiptTokenFactoryUpdated` event indicating successful setting of the `receiptTokenFactory` address.
     *
     * @param _factory Receipt token factory's address.
     */
    function setReceiptTokenFactory(
        address _factory
    ) external;

    /**
     * @notice Registers jUSD's oracle change request.
     *
     * @notice Requirements:
     * - Contract must not be in active change.
     *
     * @notice Effects:
     * - Updates the the `_isActiveChange` state variable.
     * - Updates the the `_newOracle` state variable.
     * - Updates the the `_newOracleTimestamp` state variable.
     *
     * @notice Emits:
     * - `NewOracleRequested` event indicating successful jUSD's oracle change request.
     *
     * @param _oracle Liquidity gauge factory's address.
     */
    function requestNewJUsdOracle(
        address _oracle
    ) external;

    /**
     * @notice Updates jUSD's oracle.
     *
     * @notice Requirements:
     * - Contract must be in active change.
     * - Timelock must expire.
     *
     * @notice Effects:
     * - Updates the the `jUsdOracle` state variable.
     * - Updates the the `_isActiveChange` state variable.
     * - Updates the the `_newOracle` state variable.
     * - Updates the the `_newOracleTimestamp` state variable.
     *
     * @notice Emits:
     * - `OracleUpdated` event indicating successful jUSD's oracle change.
     */
    function acceptNewJUsdOracle() external;

    /**
     * @notice Updates the jUSD's oracle data.
     *
     * @notice Requirements:
     * - `_newOracleData` must be different from previous `oracleData`.
     *
     * @notice Effects:
     * - Updates the `oracleData` state variable.
     *
     * @notice Emits:
     * - `OracleDataUpdated` event indicating successful update of the oracle Data.
     *
     * @param _newOracleData New data used for jUSD's oracle data.
     */
    function setJUsdOracleData(
        bytes calldata _newOracleData
    ) external;

    /**
     * @notice Sets the minimum debt amount.
     *
     * @notice Requirements:
     * - `_minDebtAmount` must be greater than zero.
     * - `_minDebtAmount` must be different from previous `minDebtAmount`.
     *
     * @param _minDebtAmount The new minimum debt amount.
     */
    function setMinDebtAmount(
        uint256 _minDebtAmount
    ) external;

    /**
     * @notice Registers timelock change request.
     *
     * @notice Requirements:
     * - `_oldTimelock` must be set zero.
     * - `_newVal` must be greater than zero.
     *
     * @notice Effects:
     * - Updates the the `_oldTimelock` state variable.
     * - Updates the the `_newTimelock` state variable.
     * - Updates the the `_newTimelockTimestamp` state variable.
     *
     * @notice Emits:
     * - `TimelockAmountUpdateRequested` event indicating successful timelock change request.
     *
     * @param _newVal The new timelock value in seconds.
     */
    function requestNewTimelock(
        uint256 _newVal
    ) external;

    /**
     * @notice Updates the timelock amount.
     *
     * @notice Requirements:
     * - Contract must be in active change.
     * - `_newTimelock` must be greater than zero.
     * - The old timelock must expire.
     *
     * @notice Effects:
     * - Updates the the `timelockAmount` state variable.
     * - Updates the the `_oldTimelock` state variable.
     * - Updates the the `_newTimelock` state variable.
     * - Updates the the `_newTimelockTimestamp` state variable.
     *
     * @notice Emits:
     * - `TimelockAmountUpdated` event indicating successful timelock amount change.
     */
    function acceptNewTimelock() external;

    // -- Getters --

    /**
     * @notice Returns the up to date exchange rate of the protocol's stablecoin jUSD.
     *
     * @notice Requirements:
     * - Oracle must have updated rate.
     * - Rate must be a non zero positive value.
     *
     * @return The current exchange rate.
     */
    function getJUsdExchangeRate() external view returns (uint256);
}
```

## File: src/interfaces/core/IStablesManager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IJigsawUSD } from "../core/IJigsawUSD.sol";
import { ISharesRegistry } from "../core/ISharesRegistry.sol";
import { IManager } from "./IManager.sol";

/**
 * @title IStablesManager
 * @notice Interface for the Stables Manager.
 */
interface IStablesManager {
    // -- Custom types --

    /**
     * @notice Structure to store state and deployment address for a share registry
     */
    struct ShareRegistryInfo {
        bool active; // Flag indicating if the registry is active
        address deployedAt; // Address where the registry is deployed
    }

    /**
     * @notice Temporary struct used to store data during borrow operations to avoid stack too deep errors.
     * @dev This struct helps organize variables used in the borrow function.
     * @param registry The shares registry contract for the collateral token
     * @param exchangeRatePrecision The precision used for exchange rate calculations
     * @param amount The normalized amount (18 decimals) of collateral being borrowed against
     * @param amountValue The USD value of the collateral amount
     */
    struct BorrowTempData {
        ISharesRegistry registry;
        uint256 exchangeRatePrecision;
        uint256 amount;
        uint256 amountValue;
    }

    // -- Events --

    /**
     * @notice Emitted when collateral is registered.
     * @param holding The address of the holding.
     * @param token The address of the token.
     * @param amount The amount of collateral.
     */
    event AddedCollateral(address indexed holding, address indexed token, uint256 amount);

    /**
     * @notice Emitted when collateral is unregistered.
     * @param holding The address of the holding.
     * @param token The address of the token.
     * @param amount The amount of collateral.
     */
    event RemovedCollateral(address indexed holding, address indexed token, uint256 amount);

    /**
     * @notice Emitted when a borrow action is performed.
     * @param holding The address of the holding.
     * @param jUsdMinted The amount of jUSD minted.
     * @param mintToUser Boolean indicating if the amount is minted directly to the user.
     */
    event Borrowed(address indexed holding, uint256 jUsdMinted, bool mintToUser);

    /**
     * @notice Emitted when a repay action is performed.
     * @param holding The address of the holding.
     * @param amount The amount repaid.
     * @param burnFrom The address to burn from.
     */
    event Repaid(address indexed holding, uint256 amount, address indexed burnFrom);

    /**
     * @notice Emitted when a registry is added.
     * @param token The address of the token.
     * @param registry The address of the registry.
     */
    event RegistryAdded(address indexed token, address indexed registry);

    /**
     * @notice Emitted when a registry is updated.
     * @param token The address of the token.
     * @param registry The address of the registry.
     */
    event RegistryUpdated(address indexed token, address indexed registry);

    /**
     * @notice Returns total borrowed jUSD amount using `token`.
     * @param _token The address of the token.
     * @return The total borrowed amount.
     */
    function totalBorrowed(
        address _token
    ) external view returns (uint256);

    /**
     * @notice Returns config info for each token.
     * @param _token The address of the token to get registry info for.
     * @return Boolean indicating if the registry is active and the address of the registry.
     */
    function shareRegistryInfo(
        address _token
    ) external view returns (bool, address);

    /**
     * @notice Returns protocol's stablecoin address.
     * @return The address of the Jigsaw stablecoin.
     */
    function jUSD() external view returns (IJigsawUSD);

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     * @return The manager contract.
     */
    function manager() external view returns (IManager);

    // -- User specific methods --

    /**
     * @notice Registers new collateral.
     *
     * @dev The amount will be transformed to shares.
     *
     * @notice Requirements:
     * - The caller must be allowed to perform this action directly. If user - use Holding Manager Contract.
     * - The `_token` must be whitelisted.
     * - The `_token`'s registry must be active.
     *
     * @notice Effects:
     * - Adds collateral for the holding.
     *
     * @notice Emits:
     * - `AddedCollateral` event indicating successful collateral addition operation.
     *
     * @param _holding The holding for which collateral is added.
     * @param _token Collateral token.
     * @param _amount Amount of tokens to be added as collateral.
     */
    function addCollateral(address _holding, address _token, uint256 _amount) external;

    /**
     * @notice Unregisters collateral.
     *
     * @notice Requirements:
     * - The contract must not be paused.
     * - The caller must be allowed to perform this action directly. If user - use Holding Manager Contract.
     * - The token's registry must be active.
     * - `_holding` must stay solvent after collateral removal.
     *
     * @notice Effects:
     * - Removes collateral for the holding.
     *
     * @notice Emits:
     * - `RemovedCollateral` event indicating successful collateral removal operation.
     *
     * @param _holding The holding for which collateral is removed.
     * @param _token Collateral token.
     * @param _amount Amount of collateral.
     */
    function removeCollateral(address _holding, address _token, uint256 _amount) external;

    /**
     * @notice Unregisters collateral.
     *
     * @notice Requirements:
     * - The caller must be the LiquidationManager.
     * - The token's registry must be active.
     *
     * @notice Effects:
     * - Force removes collateral from the `_holding` in case of liquidation, without checking if user is solvent after
     * collateral removal.
     *
     * @notice Emits:
     * - `RemovedCollateral` event indicating successful collateral removal operation.
     *
     * @param _holding The holding for which collateral is added.
     * @param _token Collateral token.
     * @param _amount Amount of collateral.
     */
    function forceRemoveCollateral(address _holding, address _token, uint256 _amount) external;

    /**
     * @notice Mints stablecoin to the user.
     *
     * @notice Requirements:
     * - The caller must be allowed to perform this action directly. If user - use Holding Manager Contract.
     * - The token's registry must be active.
     * - `_amount` must be greater than zero.
     *
     * @notice Effects:
     * - Mints stablecoin based on the collateral amount.
     * - Updates the total borrowed jUSD amount for `_token`, used for borrowing.
     * - Updates `_holdings`'s borrowed amount in `token`'s registry contract.
     * - Ensures the holding remains solvent.
     *
     * @notice Emits:
     * - `Borrowed`.
     *
     * @param _holding The holding for which collateral is added.
     * @param _token Collateral token.
     * @param _amount The collateral amount equivalent for borrowed jUSD.
     * @param _minJUsdAmountOut The minimum amount of jUSD that is expected to be received.
     * @param _mintDirectlyToUser If true, mints to user instead of holding.
     *
     * @return jUsdMintAmount The amount of jUSD minted.
     */
    function borrow(
        address _holding,
        address _token,
        uint256 _amount,
        uint256 _minJUsdAmountOut,
        bool _mintDirectlyToUser
    ) external returns (uint256 jUsdMintAmount);

    /**
     * @notice Repays debt.
     *
     * @notice Requirements:
     * - The caller must be allowed to perform this action directly. If user - use Holding Manager Contract.
     * - The token's registry must be active.
     * - The holding must have a positive borrowed amount.
     * - `_amount` must not exceed `holding`'s borrowed amount.
     * - `_amount` must be greater than zero.
     * - `_burnFrom` must not be the zero address.
     *
     * @notice Effects:
     * - Updates the total borrowed jUSD amount for `_token`, used for borrowing.
     * - Updates `_holdings`'s borrowed amount in `token`'s registry contract.
     * - Burns `_amount` jUSD tokens from `_burnFrom` address
     *
     * @notice Emits:
     * - `Repaid` event indicating successful repay operation.
     *
     * @param _holding The holding for which repay is performed.
     * @param _token Collateral token.
     * @param _amount The repaid jUSD amount.
     * @param _burnFrom The address to burn from.
     */
    function repay(address _holding, address _token, uint256 _amount, address _burnFrom) external;

    // -- Administration --

    /**
     * @notice Triggers stopped state.
     */
    function pause() external;

    /**
     * @notice Returns to normal state.
     */
    function unpause() external;

    // -- Getters --

    /**
     * @notice Returns true if user is solvent for the specified token.
     *
     * @dev The method reverts if block.timestamp - _maxTimeRange > exchangeRateUpdatedAt.
     *
     * @notice Requirements:
     * - `_holding` must not be the zero address.
     * - There must be registry for `_token`.
     *
     * @param _token The token for which the check is done.
     * @param _holding The user address.
     *
     * @return flag indicating whether `holding` is solvent.
     */
    function isSolvent(address _token, address _holding) external view returns (bool);

    /**
     * @notice Checks if a holding can be liquidated for a specific token.
     *
     * @notice Requirements:
     * - `_holding` must not be the zero address.
     * - There must be registry for `_token`.
     *
     * @param _token The token for which the check is done.
     * @param _holding The user address.
     *
     * @return flag indicating whether `holding` is liquidatable.
     */
    function isLiquidatable(address _token, address _holding) external view returns (bool);

    /**
     * @notice Computes the solvency ratio.
     *
     * @dev Solvency ratio is calculated based on the used collateral type, its collateralization and exchange rates,
     * and `_holding`'s borrowed amount.
     *
     * @param _holding The holding address to check for.
     * @param registry The Shares Registry Contract for the token.
     * @param rate The rate to compute ratio for (either collateralization rate for `isSolvent` or liquidation
     * threshold for `isLiquidatable`).
     *
     * @return The calculated solvency ratio.
     */
    function getRatio(address _holding, ISharesRegistry registry, uint256 rate) external view returns (uint256);
}
```

## File: src/oracles/chronicle/ChronicleOracle.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IChronicleMinimal } from "./interfaces/IChronicleMinimal.sol";
import { IChronicleOracle } from "./interfaces/IChronicleOracle.sol";

/**
 * @title ChronicleOracle Contract
 *
 * @notice Oracle contract that fetches price data from Chronicle Oracle.
 *
 * @dev Implements IChronicleOracle interface and uses Chronicle Protocol as price feed source.
 * @dev This contract inherits functionalities from `Initializable` and `Ownable2StepUpgradeable`.
 *
 * @author Hovooo (@hovooo)
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract ChronicleOracle is IChronicleOracle, Initializable, Ownable2StepUpgradeable {
    // -- State variables --

    /**
     * @notice Address of the token the oracle is for.
     */
    address public override underlying;

    /**
     * @notice Chronicle Oracle address.
     */
    address public override chronicle;

    /**
     * @notice Allowed age of the returned price in seconds.
     */
    uint256 public override ageValidityPeriod;

    /**
     * @notice Buffer to account for the age of the price.
     * @dev This is used to ensure that the price is not considered outdated if it is within the buffer allowed for the
     * Chronicle protocol to update the price on-chain.
     */
    uint256 public override ageValidityBuffer;

    // -- Constructor --

    constructor() {
        _disableInitializers();
    }

    // -- Initialization --

    /**
     * @notice Initializes the Oracle contract with necessary parameters.
     *
     * @param _initialOwner The address of the initial owner of the contract.
     * @param _underlying The address of the token the oracle is for.
     * @param _chronicle The Address of the Chronicle Oracle.
     * @param _ageValidityPeriod The Age in seconds after which the price is considered invalid.
     */
    function initialize(
        address _initialOwner,
        address _underlying,
        address _chronicle,
        uint256 _ageValidityPeriod
    ) public initializer {
        __Ownable_init(_initialOwner);
        __Ownable2Step_init();

        // Emit the event before state changes to track oracle deployments and configurations
        emit ChronicleOracleCreated({
            underlying: _underlying,
            chronicle: _chronicle,
            ageValidityPeriod: _ageValidityPeriod
        });

        // Initialize oracle configuration parameters
        underlying = _underlying;
        chronicle = _chronicle;
        ageValidityPeriod = _ageValidityPeriod;
        ageValidityBuffer = 15 minutes;
    }

    // -- Administration --

    /**
     * @notice Updates the age validity period to a new value.
     * @dev Only the contract owner can call this function.
     * @param _newAgeValidityPeriod The new age validity period to be set.
     */
    function updateAgeValidityPeriod(
        uint256 _newAgeValidityPeriod
    ) external override onlyOwner {
        if (_newAgeValidityPeriod == 0) revert InvalidAgeValidityPeriod();
        if (_newAgeValidityPeriod == ageValidityPeriod) revert InvalidAgeValidityPeriod();

        // Emit the event before modifying the state to provide a reliable record of the oracle's age update operation.
        emit AgeValidityPeriodUpdated({ oldValue: ageValidityPeriod, newValue: _newAgeValidityPeriod });
        ageValidityPeriod = _newAgeValidityPeriod;
    }

    /**
     * @notice Updates the age validity buffer to a new value.
     * @dev Only the contract owner can call this function.
     * @param _newAgeValidityBuffer The new age validity buffer to be set.
     */
    function updateAgeValidityBuffer(
        uint256 _newAgeValidityBuffer
    ) external override onlyOwner {
        if (_newAgeValidityBuffer == 0) revert InvalidAgeValidityBuffer();
        if (_newAgeValidityBuffer == ageValidityBuffer) revert InvalidAgeValidityBuffer();

        // Emit the event before modifying the state to provide a reliable record of the oracle's age update operation.
        emit AgeValidityBufferUpdated({ oldValue: ageValidityBuffer, newValue: _newAgeValidityBuffer });
        ageValidityBuffer = _newAgeValidityBuffer;
    }

    // -- Getters --

    /**
     * @notice Fetches the latest exchange rate without causing any state changes.
     *
     * @dev The function attempts to retrieve the price from the Chronicle oracle.
     * @dev Ensures that the price does not violate constraints such as being zero or being too old.
     * @dev Any failure in fetching the price results in the function returning a failure status and a zero rate.
     *
     * @return success Indicates whether a valid (recent) rate was retrieved. Returns false if no valid rate available.
     * @return rate The normalized exchange rate of the requested asset pair, expressed with `ALLOWED_DECIMALS`.
     */
    function peek(
        bytes calldata
    ) external view returns (bool success, uint256 rate) {
        try IChronicleMinimal(chronicle).readWithAge() returns (uint256 value, uint256 age) {
            // Ensure the fetched price is not zero
            if (value == 0) revert ZeroPrice();

            // Ensure the price is not outdated
            uint256 minAllowedAge = block.timestamp - (ageValidityPeriod + ageValidityBuffer);
            if (age < minAllowedAge) revert OutdatedPrice({ minAllowedAge: minAllowedAge, actualAge: age });

            // Set success flag and return the price
            success = true;
            rate = value;
        } catch {
            // Handle any failure in fetching the price by returning false and a zero rate
            success = false;
            rate = 0;
        }
    }

    /**
     * @notice Returns a human readable name of the underlying of the oracle.
     */
    function name() external view override returns (string memory) {
        return IERC20Metadata(underlying).name();
    }

    /**
     * @notice Returns a human readable symbol of the underlying of the oracle.
     */
    function symbol() external view override returns (string memory) {
        return IERC20Metadata(underlying).symbol();
    }

    /**
     * @dev Renounce ownership override to avoid losing contract's ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }
}
```

## File: src/Holding.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { OperationsLib } from "./libraries/OperationsLib.sol";

import { IHolding } from "./interfaces/core/IHolding.sol";

import { IHoldingManager } from "./interfaces/core/IHoldingManager.sol";
import { IManager } from "./interfaces/core/IManager.sol";
import { IStrategyManagerMin } from "./interfaces/core/IStrategyManagerMin.sol";
/**
 * @title Holding Contract
 *
 * @notice This contract is designed to manage the holding of tokens and allow operations like transferring tokens,
 * approving spenders, making generic calls, and minting Jigsaw Tokens. It is intended to be cloned and initialized to
 * ensure unique instances with specific managers.
 *
 * @dev This contract inherits functionalities from `ReentrancyGuard` and `Initializable`.
 *
 * @author Hovooo (@hovooo), Cosmin Grigore (@gcosmintech).
 *
 * @custom:security-contact support@jigsaw.finance
 */

contract Holding is IHolding, Initializable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /**
     * @notice The address of the emergency invoker.
     */
    address public override emergencyInvoker;

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     */
    IManager public override manager;

    // --- Constructor ---

    /**
     * @dev To prevent the implementation contract from being used, the _disableInitializers function is invoked
     * in the constructor to automatically lock it when it is deployed.
     */
    constructor() {
        _disableInitializers();
    }

    // --- Initialization ---

    /**
     * @notice This function initializes the contract (instead of a constructor) to be cloned.
     *
     * @notice Requirements:
     * - The contract must not be already initialized.
     * - `_manager` must not be the zero address.
     *
     * @notice Effects:
     * - Sets `_initialized` to true.
     * - Sets `manager` to the provided `_manager` address.
     *
     * @param _manager Contract that holds all the necessary configs of the protocol.
     */
    function init(
        address _manager
    ) public initializer {
        require(_manager != address(0), "3065");
        manager = IManager(_manager);
    }

    // -- User specific methods --

    /**
     * @notice Sets the emergency invoker address for this holding.
     *
     * @notice Requirements:
     * - The caller must be the owner of this holding.
     *
     * @notice Effects:
     * - Updates the emergency invoker address to the provided value.
     * - Emits an event to track the change for off-chain monitoring.
     *
     * @param _emergencyInvoker The address to set as the emergency invoker.
     */
    function setEmergencyInvoker(
        address _emergencyInvoker
    ) external onlyUser {
        address oldInvoker = emergencyInvoker;
        emergencyInvoker = _emergencyInvoker;
        emit EmergencyInvokerSet(oldInvoker, _emergencyInvoker);
    }

    /**
     * @notice Approves an `_amount` of a specified token to be spent on behalf of the `msg.sender` by `_destination`.
     *
     * @notice Requirements:
     * - The caller must be allowed to make this call.
     *
     * @notice Effects:
     * - Safe approves the `_amount` of `_tokenAddress` to `_destination`.
     *
     * @param _tokenAddress Token user to be spent.
     * @param _destination Destination address of the approval.
     * @param _amount Withdrawal amount.
     */
    function approve(address _tokenAddress, address _destination, uint256 _amount) external override onlyAllowed {//@audit need to check the limit of onlyAllowed
        IERC20(_tokenAddress).forceApprove(_destination, _amount);//@audit can the force approve be removed in case strategy is compromised?
    }

    /**
     * @notice Transfers `_token` from the holding contract to `_to` address.
     *
     * @notice Requirements:
     * - The caller must be allowed.
     *
     * @notice Effects:
     * - Safe transfers `_amount` of `_token` to `_to`.
     *
     * @param _token Token address.
     * @param _to Address to move token to.
     * @param _amount Transfer amount.
     */
    function transfer(address _token, address _to, uint256 _amount) external override nonReentrant onlyAllowed {
        IERC20(_token).safeTransfer({ to: _to, value: _amount });
    }

    /**
     * @notice Executes generic call on the `contract`.
     *
     * @notice Requirements:
     * - The caller must be allowed.
     *
     * @notice Effects:
     * - Makes a low-level call to the `_contract` with the provided `_call` data.
     *
     * @param _contract The contract address for which the call will be invoked.
     * @param _call Abi.encodeWithSignature data for the call.
     *
     * @return success Indicates if the call was successful.
     * @return result The result returned by the call.
     */
    function genericCall(//@audit can ether sent be stuck in contract?
        address _contract,
        bytes calldata _call
    ) external payable override nonReentrant onlyAllowed returns (bool success, bytes memory result) {//@audit onlyAllowed?
        (success, result) = _contract.call{ value: msg.value }(_call);
    }

    /**
     * @notice Executes an emergency generic call on the specified contract.
     *
     * @notice Requirements:
     * - The caller must be the designated emergency invoker.
     * - The emergency invoker must be an allowed invoker in the Manager contract.
     * - Protected by nonReentrant modifier to prevent reentrancy attacks.
     *
     * @notice Effects:
     * - Makes a low-level call to the `_contract` with the provided `_call` data.
     * - Forwards any ETH value sent with the transaction.
     *
     * @param _contract The contract address for which the call will be invoked.
     * @param _call Abi.encodeWithSignature data for the call.
     *
     * @return success Indicates if the call was successful.
     * @return result The result returned by the call.
     */
    function emergencyGenericCall(
        address _contract,
        bytes calldata _call
    ) external payable onlyEmergencyInvoker nonReentrant returns (bool success, bytes memory result) {
        (success, result) = _contract.call{ value: msg.value }(_call);
    }

    // -- Modifiers

    modifier onlyAllowed() {//@audit what is going on here?
        (,, bool isStrategyWhitelisted) = IStrategyManagerMin(manager.strategyManager()).strategyInfo(msg.sender);

        require(
            msg.sender == manager.holdingManager() || msg.sender == manager.liquidationManager()
                || msg.sender == manager.swapManager() || isStrategyWhitelisted,
            "1000"
        );
        _;
    }

    modifier onlyUser() {
        require(msg.sender == IHoldingManager(manager.holdingManager()).holdingUser(address(this)), "1000");
        _;
    }

    modifier onlyEmergencyInvoker() {
        require(msg.sender == emergencyInvoker && manager.allowedInvokers(msg.sender), "1000");
        _;
    }
}
```

## File: src/SharesRegistry.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";// @audit not used?

import {IManager} from "./interfaces/core/IManager.sol";
import {ISharesRegistry} from "./interfaces/core/ISharesRegistry.sol";
import {IStablesManager} from "./interfaces/core/IStablesManager.sol";//@audit not used?
import {IOracle} from "./interfaces/oracle/IOracle.sol";

/**
 * @title SharesRegistry
 *
 * @notice Registers, manages and tracks assets used as collaterals within the Jigsaw Protocol.
 *
 * @author Hovooo (@hovooo), Cosmin Grigore (@gcosmintech).
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract SharesRegistry is ISharesRegistry, Ownable2Step {
    /**
     * @notice Returns the token address for which this registry was created.
     */
    address public immutable override token;

    /**
     * @notice Returns holding's borrowed amount.
     */
    mapping(address holding => uint256 amount) public override borrowed;

    /**
     * @notice Returns holding's available collateral amount.
     */
    mapping(address holding => uint256 amount) public override collateral;

    /**
     * @notice Contract that contains the address of the Manager Contract.
     */
    IManager public override manager;

    /**
     * @notice Configuration parameters for the registry.
     * @dev Stores collateralization rate, liquidation threshold, and liquidator bonus.
     */
    RegistryConfig private config;

    /**
     * @notice Minimal collateralization rate acceptable for registry to avoid computational errors.
     * @dev 20e3 means 20% LTV.
     */
    uint16 private immutable minCR = 20e3; //@audit wrong- not using 2 decimals?

    /**
     * @notice Maximum liquidation buffer acceptable for registry to avoid computational errors.
     * @dev 20e3 means 20% buffer.
     */
    uint16 private immutable maxLiquidationBuffer = 20e3; //@audit wrong- not using 2 decimals?

    /**
     * @notice Oracle contract associated with this share registry.
     */
    IOracle public override oracle;
    address private _newOracle;
    uint256 private _newOracleTimestamp;

    /**
     * @notice Extra oracle data if needed.
     */
    bytes public override oracleData;
    bytes private _newOracleData;
    uint256 private _newOracleDataTimestamp;

    /**
     * @notice Timelock amount in seconds for changing the oracle data.
     */
    uint256 public override timelockAmount = 1 hours;
    uint256 private _oldTimelock;
    uint256 private _newTimelock;
    uint256 private _newTimelockTimestamp;

    bool private _isOracleActiveChange = false;
    bool private _isOracleDataActiveChange = false;
    bool private _isTimelockActiveChange = false;

    /**
     * @notice Creates a SharesRegistry for a specific token.
     *
     * @param _initialOwner The initial owner of the contract.
     * @param _manager Contract that holds all the necessary configs of the protocol.
     * @param _token The address of the token contract, used as a collateral within this contract.
     * @param _oracle The oracle used to retrieve price data for the `_token`.
     * @param _oracleData Extra data for the oracle.
     * @param _config Configuration parameters for the registry.
     */
    constructor(
        address _initialOwner,
        address _manager,
        address _token,
        address _oracle,
        bytes memory _oracleData,
        RegistryConfig memory _config
    ) Ownable(_initialOwner) {
        require(_manager != address(0), "3065");
        require(_token != address(0), "3001");
        require(_oracle != address(0), "3034");

        token = _token;
        oracle = IOracle(_oracle);
        oracleData = _oracleData;
        manager = IManager(_manager);

        _updateConfig(_config);
    }

    // -- User specific methods --

    /**
     * @notice Updates `_holding`'s borrowed amount.
     *
     * @notice Requirements:
     * - `msg.sender` must be the Stables Manager Contract.
     * - `_newVal` must be greater than or equal to the minimum debt amount.
     *
     * @notice Effects:
     * - Updates `borrowed` mapping.
     *
     * @notice Emits:
     * - `BorrowedSet` indicating holding's borrowed amount update operation.
     *
     * @param _holding The address of the user's holding.
     * @param _newVal The new borrowed amount.
     */
    function setBorrowed(
        address _holding,
        uint256 _newVal
    ) external override onlyStableManager {
        // Ensure the `holding` holds allowed minimum jUSD debt amount
        require(_newVal == 0 || _newVal >= manager.minDebtAmount(), "3102");
        // Emit event indicating successful update
        emit BorrowedSet({
            _holding: _holding,
            oldVal: borrowed[_holding],
            newVal: _newVal
        });
        // Update the borrowed amount for the holding
        borrowed[_holding] = _newVal;//@audit can only be reset
    }

    /**
     * @notice Registers collateral for user's `_holding`.
     *
     * @notice Requirements:
     * - `msg.sender` must be the Stables Manager Contract.
     *
     * @notice Effects:
     * - Updates `collateral` mapping.
     *
     * @notice Emits:
     * - `CollateralAdded` event indicating collateral addition operation.
     *
     * @param _holding The address of the user's holding.
     * @param _share The new collateral shares.
     */
    function registerCollateral(
        address _holding,
        uint256 _share
    ) external override onlyStableManager {
        collateral[_holding] += _share;
        emit CollateralAdded({user: _holding, share: _share});
    }

    /**
     * @notice Registers a collateral removal operation for user's `_holding`.
     *
     * @notice Requirements:
     * - `msg.sender` must be the Stables Manager Contract.
     *
     * @notice Effects:
     * - Updates `collateral` mapping.
     *
     * @notice Emits:
     * - `CollateralRemoved` event indicating collateral removal operation.
     *
     * @param _holding The address of the user's holding.
     * @param _share The new collateral shares.
     */
    function unregisterCollateral(
        address _holding,
        uint256 _share
    ) external override onlyStableManager {
        if (_share > collateral[_holding]) {
            _share = collateral[_holding];
        }
        collateral[_holding] = collateral[_holding] - _share;
        emit CollateralRemoved(_holding, _share);
    }

    // -- Administration --

    /**
     * @notice Updates the registry configuration parameters.
     *
     * @notice Effects:
     * - Updates `config` state variable.
     *
     * @notice Emits:
     * - `ConfigUpdated` event indicating config update operation.
     *
     * @param _newConfig The new configuration parameters.
     */
    function updateConfig(
        RegistryConfig memory _newConfig
    ) external override onlyOwner {
        _updateConfig(_newConfig);
    }

    /**
     * @notice Requests a change for the oracle address.
     *
     * @notice Requirements:
     * - Previous oracle change request must have expired or been accepted.
     * - No timelock or oracle data change requests should be active.
     * - `_oracle` must not be the zero address.
     *
     * @notice Effects:
     * - Updates `_isOracleActiveChange` state variable.
     * - Updates `_newOracle` state variable.
     * - Updates `_newOracleTimestamp` state variable.
     *
     * @notice Emits:
     * - `NewOracleRequested` event indicating new oracle request.
     *
     * @param _oracle The new oracle address.
     */
    function requestNewOracle(address _oracle) external override onlyOwner {
        if (_newOracleTimestamp + timelockAmount > block.timestamp)
            require(!_isOracleActiveChange, "3093");
        require(!_isTimelockActiveChange, "3095");
        require(_oracle != address(0), "3000");

        _isOracleActiveChange = true;
        _newOracle = _oracle;
        _newOracleTimestamp = block.timestamp;
        emit NewOracleRequested(_oracle);
    }

    /**
     * @notice Updates the oracle.
     *
     * @notice Requirements:
     * - Oracle change must have been requested and the timelock must have passed.
     *
     * @notice Effects:
     * - Updates `oracle` state variable.
     * - Updates `_isOracleActiveChange` state variable.
     * - Updates `_newOracle` state variable.
     * - Updates `_newOracleTimestamp` state variable.
     *
     * @notice Emits:
     * - `OracleUpdated` event indicating oracle update.
     */
    function setOracle() external override onlyOwner {
        require(_isOracleActiveChange, "3094");
        require(
            _newOracleTimestamp + timelockAmount <= block.timestamp,
            "3066"
        );

        oracle = IOracle(_newOracle);
        _isOracleActiveChange = false;
        _newOracle = address(0);
        _newOracleTimestamp = 0;
        emit OracleUpdated();
    }

    /**
     * @notice Requests a change for oracle data.
     *
     * @notice Requirements:
     * - Previous oracle data change request must have expired or been accepted.
     * - No timelock or oracle change requests should be active.
     *
     * @notice Effects:
     * - Updates `_isOracleDataActiveChange` state variable.
     * - Updates `_newOracleData` state variable.
     * - Updates `_newOracleDataTimestamp` state variable.
     *
     * @notice Emits:
     * - `NewOracleDataRequested` event indicating new oracle data request.
     *
     * @param _data The new oracle data.
     */
    function requestNewOracleData(
        bytes calldata _data
    ) external override onlyOwner {
        if (_newOracleDataTimestamp + timelockAmount > block.timestamp)
            require(!_isOracleDataActiveChange, "3096");
        require(!_isTimelockActiveChange, "3095");

        _isOracleDataActiveChange = true;
        _newOracleData = _data;
        _newOracleDataTimestamp = block.timestamp;
        emit NewOracleDataRequested(_newOracleData);
    }

    /**
     * @notice Updates the oracle data.
     *
     * @notice Requirements:
     * - Oracle data change must have been requested and the timelock must have passed.
     *
     * @notice Effects:
     * - Updates `oracleData` state variable.
     * - Updates `_isOracleDataActiveChange` state variable.
     * - Updates `_newOracleData` state variable.
     * - Updates `_newOracleDataTimestamp` state variable.
     *
     * @notice Emits:
     * - `OracleDataUpdated` event indicating oracle data update.
     */
    function setOracleData() external override onlyOwner {
        require(_isOracleDataActiveChange, "3094");
        require(
            _newOracleDataTimestamp + timelockAmount <= block.timestamp,
            "3066"
        );

        oracleData = _newOracleData;
        _isOracleDataActiveChange = false;
        delete _newOracleData;
        _newOracleDataTimestamp = 0;
        emit OracleDataUpdated();
    }

    /**
     * @notice Requests a timelock update.
     *
     * @notice Requirements:
     * - `_newVal` must not be zero.
     * - Previous timelock change request must have expired or been accepted.
     * - No oracle or oracle data change requests should be active.
     *
     * @notice Effects:
     * - Updates `_isTimelockActiveChange` state variable.
     * - Updates `_oldTimelock` state variable.
     * - Updates `_newTimelock` state variable.
     * - Updates `_newTimelockTimestamp` state variable.
     *
     * @notice Emits:
     * - `TimelockAmountUpdateRequested` event indicating timelock change request.
     *
     * @param _newVal The new value in seconds.
     */
    function requestTimelockAmountChange(
        uint256 _newVal
    ) external override onlyOwner {
        if (_newTimelockTimestamp + _oldTimelock > block.timestamp)
            require(!_isTimelockActiveChange, "3095");
        require(!_isOracleActiveChange, "3093");
        require(!_isOracleDataActiveChange, "3096");
        require(_newVal != 0, "2001");

        _isTimelockActiveChange = true;
        _oldTimelock = timelockAmount;
        _newTimelock = _newVal;
        _newTimelockTimestamp = block.timestamp;
        emit TimelockAmountUpdateRequested(_oldTimelock, _newTimelock);
    }

    /**
     * @notice Updates the timelock amount.
     *
     * @notice Requirements:
     * - Timelock change must have been requested and the timelock must have passed.
     * - The timelock for timelock change must have already expired.
     *
     * @notice Effects:
     * - Updates `timelockAmount` state variable.
     * - Updates `_oldTimelock` state variable.
     * - Updates `_newTimelock` state variable.
     * - Updates `_newTimelockTimestamp` state variable.
     *
     * @notice Emits:
     * - `TimelockAmountUpdated` event indicating timelock amount change operation.
     */
    function acceptTimelockAmountChange() external override onlyOwner {
        require(_isTimelockActiveChange, "3094");
        require(
            _newTimelockTimestamp + _oldTimelock <= block.timestamp,
            "3066"
        );

        timelockAmount = _newTimelock;
        emit TimelockAmountUpdated(_oldTimelock, _newTimelock);
        _oldTimelock = 0;
        _newTimelock = 0;
        _newTimelockTimestamp = 0;

        _isTimelockActiveChange = false;
    }

    // -- Getters --

    /**
     * @notice Returns the up to date exchange rate of the `token`.
     *
     * @notice Requirements:
     * - Oracle must provide an updated rate.
     *
     * @return The updated exchange rate.
     */
    function getExchangeRate() external view override returns (uint256) {
        (bool updated, uint256 rate) = oracle.peek(oracleData);
        require(updated, "3037");
        require(rate > 0, "2100");

        return rate;
    }

    /**
     * @notice Returns the configuration parameters for the registry.
     * @return The RegistryConfig struct containing the parameters.
     */
    function getConfig()
        external
        view
        override
        returns (RegistryConfig memory)
    {
        return config;
    }

    // -- Private methods --

    /**
     * @notice Updates the configuration parameters for the registry.
     * @param _config The new configuration parameters.
     */
    function _updateConfig(RegistryConfig memory _config) private {
        uint256 precision = manager.PRECISION(); //@audit uses three decimals?

        require(
            _config.collateralizationRate >= minCR &&
                _config.collateralizationRate <= precision,
            "3066"
        );
        require(_config.liquidationBuffer <= maxLiquidationBuffer, "3100");

        uint256 maxLiquidatorBonus = precision -
            _config.collateralizationRate -
            _config.liquidationBuffer;
        require(_config.liquidatorBonus <= maxLiquidatorBonus, "3101");

        emit ConfigUpdated(token, config, _config);
        config = _config;
    }

    // -- Modifiers --

    /**
     * @notice Modifier to only allow access to a function by the Stables Manager Contract.
     */
    modifier onlyStableManager() {
        require(msg.sender == manager.stablesManager(), "1000");
        _;
    }
}
```

## File: src/HoldingManager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { Holding } from "./Holding.sol";
import { OperationsLib } from "./libraries/OperationsLib.sol";

import { IWETH } from "./interfaces/IWETH.sol";
import { IHolding } from "./interfaces/core/IHolding.sol";
import { IHoldingManager } from "./interfaces/core/IHoldingManager.sol";
import { IManager } from "./interfaces/core/IManager.sol";

import { ISharesRegistry } from "./interfaces/core/ISharesRegistry.sol";
import { IStablesManager } from "./interfaces/core/IStablesManager.sol";

/**
 * @title HoldingManager
 *
 * @notice Manages holding creation, management, and interaction for a more secure and dynamic flow.
 *
 * @dev This contract inherits functionalities from `Ownable2Step`, `Pausable`, and `ReentrancyGuard`.
 *
 * @author Hovooo (@hovooo), Cosmin Grigore (@gcosmintech).
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract HoldingManager is IHoldingManager, Ownable2Step, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /**
     * @notice Returns holding address associated with the user.
     */
    mapping(address user => address holding) public override userHolding;

    /**
     * @notice Returns user address associated with the holding.
     */
    mapping(address holding => address user) public override holdingUser;

    /**
     * @notice Returns true if provided address is a holding within protocol.
     */
    mapping(address holding => bool exists) public override isHolding;

    /**
     * @notice Returns the address of the holding implementation to be cloned from.
     */
    address public immutable override holdingImplementationReference;

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     */
    IManager public immutable override manager;

    /**
     * @notice Returns the address of the WETH contract to save on `manager.WETH()` calls.
     */
    address public immutable override WETH;

    /**
     * @notice Creates a new HoldingManager Contract.
     * @param _initialOwner The initial owner of the contract
     * @param _manager Contract that holds all the necessary configs of the protocol.
     */
    constructor(address _initialOwner, address _manager) Ownable(_initialOwner) {
        require(_manager != address(0), "3065");
        manager = IManager(_manager);
        holdingImplementationReference = address(new Holding());
        WETH = manager.WETH();
    }

    // -- User specific methods --

    /**
     * @notice Creates holding for the msg.sender.
     *
     * @notice Requirements:
     * - `msg.sender` must not have a holding within the protocol, as only one holding is allowed per address.
     * - Must be called from an EOA or whitelisted contract.
     *
     * @notice Effects:
     * - Clones `holdingImplementationReference`.
     * - Updates `userHolding` and `holdingUser` mappings with newly deployed `newHoldingAddress`.
     * - Initiates the `newHolding`.
     *
     * @notice Emits:
     * - `HoldingCreated` event indicating successful Holding creation.
     *
     * @return The address of the new holding.
     */
    function createHolding() external override nonReentrant whenNotPaused returns (address) {
        require(userHolding[msg.sender] == address(0), "1101");

        if (msg.sender != tx.origin) {//@audit issue?
            require(manager.isContractWhitelisted(msg.sender), "1000");
        }

        // Instead of deploying the contract, it is cloned to save on gas.
        address newHoldingAddress = Clones.clone(holdingImplementationReference);//@audit does this clone the state of implementation?
        emit HoldingCreated({ user: msg.sender, holdingAddress: newHoldingAddress });

        isHolding[newHoldingAddress] = true;
        userHolding[msg.sender] = newHoldingAddress;
        holdingUser[newHoldingAddress] = msg.sender;

        Holding newHolding = Holding(newHoldingAddress);
        newHolding.init(address(manager));

        return newHoldingAddress;
    }

    /**
     * @notice Deposits a whitelisted token into the Holding.
     *
     * @notice Requirements:
     * - `_token` must be a whitelisted token.
     * - `_amount` must be greater than zero.
     * - `msg.sender` must have a valid holding.
     *
     * @param _token Token's address.
     * @param _amount Amount to deposit.
     */
    function deposit(
        address _token,
        uint256 _amount
    )
        external
        override
        validToken(_token)
        validAmount(_amount)
        validHolding(userHolding[msg.sender])
        nonReentrant
        whenNotPaused
    {
        _deposit({ _from: msg.sender, _token: _token, _amount: _amount });
    }

    /**
     * @notice Wraps native coin and deposits WETH into the holding.
     *
     * @dev This function must receive ETH in the transaction.
     *
     * @notice Requirements:
     *  - WETH must be whitelisted within protocol.
     * - `msg.sender` must have a valid holding.
     */
    function wrapAndDeposit()
        external
        payable
        override
        validToken(WETH)
        validHolding(userHolding[msg.sender])
        nonReentrant
        whenNotPaused
    {
        _wrap();
        _deposit({ _from: address(this), _token: WETH, _amount: msg.value });//@audit are we assuming here?
    }

    /**
     * @notice Withdraws a token from a Holding to a user.
     *
     * @notice Requirements:
     * - `_token` must be a valid address.
     * - `_amount` must be greater than zero.
     * - `msg.sender` must have a valid holding.
     *
     * @notice Effects:
     * - Withdraws the `_amount` of `_token` from the holding.
     * - Transfers the `_amount` of `_token` to `msg.sender`.
     * - Deducts any applicable fees.
     *
     * @param _token Token user wants to withdraw.
     * @param _amount Withdrawal amount.
     */
    function withdraw(
        address _token,
        uint256 _amount
    )
        external
        override
        validAddress(_token)//@audit just checking address,not if token is valid?
        validAmount(_amount)
        validHolding(userHolding[msg.sender])
        nonReentrant
        whenNotPaused
    {
        IHolding holding = IHolding(userHolding[msg.sender]);
        (uint256 userAmount, uint256 feeAmount) = _withdraw({ _token: _token, _amount: _amount });

        // Transfer the fee amount to the fee address.
        if (feeAmount > 0) {
            holding.transfer({ _token: _token, _to: manager.feeAddress(), _amount: feeAmount });
        }

        // Transfer the remaining amount to the user.
        holding.transfer({ _token: _token, _to: msg.sender, _amount: userAmount });
    }

    /**
     * @notice Withdraws WETH from holding and unwraps it before sending it to the user.
     *
     * @notice Requirements:
     * - `_amount` must be greater than zero.
     * - `msg.sender` must have a valid holding.
     * - The low level native coin transfers must succeed.
     *
     * @notice Effects
     * - Transfers WETH from Holding address to address(this).
     * - Unwraps the WETH into native coin.
     * - Withdraws the `_amount` of WETH from the holding.
     * - Deducts any applicable fees.
     * - Transfers the unwrapped amount to `msg.sender`.
     *
     * @param _amount Withdrawal amount.
     */
    function withdrawAndUnwrap(
        uint256 _amount
    ) external override validAmount(_amount) validHolding(userHolding[msg.sender]) nonReentrant whenNotPaused {
        IHolding(userHolding[msg.sender]).transfer({ _token: WETH, _to: address(this), _amount: _amount });
        _unwrap(_amount);//@audit why are we unwrapping here?
        (uint256 userAmount, uint256 feeAmount) = _withdraw({ _token: WETH, _amount: _amount });

        if (feeAmount > 0) {
            (bool feeSuccess,) = payable(manager.feeAddress()).call{ value: feeAmount }("");
            require(feeSuccess, "3016");
        }

        (bool success,) = payable(msg.sender).call{ value: userAmount }("");
        require(success, "3016");
    }

    /**
     * @notice Borrows jUSD stablecoin to the user or to the holding contract.
     *
     * @dev The _amount does not account for the collateralization ratio and is meant to represent collateral's amount
     * equivalent to jUSD's value the user wants to receive.
     * @dev Ensure that the user will not become insolvent after borrowing before calling this function, as this
     * function will revert ("3009") if the supplied `_amount` does not adhere to the collateralization ratio set in
     * the registry for the specific collateral.
     *
     * @notice Requirements:
     * - `msg.sender` must have a valid holding.
     *
     * @notice Effects:
     * - Calls borrow function on `Stables Manager` Contract resulting in minting stablecoin based on the `_amount` of
     * `_token` collateral.
     *
     * @notice Emits:
     * - `Borrowed` event indicating successful borrow operation.
     *
     * @param _token Collateral token.
     * @param _amount The collateral amount equivalent for borrowed jUSD.
     * @param _mintDirectlyToUser If true, mints to user instead of holding.
     * @param _minJUsdAmountOut The minimum amount of jUSD that is expected to be received.
     *
     * @return jUsdMinted The amount of jUSD minted.
     */
    function borrow(
        address _token,
        uint256 _amount,
        uint256 _minJUsdAmountOut,
        bool _mintDirectlyToUser
    ) external override nonReentrant whenNotPaused validHolding(userHolding[msg.sender]) returns (uint256 jUsdMinted) {
        address holding = userHolding[msg.sender];//@audit validate token and amount?

        jUsdMinted = _getStablesManager().borrow({
            _holding: holding,
            _token: _token,
            _amount: _amount,
            _minJUsdAmountOut: _minJUsdAmountOut,
            _mintDirectlyToUser: _mintDirectlyToUser
        });//@audit who takes collateral from the user?

        emit Borrowed({ holding: holding, token: _token, jUsdMinted: jUsdMinted, mintToUser: _mintDirectlyToUser });
    }

    /**
     * @notice Borrows jUSD stablecoin to the user or to the holding contract using multiple collaterals.
     *
     * @dev This function will fail if any `amount` supplied in the `_data` does not adhere to the collateralization
     * ratio set in the registry for the specific collateral. For instance, if the collateralization ratio is 200%, the
     * maximum `_amount` that can be used to borrow is half of the user's free collateral, otherwise the user's holding
     * will become insolvent after borrowing.
     *
     * @notice Requirements:
     * - `msg.sender` must have a valid holding.
     * - `_data` must contain at least one entry.
     *
     * @notice Effects:
     * - Mints jUSD stablecoin for each entry in `_data` based on the collateral amounts.
     *
     * @notice Emits:
     * - `Borrowed` event for each entry indicating successful borrow operation.
     * - `BorrowedMultiple` event indicating successful multiple borrow operation.
     *
     * @param _data Struct containing data for each collateral type.
     * @param _mintDirectlyToUser If true, mints to user instead of holding.
     *
     * @return  The amount of jUSD minted for each collateral type.
     */
    function borrowMultiple(
        BorrowData[] calldata _data,
        bool _mintDirectlyToUser
    ) external override validHolding(userHolding[msg.sender]) nonReentrant whenNotPaused returns (uint256[] memory) {
        require(_data.length > 0, "3006");

        address holding = userHolding[msg.sender];

        uint256[] memory jUsdMintedAmounts = new uint256[](_data.length);
        for (uint256 i = 0; i < _data.length; i++) {
            uint256 jUsdMinted = _getStablesManager().borrow({
                _holding: holding,
                _token: _data[i].token,
                _amount: _data[i].amount,
                _minJUsdAmountOut: _data[i].minJUsdAmountOut,
                _mintDirectlyToUser: _mintDirectlyToUser
            });

            emit Borrowed({
                holding: holding,
                token: _data[i].token,
                jUsdMinted: jUsdMinted,
                mintToUser: _mintDirectlyToUser
            });

            jUsdMintedAmounts[i] = jUsdMinted;
        }

        emit BorrowedMultiple({ holding: holding, length: _data.length, mintedToUser: _mintDirectlyToUser });
        return jUsdMintedAmounts;
    }

    /**
     * @notice Repays jUSD stablecoin debt from the user's or to the holding's address and frees up the locked
     * collateral.
     *
     * @notice Requirements:
     * - `msg.sender` must have a valid holding.
     *
     * @notice Effects:
     * - Repays `_amount` jUSD stablecoin.
     *
     * @notice Emits:
     * - `Repaid` event indicating successful debt repayment operation.
     *
     * @param _token Collateral token.
     * @param _amount The repaid amount.
     * @param _repayFromUser If true, Stables Manager will burn jUSD from the msg.sender, otherwise user's holding.
     */
    function repay(
        address _token,
        uint256 _amount,
        bool _repayFromUser
    ) external override nonReentrant whenNotPaused validHolding(userHolding[msg.sender]) {
        address holding = userHolding[msg.sender];

        emit Repaid({ holding: holding, token: _token, amount: _amount, repayFromUser: _repayFromUser });
        _getStablesManager().repay({
            _holding: holding,
            _token: _token,
            _amount: _amount,
            _burnFrom: _repayFromUser ? msg.sender : holding
        });
    }

    /**
     * @notice Repays multiple jUSD stablecoin debts from the user's or to the holding's address and frees up the locked
     * collateral assets.
     *
     * @notice Requirements:
     * - `msg.sender` must have a valid holding.
     * - `_data` must contain at least one entry.
     *
     * @notice Effects:
     * - Repays stablecoin for each entry in `_data.
     *
     * @notice Emits:
     * - `Repaid` event indicating successful debt repayment operation.
     * - `RepaidMultiple` event indicating successful multiple repayment operation.
     *
     * @param _data Struct containing data for each collateral type.
     * @param _repayFromUser If true, it will burn from user's wallet, otherwise from user's holding.
     */
    function repayMultiple(
        RepayData[] calldata _data,
        bool _repayFromUser
    ) external override validHolding(userHolding[msg.sender]) nonReentrant whenNotPaused {
        require(_data.length > 0, "3006");

        address holding = userHolding[msg.sender];
        for (uint256 i = 0; i < _data.length; i++) {
            emit Repaid({
                holding: holding,
                token: _data[i].token,
                amount: _data[i].amount,
                repayFromUser: _repayFromUser
            });
            _getStablesManager().repay({
                _holding: holding,
                _token: _data[i].token,
                _amount: _data[i].amount,
                _burnFrom: _repayFromUser ? msg.sender : holding
            });
        }

        emit RepaidMultiple({ holding: holding, length: _data.length, repaidFromUser: _repayFromUser });
    }

    /**
     * @notice Allows the contract to accept incoming Ether transfers.
     * @dev This function is executed when the contract receives Ether with no data in the transaction.
     * @dev Only allows transfers from the WETH contract.
     *
     * @notice Emits:
     * - `Received` event to log the sender's address and the amount received.
     */
    receive() external payable {
        require(msg.sender == WETH, "1000");
        emit Received({ from: msg.sender, amount: msg.value });
    }
    //@audit how about with data,it calls fallback and ultimately sends ether in 

    // -- Administration --

    /**
     * @notice Triggers stopped state.
     */
    function pause() external override onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     */
    function unpause() external override onlyOwner whenPaused {
        _unpause();
    }

    /**
     * @dev Renounce ownership override to avoid losing contract's ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }

    // -- Private methods --

    /**
     * @notice Returns the stables manager contract.
     * @return The IStablesManager instance.
     */
    function _getStablesManager() private view returns (IStablesManager) {
        return IStablesManager(manager.stablesManager());
    }

    /**
     * @notice Wraps native coin.
     *
     * @notice Requirements:
     * - The transaction must include ETH.
     * - The amount of ETH sent must be greater than zero.
     *
     * @notice Effects:
     * - Converts the sent ETH to WETH.
     *
     * @notice Emits:
     * - `NativeCoinWrapped` event indicating successful native coin's wrapping.
     */
    function _wrap() private {//@audit does this inherit msg.value
        require(msg.value > 0, "2001");
        emit NativeCoinWrapped({ user: msg.sender, amount: msg.value });
        IWETH(WETH).deposit{ value: msg.value }();
    }

    /**
     * @notice Unwraps WETH.
     *
     * @notice Requirements:
     * - The contract must have enough WETH to unwrap the specified amount.
     *
     * @notice Effects:
     * - Converts the specified amount of WETH to ETH.
     *
     * @notice Emits:
     * - `NativeCoinUnwrapped` event indicating successful WETH's  unwrapping.
     *
     * @param _amount The amount of WETH to unwrap.
     */
    function _unwrap(
        uint256 _amount
    ) private {
        emit NativeCoinUnwrapped({ user: msg.sender, amount: _amount });
        IWETH(WETH).withdraw(_amount);//@audit is there approval needed?
    }

    /**
     * @notice Deposits a specified amount of a token into the holding.
     *
     * @notice Requirements:
     * - `_from` must have approved the contract to spend `_amount` of `_token`.
     *
     * @notice Effects:
     * - Transfers `_amount` of `_token` from `_from` to the holding.
     * - Adds `_amount` of `_token` to the collateral in the Stables Manager Contract.
     *
     * @notice Emits:
     * - `Deposit` event indicating successful deposit operation.
     *
     * @param _from The address from which the token is transferred.
     * @param _token The token address.
     * @param _amount The amount to deposit.
     */
    function _deposit(address _from, address _token, uint256 _amount) private {
        address holding = userHolding[msg.sender];

        emit Deposit(holding, _token, _amount);
        if (_from == address(this)) {
            IERC20(_token).safeTransfer({ to: holding, value: _amount });
        } else {
            IERC20(_token).safeTransferFrom({ from: _from, to: holding, value: _amount });
        }

        _getStablesManager().addCollateral({ _holding: holding, _token: _token, _amount: _amount });
    }

    /**
     * @notice Withdraws a specified amount of a token from the holding.
     *
     * @notice Requirements:
     * - The `_token` must be withdrawable.
     * -The holding must remain solvent after withdrawal if the `_token` is used as a collateral.
     *
     * @notice Effects:
     * - Removes `_amount` of `_token` from the collateral in the Stables Manager Contract if the `_token` is used as a
     * collateral.
     * - Calculates any applicable withdrawal fee.
     * @notice Emits:
     * - `Withdrawal` event indicating successful withdrawal operation.
     *
     * @param _token The token address.
     * @param _amount The amount to withdraw.
     *
     * @return The available amount to be withdrawn and the withdrawal fee amount.
     */
    function _withdraw(address _token, uint256 _amount) private returns (uint256, uint256) {
        require(manager.isTokenWithdrawable(_token), "3071");
        address holding = userHolding[msg.sender];

        // Perform the check to see if this is an airdropped token or user actually has collateral for it //@audit this means?
        (, address _tokenRegistry) = _getStablesManager().shareRegistryInfo(_token);
        if (_tokenRegistry != address(0) && ISharesRegistry(_tokenRegistry).collateral(holding) > 0) {
            _getStablesManager().removeCollateral({ _holding: holding, _token: _token, _amount: _amount });
        }
        uint256 withdrawalFee = manager.withdrawalFee();
        uint256 withdrawalFeeAmount = 0;
        if (withdrawalFee > 0) withdrawalFeeAmount = OperationsLib.getFeeAbsolute(_amount, withdrawalFee);
        emit Withdrawal({ holding: holding, token: _token, totalAmount: _amount, feeAmount: withdrawalFeeAmount });

        return (_amount - withdrawalFeeAmount, withdrawalFeeAmount);
    }

    // -- Modifiers --

    /**
     * @notice Validates that the address is not zero.
     * @param _address The address to validate.
     */
    modifier validAddress(
        address _address
    ) {
        require(_address != address(0), "3000");
        _;
    }

    /**
     * @notice Validates that the holding exists.
     * @param _holding The address of the holding.
     */
    modifier validHolding(
        address _holding
    ) {
        require(isHolding[_holding], "3002");
        _;
    }

    /**
     * @notice Validates that the amount is greater than zero.
     * @param _amount The amount to validate.
     */
    modifier validAmount(
        uint256 _amount
    ) {
        require(_amount > 0, "2001");
        _;
    }

    /**
     * @notice Validates that the token is whitelisted.
     * @param _token The address of the token.
     */
    modifier validToken(
        address _token
    ) {
        require(manager.isTokenWhitelisted(_token), "3001");
        _;
    }
}
```

## File: src/Manager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import {ILiquidationManager} from "./interfaces/core/ILiquidationManager.sol";
import {IManager} from "./interfaces/core/IManager.sol";
import {IOracle} from "./interfaces/oracle/IOracle.sol";
import {OperationsLib} from "./libraries/OperationsLib.sol";

/**
 * @title Manager
 *
 * @notice This contract manages various configurations necessary for the functioning of the protocol.
 *
 * @dev This contract inherits functionalities from `Ownable2Step`.
 *
 * @author Hovooo (@hovooo), Cosmin Grigore (@gcosmintech).
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract Manager is IManager, Ownable2Step {
    // -- Mappings --

    /**
     * @notice Returns true/false for contracts' whitelist status.
     */
    mapping(address caller => bool whitelisted)
        public
        override isContractWhitelisted;

    /**
     * @notice Returns true if token is whitelisted.
     */
    mapping(address token => bool whitelisted)
        public
        override isTokenWhitelisted;

    /**
     * @notice Returns true if the token cannot be withdrawn from a holding.//@audit cannot?
     */
    mapping(address token => bool withdrawable)
        public
        override isTokenWithdrawable;

    /**
     * @notice Returns true if caller is allowed invoker.
     */
    mapping(address invoker => bool allowed) public override allowedInvokers;

    // -- Essential tokens --

    /**
     * @notice WETH address.
     */
    address public immutable override WETH;

    // -- Protocol's stablecoin oracle config --

    /**
     * @notice Oracle contract associated with protocol's stablecoin.
     */
    IOracle public override jUsdOracle;

    /**
     * @notice Extra oracle data if needed.
     */
    bytes public override oracleData;

    // -- Managers --

    /**
     * @notice Returns the address of the HoldingManager Contract.
     */
    address public override holdingManager;

    /**
     * @notice Returns the address of the LiquidationManager Contract.
     */
    address public override liquidationManager;

    /**
     * @notice Returns the address of the StablesManager Contract.
     */
    address public override stablesManager;

    /**
     * @notice Returns the address of the StrategyManager Contract.
     */
    address public override strategyManager;

    /**
     * @notice Returns the address of the SwapManager Contract.
     */
    address public override swapManager;

    // -- Fees --

    /**
     * @notice Returns the default performance fee.
     * @dev Uses 2 decimal precision, where 1% is represented as 100.
     */
    uint256 public override performanceFee = 1500; //15%

    /**
     * @notice Returns the maximum performance fee.
     * @dev Uses 2 decimal precision, where 1% is represented as 100.
     */
    uint256 public immutable override MAX_PERFORMANCE_FEE = 2500; //25%

    /**
     * @notice Fee for withdrawing from a holding.
     * @dev Uses 2 decimal precision, where 1% is represented as 100.
     */
    uint256 public override withdrawalFee;

    /**
     * @notice Returns the maximum withdrawal fee.
     * @dev Uses 2 decimal precision, where 1% is represented as 100.
     */
    uint256 public immutable override MAX_WITHDRAWAL_FEE = 800; //8%

    /**
     * @notice Returns the fee address, where all the fees are collected.
     */
    address public override feeAddress;

    // -- Factories --

    /**
     * @notice Returns the address of the ReceiptTokenFactory.
     */
    address public override receiptTokenFactory;

    // -- Utility values --

    /**
     * @notice Minimum allowed jUSD debt amount for a holding to ensure successful liquidation.
     * @dev 200 jUSD is the initial minimum allowed debt amount for a holding to ensure successful liquidation.
     */
    uint256 public override minDebtAmount = 200e18; //@audit looks like jUSD is 18 decimals

    /**
     * @notice Returns the collateral rate precision.
     * @dev Should be less than exchange rate precision due to optimization in math.
     */
    uint256 public constant override PRECISION = 1e5; //@audit what?

    /**
     * @notice Returns the exchange rate precision.
     */
    uint256 public constant override EXCHANGE_RATE_PRECISION = 1e18; //@audit what?

    /**
     * @notice Timelock amount in seconds for changing the oracle data.
     */
    uint256 public override timelockAmount = 1 hours;

    /**
     * @notice Variables required for delayed timelock update.
     */
    uint256 public override oldTimelock;
    uint256 public override newTimelock;
    uint256 public override newTimelockTimestamp;

    /**
     * @notice Variables required for delayed oracle update.
     */
    address public override newOracle;
    uint256 public override newOracleTimestamp;

    /**
     * @notice Variables required for delayed swap manager update.
     */
    address public override newSwapManager;
    uint256 public override newSwapManagerTimestamp;

    /**
     * @notice Variables required for delayed liquidation manager update.
     */
    address public override newLiquidationManager;
    uint256 public override newLiquidationManagerTimestamp;

    /**
     * @notice Creates a new Manager Contract.
     *
     * @param _initialOwner The initial owner of the contract.
     * @param _weth The WETH address.
     * @param _oracle The jUSD oracle address.
     * @param _oracleData The jUSD initial oracle data.
     */
    constructor(
        address _initialOwner,
        address _weth,
        address _oracle,
        bytes memory _oracleData
    ) Ownable(_initialOwner) validAddress(_weth) validAddress(_oracle) {
        WETH = _weth;
        jUsdOracle = IOracle(_oracle);
        oracleData = _oracleData;
    }

    // -- Setters --

    /**
     * @notice Whitelists a contract.
     *
     * @notice Requirements:
     * - `_contract` must not be whitelisted.
     *
     * @notice Effects:
     * - Updates the `isContractWhitelisted` mapping.
     *
     * @notice Emits:
     * - `ContractWhitelisted` event indicating successful contract whitelist operation.
     *
     * @param _contract The address of the contract to be whitelisted.
     */
    function whitelistContract(
        address _contract
    ) external override onlyOwner validAddress(_contract) {
        require(!isContractWhitelisted[_contract], "3019");
        isContractWhitelisted[_contract] = true;
        emit ContractWhitelisted(_contract);
    }

    /**
     * @notice Blacklists a contract.
     *
     * @notice Requirements:
     * - `_contract` must be whitelisted.
     *
     * @notice Effects:
     * - Updates the `isContractWhitelisted` mapping.
     *
     * @notice Emits:
     * - `ContractBlacklisted` event indicating successful contract blacklist operation.
     *
     * @param _contract The address of the contract to be blacklisted.
     */
    function blacklistContract(
        address _contract
    ) external override onlyOwner validAddress(_contract) {
        require(isContractWhitelisted[_contract], "1000");
        isContractWhitelisted[_contract] = false;
        emit ContractBlacklisted(_contract);
    }

    /**
     * @notice Whitelists a token.
     *
     * @notice Requirements:
     * - `_token` must not be whitelisted.
     *
     * @notice Effects:
     * - Updates the `isTokenWhitelisted` mapping.
     *
     * @notice Emits:
     * - `TokenWhitelisted` event indicating successful token whitelist operation.
     *
     * @param _token The address of the token to be whitelisted.
     */
    function whitelistToken(
        address _token
    ) external override onlyOwner validAddress(_token) {
        require(!isTokenWhitelisted[_token], "3019");
        isTokenWhitelisted[_token] = true;
        emit TokenWhitelisted(_token);
    }

    /**
     * @notice Removes a token from whitelist.
     *
     * @notice Requirements:
     * - `_token` must be whitelisted.
     *
     * @notice Effects:
     * - Updates the `isTokenWhitelisted` mapping.
     *
     * @notice Emits:
     * - `TokenRemoved` event indicating successful token removal operation.
     *
     * @param _token The address of the token to be whitelisted.
     */
    function removeToken(
        address _token
    ) external override onlyOwner validAddress(_token) {
        require(isTokenWhitelisted[_token], "1000");
        isTokenWhitelisted[_token] = false;
        emit TokenRemoved(_token);
    }

    /**
     * @notice Registers the `_token` as withdrawable.
     *
     * @notice Requirements:
     * - `msg.sender` must be owner or `stablesManager`.
     * - `_token` must not be withdrawable.
     *
     * @notice Effects:
     * - Updates the `isTokenWithdrawable` mapping.
     *
     * @notice Emits:
     * - `WithdrawableTokenAdded` event indicating successful withdrawable token addition operation.
     *
     * @param _token The address of the token to be added as withdrawable.
     */
    function addWithdrawableToken(
        address _token
    ) external override validAddress(_token) {
        require(owner() == msg.sender || stablesManager == msg.sender, "1000");
        require(!isTokenWithdrawable[_token], "3069");
        isTokenWithdrawable[_token] = true;
        emit WithdrawableTokenAdded(_token);
    }

    /**
     * @notice Unregisters the `_token` as withdrawable.
     *
     * @notice Requirements:
     * - `_token` must be withdrawable.
     *
     * @notice Effects:
     * - Updates the `isTokenWithdrawable` mapping.
     *
     * @notice Emits:
     * - `WithdrawableTokenRemoved` event indicating successful withdrawable token removal operation.
     *
     * @param _token The address of the token to be removed as withdrawable.
     */
    function removeWithdrawableToken(
        address _token
    ) external override onlyOwner validAddress(_token) {
        require(isTokenWithdrawable[_token], "3070"); //@audit only owner can remove withdrawable?
        isTokenWithdrawable[_token] = false;
        emit WithdrawableTokenRemoved(_token);
    }

    /**
     * @notice Sets invoker as allowed or forbidden.
     *
     * @notice Effects:
     * - Updates the `allowedInvokers` mapping.
     *
     * @notice Emits:
     * - `InvokerUpdated` event indicating successful invoker update operation.
     *
     * @param _component Invoker's address.
     * @param _allowed True/false.
     */
    function updateInvoker(
        address _component,
        bool _allowed
    ) external override onlyOwner validAddress(_component) {
        allowedInvokers[_component] = _allowed;
        emit InvokerUpdated(_component, _allowed);
    }

    /**
     * @notice Sets the Holding Manager Contract's address.
     *
     * @notice Requirements:
     * - Can only be called once.
     * - `_val` must be non-zero address.
     *
     * @notice Effects:
     * - Updates the `holdingManager` state variable.
     *
     * @notice Emits:
     * - `HoldingManagerUpdated` event indicating the successful setting of the Holding Manager's address.
     *
     * @param _val The holding manager's address.
     */
    function setHoldingManager(
        address _val
    ) external override onlyOwner validAddress(_val) {
        require(holdingManager == address(0), "3017");
        emit HoldingManagerUpdated(holdingManager, _val);
        holdingManager = _val;
    }

    /**
     * @notice Sets the Liquidation Manager Contract's address.
     *
     * @notice Requirements:
     * - Can only be called once.
     * - `_val` must be non-zero address.
     *
     * @notice Effects:
     * - Updates the `liquidationManager` state variable.
     *
     * @notice Emits:
     * - `LiquidationManagerUpdated` event indicating the successful setting of the Liquidation Manager's address.
     *
     * @param _val The liquidation manager's address.
     */
    function setLiquidationManager(
        address _val
    ) external override onlyOwner validAddress(_val) {
        require(liquidationManager == address(0), "3017");
        emit LiquidationManagerUpdated(liquidationManager, _val);
        liquidationManager = _val;
    }

    /**
     * @notice Initiates the process to update the Liquidation Manager Contract's address.
     *
     * @notice Requirements:
     * - `_val` must be non-zero address.
     * - `_val` must be different from previous `liquidationManager` address.
     *
     * @notice Effects:
     * - Updates the the `newLiquidationManager` state variable.
     * - Updates the the `newLiquidationManagerTimestamp` state variable.
     *
     * @notice Emits:
     * - `LiquidationManagerUpdateRequested` event indicating successful liquidation manager change request.
     *
     * @param _val The new liquidation manager's address.
     */
    function requestNewLiquidationManager(
        address _val
    ) external override onlyOwner validAddress(_val) {
        require(liquidationManager != _val, "3017");

        emit NewLiquidationManagerRequested(liquidationManager, _val);

        newLiquidationManager = _val;
        newLiquidationManagerTimestamp = block.timestamp;
    }

    /**
     * @notice Sets the Liquidation Manager Contract's address.
     *
     * @notice Requirements:
     * - `_val` must be different from previous `liquidationManager` address.
     * - Timelock must expire.
     *
     * @notice Effects:
     * - Updates the `liquidationManager` state variable.
     * - Updates the the `newLiquidationManager` state variable.
     * - Updates the the `newLiquidationManagerTimestamp` state variable.
     *
     * @notice Emits:
     * - `LiquidationManagerUpdated` event indicating the successful setting of the Liquidation Manager's address.
     */
    function acceptNewLiquidationManager() external override onlyOwner {
        require(newLiquidationManager != address(0), "3063");
        require(
            newLiquidationManagerTimestamp + timelockAmount <= block.timestamp,
            "3066"
        );

        emit LiquidationManagerUpdated(
            liquidationManager,
            newLiquidationManager
        );

        liquidationManager = newLiquidationManager;
        newLiquidationManager = address(0);
        newLiquidationManagerTimestamp = 0;
    }

    /**
     * @notice Sets the Stablecoin Manager Contract's address.
     *
     * @notice Requirements:
     * - `_val` must be different from previous `stablesManager` address.
     *
     * @notice Effects:
     * - Updates the `stablesManager` state variable.
     *
     * @notice Emits:
     * - `StablecoinManagerUpdated` event indicating the successful setting of the Stablecoin Manager's address.
     *
     * @param _val The Stablecoin manager's address.
     */
    function setStablecoinManager(
        address _val
    ) external override onlyOwner validAddress(_val) {
        require(stablesManager == address(0), "3017");
        emit StablecoinManagerUpdated(stablesManager, _val);
        stablesManager = _val;
    }

    /**
     * @notice Sets the Strategy Manager Contract's address.
     *
     * @notice Requirements:
     * - `_val` must be different from previous `strategyManager` address.
     *
     * @notice Effects:
     * - Updates the `strategyManager` state variable.
     *
     * @notice Emits:
     * - `StrategyManagerUpdated` event indicating the successful setting of the Strategy Manager's address.
     *
     * @param _val The Strategy manager's address.
     */
    function setStrategyManager(
        address _val
    ) external override onlyOwner validAddress(_val) {
        require(strategyManager == address(0), "3017");
        emit StrategyManagerUpdated(strategyManager, _val);
        strategyManager = _val;
    }

    /**
     * @notice Sets the Swap Manager Contract's address.
     *
     * @notice Requirements:
     * - Can only be called once.
     * - `_val` must be non-zero address.
     *
     * @notice Effects:
     * - Updates the `swapManager` state variable.
     *
     * @notice Emits:
     * - `SwapManagerUpdated` event indicating the successful setting of the Swap Manager's address.
     *
     * @param _val The Swap manager's address.
     */
    function setSwapManager(
        address _val
    ) external override onlyOwner validAddress(_val) {
        require(swapManager == address(0), "3017");
        emit SwapManagerUpdated(swapManager, _val);
        swapManager = _val;
    }

    /**
     * @notice Initiates the process to update the Swap Manager Contract's address.
     *
     * @notice Requirements:
     * - `_val` must be non-zero address.
     * - `_val` must be different from previous `swapManager` address.
     *
     * @notice Effects:
     * - Updates the the `newSwapManager` state variable.
     * - Updates the the `newSwapManagerTimestamp` state variable.
     *
     * @notice Emits:
     * - `NewSwapManagerRequested` event indicating successful swap manager change request.
     *
     * @param _val The new swap manager's address.
     */
    function requestNewSwapManager(
        address _val
    ) external override onlyOwner validAddress(_val) {
        require(swapManager != _val, "3017");

        emit NewSwapManagerRequested(swapManager, _val);

        newSwapManager = _val;
        newSwapManagerTimestamp = block.timestamp;
    }

    /**
     * @notice Updates the Swap Manager Contract    .
     *
     * @notice Requirements:
     * - Timelock must expire.
     *
     * @notice Effects:
     * - Updates the `swapManager` state variable.
     * - Resets `newSwapManager` to address(0).
     * - Resets `newSwapManagerTimestamp` to 0.
     *
     * @notice Emits:
     * - `SwapManagerUpdated` event indicating the successful setting of the Swap Manager's address.
     */
    function acceptNewSwapManager() external override onlyOwner {
        require(newSwapManager != address(0), "3063");
        require(
            newSwapManagerTimestamp + timelockAmount <= block.timestamp,
            "3066"
        );

        emit SwapManagerUpdated(swapManager, newSwapManager);

        swapManager = newSwapManager;
        newSwapManager = address(0);
        newSwapManagerTimestamp = 0;
    }

    /**
     * @notice Sets the performance fee.
     *
     * @notice Requirements:
     * - `_val` must be smaller than `MAX_PERFORMANCE_FEE`.
     *
     * @notice Effects:
     * - Updates the `performanceFee` state variable.
     *
     * @notice Emits:
     * - `PerformanceFeeUpdated` event indicating successful performance fee update operation.
     *
     * @dev `_val` uses 2 decimal precision, where 1% is represented as 100.
     *
     * @param _val The new performance fee value.
     */
    function setPerformanceFee(uint256 _val) external override onlyOwner {
        require(performanceFee != _val, "3017");
        require(_val < MAX_PERFORMANCE_FEE, "3018");
        emit PerformanceFeeUpdated(performanceFee, _val);
        performanceFee = _val;
    }

    /**
     * @notice Sets the withdrawal fee.
     *
     * @notice Requirements:
     * - `_val` must be smaller than `FEE_FACTOR` to avoid wrong computations.
     *
     * @notice Effects:
     * - Updates the `withdrawalFee` state variable.
     *
     * @notice Emits:
     * - `WithdrawalFeeUpdated` event indicating successful withdrawal fee update operation.
     *
     * @dev `_val` uses 2 decimal precision, where 1% is represented as 100.
     *
     * @param _val The new withdrawal fee value.
     */
    function setWithdrawalFee(uint256 _val) external override onlyOwner {
        require(withdrawalFee != _val, "3017");
        require(_val <= MAX_WITHDRAWAL_FEE, "3018");
        emit WithdrawalFeeUpdated(withdrawalFee, _val);
        withdrawalFee = _val;
    }

    /**
     * @notice Sets the global fee address.
     *
     * @notice Requirements:
     * - `_val` must be different from previous `holdingManager` address.
     *
     * @notice Effects:
     * - Updates the `feeAddress` state variable.
     *
     * @notice Emits:
     * - `FeeAddressUpdated` event indicating successful setting of the global fee address.
     *
     * @param _val The new fee address.
     */
    function setFeeAddress(
        address _val
    ) external override onlyOwner validAddress(_val) {
        require(feeAddress != _val, "3017");
        emit FeeAddressUpdated(feeAddress, _val);
        feeAddress = _val;
    }

    /**
     * @notice Sets the receipt token factory's address.
     *
     * @notice Requirements:
     * - `_val` must be different from previous `receiptTokenFactory` address.
     *
     * @notice Effects:
     * - Updates the `receiptTokenFactory` state variable.
     *
     * @notice Emits:
     * - `ReceiptTokenFactoryUpdated` event indicating successful setting of the `receiptTokenFactory` address.
     *
     * @param _factory Receipt token factory's address.
     */
    function setReceiptTokenFactory(
        address _factory
    ) external override onlyOwner validAddress(_factory) {
        require(receiptTokenFactory != _factory, "3017");
        emit ReceiptTokenFactoryUpdated(receiptTokenFactory, _factory);
        receiptTokenFactory = _factory;
    }

    /**
     * @notice Registers jUSD's oracle change request.
     *
     * @notice Requirements:
     * - Contract must not be in active change.
     *
     * @notice Effects:
     * - Updates the the `newOracle` state variable.
     * - Updates the the `newOracleTimestamp` state variable.
     *
     * @notice Emits:
     * - `NewOracleRequested` event indicating successful jUSD's oracle change request.
     *
     * @param _oracle Liquidity gauge factory's address.
     */
    function requestNewJUsdOracle(
        address _oracle
    ) external override onlyOwner validAddress(_oracle) {
        require(newOracle == address(0), "3017");
        require(address(jUsdOracle) != _oracle, "3017");

        emit NewOracleRequested(_oracle);

        newOracle = _oracle;
        newOracleTimestamp = block.timestamp;
    }

    /**
     * @notice Updates jUSD's oracle.
     *
     * @notice Requirements:
     * - Contract must be in active change.
     * - Timelock must expire.
     *
     * @notice Effects:
     * - Updates the the `jUsdOracle` state variable.
     * - Updates the the `newOracle` state variable.
     * - Updates the the `newOracleTimestamp` state variable.
     *
     * @notice Emits:
     * - `OracleUpdated` event indicating successful jUSD's oracle change.
     */
    function acceptNewJUsdOracle() external override onlyOwner {
        require(newOracle != address(0), "3063");
        require(newOracleTimestamp + timelockAmount <= block.timestamp, "3066");

        emit OracleUpdated(address(jUsdOracle), newOracle);

        jUsdOracle = IOracle(newOracle);
        newOracle = address(0);
        newOracleTimestamp = 0;
    }

    /**
     * @notice Updates the jUSD's oracle data.
     *
     * @notice Requirements:
     * - `newOracleData` must be different from previous `oracleData`.
     *
     * @notice Effects:
     * - Updates the `oracleData` state variable.
     *
     * @notice Emits:
     * - `OracleDataUpdated` event indicating successful update of the oracle Data.
     *
     * @param newOracleData New data used for jUSD's oracle data.
     */
    function setJUsdOracleData(
        bytes calldata newOracleData
    ) external override onlyOwner {
        require(keccak256(oracleData) != keccak256(newOracleData), "3017");
        emit OracleDataUpdated(oracleData, newOracleData);
        oracleData = newOracleData;
    }

    /**
     * @notice Sets the minimum debt amount.
     *
     * @notice Requirements:
     * - `_minDebtAmount` must be greater than zero.
     * - `_minDebtAmount` must be different from previous `minDebtAmount`.
     *
     * @param _minDebtAmount The new minimum debt amount.
     */
    function setMinDebtAmount(
        uint256 _minDebtAmount
    ) external override onlyOwner {
        require(_minDebtAmount > 0, "2100");
        require(_minDebtAmount != minDebtAmount, "3017");
        minDebtAmount = _minDebtAmount;
    }

    /**
     * @notice Registers timelock change request.
     *
     * @notice Requirements:
     * - `oldTimelock` must be set zero.
     * - `newVal` must be greater than zero.
     *
     * @notice Effects:
     * - Updates the the `oldTimelock` state variable.
     * - Updates the the `newTimelock` state variable.
     * - Updates the the `newTimelockTimestamp` state variable.
     *
     * @notice Emits:
     * - `TimelockAmountUpdateRequested` event indicating successful timelock change request.
     *
     * @param newVal The new timelock value in seconds.
     */
    function requestNewTimelock(uint256 newVal) external override onlyOwner {
        require(oldTimelock == 0, "3017");
        require(newVal != 0, "2001");

        newTimelock = newVal;
        oldTimelock = timelockAmount;

        emit TimelockAmountUpdateRequested(oldTimelock, newTimelock);

        newTimelockTimestamp = block.timestamp;
    }

    /**
     * @notice Updates the timelock amount.
     *
     * @notice Requirements:
     * - Contract must be in active change.
     * - `newTimelock` must be greater than zero.
     * - The old timelock must expire.
     *
     * @notice Effects:
     * - Updates the the `timelockAmount` state variable.
     * - Updates the the `oldTimelock` state variable.
     * - Updates the the `newTimelock` state variable.
     * - Updates the the `newTimelockTimestamp` state variable.
     *
     * @notice Emits:
     * - `TimelockAmountUpdated` event indicating successful timelock amount change.
     */
    function acceptNewTimelock() external override onlyOwner {
        require(newTimelock != 0, "2001");
        require(newTimelockTimestamp + oldTimelock <= block.timestamp, "3066");

        emit TimelockAmountUpdated(oldTimelock, newTimelock);

        timelockAmount = newTimelock;
        oldTimelock = 0;
        newTimelock = 0;
        newTimelockTimestamp = 0;
    }

    /**
     * @notice Override to avoid losing contract ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }

    // -- Getters --

    /**
     * @notice Returns the up to date exchange rate of the protocol's stablecoin jUSD.
     *
     * @notice Requirements:
     * - Oracle must have updated rate.
     * - Rate must be a non zero positive value.
     *
     * @return The current exchange rate.
     */
    function getJUsdExchangeRate() external view override returns (uint256) {
        (bool updated, uint256 rate) = jUsdOracle.peek(oracleData);
        require(updated, "3037");
        require(rate > 0, "2100");
        return rate;
    }

    // Modifiers

    /**
     * @dev Modifier to check if the address is valid (not zero address).
     * @param _address being checked.
     */
    modifier validAddress(address _address) {
        require(_address != address(0), "3000");
        _;
    }
}
```

## File: src/StablesManager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20, IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

import { OperationsLib } from "./libraries/OperationsLib.sol";

import { IHoldingManager } from "./interfaces/core/IHoldingManager.sol";
import { IJigsawUSD } from "./interfaces/core/IJigsawUSD.sol";
import { IManager } from "./interfaces/core/IManager.sol";
import { ISharesRegistry } from "./interfaces/core/ISharesRegistry.sol";
import { IStablesManager } from "./interfaces/core/IStablesManager.sol";

/**
 * @title StablesManager
 *
 * @notice Manages operations with protocol's stablecoin and user's collateral.
 *
 * @dev This contract inherits functionalities from `Ownable2Step`, `Pausable`.
 *
 * @author Hovooo (@hovooo), Cosmin Grigore (@gcosmintech).
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract StablesManager is IStablesManager, Ownable2Step, Pausable {
    using Math for uint256;

    /**
     * @notice Returns total borrowed jUSD amount using `token`.
     */
    mapping(address token => uint256 borrowedAmount) public override totalBorrowed;

    /**
     * @notice Returns config info for each token.
     */
    mapping(address token => ShareRegistryInfo info) public override shareRegistryInfo;

    /**
     * @notice Returns protocol's stablecoin address.
     */
    IJigsawUSD public immutable override jUSD;

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     */
    IManager public immutable override manager;

    // -- Constructor --

    /**
     * @notice Creates a new StablesManager contract.
     *
     * @param _initialOwner The initial owner of the contract.
     * @param _manager Contract that holds all the necessary configs of the protocol.
     * @param _jUSD The protocol's stablecoin address.
     */
    constructor(address _initialOwner, address _manager, address _jUSD) Ownable(_initialOwner) {
        require(_manager != address(0), "3065");
        require(_jUSD != address(0), "3001");
        manager = IManager(_manager);
        jUSD = IJigsawUSD(_jUSD);
    }

    // -- User specific methods --

    /**
     * @notice Registers new collateral.
     *
     * @dev The amount will be transformed to shares.
     *
     * @notice Requirements:
     * - The caller must be allowed to perform this action directly. If user - use Holding Manager Contract.
     * - The `_token` must be whitelisted.
     * - The `_token`'s registry must be active.
     *
     * @notice Effects:
     * - Adds collateral for the holding.
     *
     * @notice Emits:
     * - `AddedCollateral` event indicating successful collateral addition operation.
     *
     * @param _holding The holding for which collateral is added.
     * @param _token Collateral token.
     * @param _amount Amount of tokens to be added as collateral.
     */
    function addCollateral(
        address _holding,
        address _token,
        uint256 _amount
    ) external override whenNotPaused onlyAllowed {
        require(shareRegistryInfo[_token].active, "1201");

        emit AddedCollateral({ holding: _holding, token: _token, amount: _amount });
        _getRegistry(_token).registerCollateral({ _holding: _holding, _share: _amount });
    }

    /**
     * @notice Unregisters collateral.
     *
     * @notice Requirements:
     * - The contract must not be paused.
     * - The caller must be allowed to perform this action directly. If user - use Holding Manager Contract.
     * - The token's registry must be active.
     * - `_holding` must stay solvent after collateral removal.
     *
     * @notice Effects:
     * - Removes collateral for the holding.
     *
     * @notice Emits:
     * - `RemovedCollateral` event indicating successful collateral removal operation.
     *
     * @param _holding The holding for which collateral is removed.
     * @param _token Collateral token.
     * @param _amount Amount of collateral.
     */
    function removeCollateral(
        address _holding,
        address _token,
        uint256 _amount
    ) external override onlyAllowed whenNotPaused {
        require(shareRegistryInfo[_token].active, "1201");

        emit RemovedCollateral({ holding: _holding, token: _token, amount: _amount });
        _getRegistry(_token).unregisterCollateral({ _holding: _holding, _share: _amount });
        require(isSolvent({ _token: _token, _holding: _holding }), "3009");//@audit what is this?
    }

    /**
     * @notice Unregisters collateral.
     *
     * @notice Requirements:
     * - The caller must be the LiquidationManager.
     * - The token's registry must be active.
     *
     * @notice Effects:
     * - Force removes collateral from the `_holding` in case of liquidation, without checking if user is solvent after
     * collateral removal.
     *
     * @notice Emits:
     * - `RemovedCollateral` event indicating successful collateral removal operation.
     *
     * @param _holding The holding for which collateral is added.
     * @param _token Collateral token.
     * @param _amount Amount of collateral.
     */
    function forceRemoveCollateral(address _holding, address _token, uint256 _amount) external override whenNotPaused {
        require(msg.sender == manager.liquidationManager(), "1000");
        require(shareRegistryInfo[_token].active, "1201");

        emit RemovedCollateral({ holding: _holding, token: _token, amount: _amount });
        _getRegistry(_token).unregisterCollateral({ _holding: _holding, _share: _amount });
    }

    /**
     * @notice Mints stablecoin to the user.
     *
     * @notice Requirements:
     * - The caller must be allowed to perform this action directly. If user - use Holding Manager Contract.
     * - The token's registry must be active.
     * - `_amount` must be greater than zero.
     *
     * @notice Effects:
     * - Mints stablecoin based on the collateral amount.
     * - Updates the total borrowed jUSD amount for `_token`, used for borrowing.
     * - Updates `_holdings`'s borrowed amount in `token`'s registry contract.
     * - Ensures the holding remains solvent.
     *
     * @notice Emits:
     * - `Borrowed`.
     *
     * @param _holding The holding for which collateral is added.
     * @param _token Collateral token.
     * @param _amount The collateral amount equivalent for borrowed jUSD.
     * @param _minJUsdAmountOut The minimum amount of jUSD that is expected to be received.
     * @param _mintDirectlyToUser If true, mints to user instead of holding.
     *
     * @return jUsdMintAmount The amount of jUSD minted.
     *
     */
    function borrow(
        address _holding,
        address _token,
        uint256 _amount,
        uint256 _minJUsdAmountOut,
        bool _mintDirectlyToUser
    ) external override onlyAllowed whenNotPaused returns (uint256 jUsdMintAmount) {
        require(_amount > 0, "3010");
        require(shareRegistryInfo[_token].active, "1201");

        BorrowTempData memory tempData = BorrowTempData({
            registry: ISharesRegistry(shareRegistryInfo[_token].deployedAt),
            exchangeRatePrecision: manager.EXCHANGE_RATE_PRECISION(),
            amount: 0,
            amountValue: 0
        });

        // Ensure amount uses 18 decimals.
        tempData.amount = _transformTo18Decimals({ _amount: _amount, _decimals: IERC20Metadata(_token).decimals() });

        // Get the USD value for the provided collateral amount.
        tempData.amountValue =
            tempData.amount.mulDiv(tempData.registry.getExchangeRate(), tempData.exchangeRatePrecision);

        // Get the jUSD amount based on the provided collateral's USD value.
        jUsdMintAmount = tempData.amountValue.mulDiv(tempData.exchangeRatePrecision, manager.getJUsdExchangeRate());

        // Ensure the amount of jUSD minted is greater than the minimum amount specified by the user.
        require(jUsdMintAmount >= _minJUsdAmountOut, "2100");

        emit Borrowed({ holding: _holding, jUsdMinted: jUsdMintAmount, mintToUser: _mintDirectlyToUser });

        // Update internal values.[l.]
        totalBorrowed[_token] += jUsdMintAmount;

        // Update holding's borrowed amount.
        tempData.registry.setBorrowed({
            _holding: _holding,
            _newVal: tempData.registry.borrowed(_holding) + jUsdMintAmount
        });

        // Based on user's choice, jUSD is minted directly to them or the `_holding`.
        jUSD.mint({
            _to: _mintDirectlyToUser ? _getHoldingManager().holdingUser(_holding) : _holding,
            _amount: jUsdMintAmount
        });

        // Make sure user is solvent after borrowing operation.
        require(isSolvent({ _token: _token, _holding: _holding }), "3009");
    }

    /**
     * @notice Repays debt.
     *
     * @notice Requirements:
     * - The caller must be allowed to perform this action directly. If user - use Holding Manager Contract.
     * - The token's registry must be active.
     * - The holding must have a positive borrowed amount.
     * - `_amount` must not exceed `holding`'s borrowed amount.
     * - `_amount` must be greater than zero.
     * - `_burnFrom` must not be the zero address.
     *
     * @notice Effects:
     * - Updates the total borrowed jUSD amount for `_token`, used for borrowing.
     * - Updates `_holdings`'s borrowed amount in `token`'s registry contract.
     * - Burns `_amount` jUSD tokens from `_burnFrom` address
     *
     * @notice Emits:
     * - `Repaid` event indicating successful repay operation.
     *
     * @param _holding The holding for which repay is performed.
     * @param _token Collateral token.
     * @param _amount The repaid jUSD amount.
     * @param _burnFrom The address to burn from.
     */
    function repay(
        address _holding,
        address _token,
        uint256 _amount,
        address _burnFrom
    ) external override onlyAllowed whenNotPaused {
        require(shareRegistryInfo[_token].active, "1201");
        ISharesRegistry registry = ISharesRegistry(shareRegistryInfo[_token].deployedAt);
        require(registry.borrowed(_holding) > 0, "3011");
        require(registry.borrowed(_holding) >= _amount, "2003");
        require(_amount > 0, "3012");
        require(_burnFrom != address(0), "3000");

        // Update internal values.
        totalBorrowed[_token] -= _amount;

        emit Repaid({ holding: _holding, amount: _amount, burnFrom: _burnFrom });
        // Update holding's borrowed amount.
        registry.setBorrowed({ _holding: _holding, _newVal: registry.borrowed(_holding) - _amount });
        // Burn jUSD.
        jUSD.burnFrom({ _user: _burnFrom, _amount: _amount });
    }

    // -- Administration --

    /**
     * @notice Registers a share registry contract for a token.
     *
     * @notice Requirements:
     * - `_token` must not be the zero address.
     * - `_token` must match the token in the registry.
     *
     * @notice Effects:
     * - Adds or updates the share registry info for the token.
     *
     * @notice Emits:
     * - `RegistryAdded` if a new registry is added.
     * - `RegistryUpdated` if an existing registry is updated.
     *
     * @param _registry Registry contract address.
     * @param _token Token address.
     * @param _active Set it as active or inactive.
     *
     */
    function registerOrUpdateShareRegistry(address _registry, address _token, bool _active) external onlyOwner {
        require(_token != address(0), "3007");
        require(_token == ISharesRegistry(_registry).token(), "3008");

        ShareRegistryInfo memory info;
        info.active = _active;

        if (shareRegistryInfo[_token].deployedAt == address(0)) {
            info.deployedAt = _registry;
            manager.addWithdrawableToken(_token);
            emit RegistryAdded({ token: _token, registry: _registry });
        } else {
            info.deployedAt = shareRegistryInfo[_token].deployedAt;
            emit RegistryUpdated({ token: _token, registry: _registry });
        }

        shareRegistryInfo[_token] = info;
    }

    /**
     * @notice Triggers stopped state.
     */
    function pause() external override onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     */
    function unpause() external override onlyOwner whenPaused {
        _unpause();
    }

    /**
     * @notice Override to avoid losing contract ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }

    // -- Getters --

    /**
     * @notice Returns true if user is solvent for the specified token.
     *
     * @dev The method reverts if block.timestamp - _maxTimeRange > exchangeRateUpdatedAt.
     *
     * @notice Requirements:
     * - `_holding` must not be the zero address.
     * - There must be registry for `_token`.
     *
     * @param _token The token for which the check is done.
     * @param _holding The user address.
     *
     * @return flag indicating whether `holding` is solvent.
     */
    function isSolvent(address _token, address _holding) public view override returns (bool) {
        require(_holding != address(0), "3031");
        ISharesRegistry registry = _getRegistry(_token);
        require(address(registry) != address(0), "3008");

        if (registry.borrowed(_holding) == 0) return true;

        return getRatio({ _holding: _holding, registry: registry, rate: registry.getConfig().collateralizationRate })//@audit dont understand
            >= registry.borrowed(_holding).mulDiv(manager.getJUsdExchangeRate(), manager.EXCHANGE_RATE_PRECISION());//@audit is it returning rate in Jusd or colllateral
    }

    /**
     * @notice Checks if a holding can be liquidated for a specific token.
     *
     * @notice Requirements:
     * - `_holding` must not be the zero address.
     * - There must be registry for `_token`.
     *
     * @param _token The token for which the check is done.
     * @param _holding The user address.
     *
     * @return flag indicating whether `holding` is liquidatable.
     */
    function isLiquidatable(address _token, address _holding) public view override returns (bool) {
        require(_holding != address(0), "3031");
        ISharesRegistry registry = _getRegistry(_token);
        require(address(registry) != address(0), "3008");

        if (registry.borrowed(_holding) == 0) return false;

        // Compute threshold for specified collateral
        ISharesRegistry.RegistryConfig memory registryConfig = registry.getConfig();
        uint256 threshold = registryConfig.collateralizationRate + registryConfig.liquidationBuffer;

        // Returns true when the ratio is below the liquidation threshold
        return getRatio({ _holding: _holding, registry: registry, rate: threshold })
            <= registry.borrowed(_holding).mulDiv(manager.getJUsdExchangeRate(), manager.EXCHANGE_RATE_PRECISION());
    }

    /**
     * @notice Computes the solvency ratio.
     *
     * @dev Solvency ratio is calculated based on the used collateral type, its collateralization and exchange rates,
     * and `_holding`'s borrowed amount.
     *
     * @param _holding The holding address to check for.
     * @param registry The Shares Registry Contract for the token.
     * @param rate The rate to compute ratio for (either collateralization rate for `isSolvent` or liquidation
     * threshold for `isLiquidatable`).
     *
     * @return The calculated solvency ratio.
     */
    function getRatio(address _holding, ISharesRegistry registry, uint256 rate) public view returns (uint256) {
        // Get collateral's exchange rate.
        uint256 exchangeRate = registry.getExchangeRate();
        // Get holding's available collateral amount.
        uint256 colAmount = registry.collateral(_holding);
        // Calculate the final divider for precise calculations.
        uint256 precision = manager.EXCHANGE_RATE_PRECISION() * manager.PRECISION();// 1e18/1e5

        // Calculate the solvency ratio.
        uint256 result = colAmount * rate * exchangeRate / precision;//@audit dont understand
        // Transform to 18 decimals if needed.
        return _transformTo18Decimals({ _amount: result, _decimals: IERC20Metadata(registry.token()).decimals() });
    }

    // -- Private methods --

    /**
     * @notice Transforms the provided amount based on its original decimals to fit into 18 decimals.
     *
     * @param _amount The amount to transform.
     * @param _decimals The original number of decimals.
     *
     * @return The amount adjusted to 18 decimals.
     */
    function _transformTo18Decimals(uint256 _amount, uint256 _decimals) private pure returns (uint256) {
        if (_decimals < 18) return _amount * (10 ** (18 - _decimals));
        if (_decimals > 18) return _amount / (10 ** (_decimals - 18));

        return _amount;
    }

    /**
     * @notice Gets the Shares registry for a specific token.
     * @param _token address for which the registry is being fetched.
     * @return The Shares Registry Contract.
     */
    function _getRegistry(
        address _token
    ) private view returns (ISharesRegistry) {
        return ISharesRegistry(shareRegistryInfo[_token].deployedAt);
    }

    /**
     * @notice Gets the Holding Manager Contract.
     * @dev Returns the address of the Holding Manager Contract from the Manager Contract.
     * @return The Holding Manager Contract.
     */
    function _getHoldingManager() private view returns (IHoldingManager) {
        return IHoldingManager(manager.holdingManager());
    }

    // -- Modifiers --

    /**
     * @notice Ensures the caller is allowed to perform the call.
     *
     * @notice The caller must either be:
     * - Holding Manager Contract, or
     * - Liquidation Manager Contract, or
     * - Strategy Manager Contract.
     */
    modifier onlyAllowed() {
        require(
            msg.sender == manager.holdingManager() || msg.sender == manager.liquidationManager()
                || msg.sender == manager.strategyManager(),
            "1000"
        );
        _;
    }
}
```

## File: src/LiquidationManager.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20, IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

import { IHolding } from "./interfaces/core/IHolding.sol";
import { IHoldingManager } from "./interfaces/core/IHoldingManager.sol";
import { ILiquidationManager } from "./interfaces/core/ILiquidationManager.sol";
import { IManager } from "./interfaces/core/IManager.sol";

import { ISharesRegistry } from "./interfaces/core/ISharesRegistry.sol";
import { IStablesManager } from "./interfaces/core/IStablesManager.sol";
import { IStrategy } from "./interfaces/core/IStrategy.sol";
import { IStrategyManager } from "./interfaces/core/IStrategyManager.sol";
import { ISwapManager } from "./interfaces/core/ISwapManager.sol";

/**
 * @title LiquidationManager
 *
 * @notice Manages the liquidation and self-liquidation processes.
 *
 * @dev Self-liquidation enables solvent user to repay their stablecoin debt using their own collateral, freeing up
 * remaining collateral without attracting additional funds.
 * @dev Liquidation is a process initiated by a third party (liquidator) to liquidate  an insolvent user's
 * stablecoin debt. The liquidator uses their funds (stablecoin) in exchange for the user's collateral, plus a
 * liquidator's bonus.
 *
 * @dev This contract inherits functionalities from `Ownable2Step`, `Pausable`, `ReentrancyGuard.
 *
 * @author Hovooo (@hovooo), Cosmin Grigore (@gcosmintech).
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract LiquidationManager is ILiquidationManager, Ownable2Step, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /**
     * @notice The self-liquidation fee.
     * @dev Uses 3 decimal precision, where 1% is represented as 1000.
     * @dev 8% is the default self-liquidation fee.
     */
    uint256 public override selfLiquidationFee = 8e3;

    /**
     * @notice The max % amount the protocol gets when a self-liquidation operation happens.
     * @dev Uses 3 decimal precision, where 1% is represented as 1000.
     * @dev 10% is the max self-liquidation fee.
     */
    uint256 public constant override MAX_SELF_LIQUIDATION_FEE = 10e3;

    /**
     * @notice utility variable used for preciser computations.
     */
    uint256 public constant override LIQUIDATION_PRECISION = 1e5;

    /**
     * @notice Contract that contains all the necessary configs of the protocol.
     */
    IManager public override manager;

    // -- Constructor --

    /**
     * @notice Creates a new LiquidationManager contract.
     * @param _initialOwner The initial owner of the contract.
     * @param _manager Contract that holds all the necessary configs of the protocol.
     */
    constructor(address _initialOwner, address _manager) Ownable(_initialOwner) {
        require(_manager != address(0), "3065");
        manager = IManager(_manager);
    }

    // -- User specific methods --

    /**
     * @notice This function allows a user to self-liquidate by repaying their jUSD debt using their own collateral. The
     * function ensures the user is solvent, calculates the required collateral, handles collateral retrieval from
     * strategies if needed, and performs the necessary swaps and transfers.
     *
     * @notice Requirements:
     * - `msg.sender` must have holding.
     * - `msg.sender` must be solvent.
     * - There should be enough liquidity in jUSD pool.
     * - `_jUsdAmount` must be <= user's borrowed amount.
     *
     * @notice Effects:
     * - Retrieves collateral from specified strategies if needed.
     * - Swaps user's collateral to required `_jUsdAmount`.
     * - Sends fees to `feeAddress`.
     * - Repays user's debt in the amount of `jUsdAmountRepaid`.
     * - Removes used `collateralUsed` from `holding`.
     *
     * @notice Emits:
     * - `SelfLiquidated` event indicating self-liquidation.
     *
     * @param _collateral address of the token used as collateral for borrowing.
     * @param _jUsdAmount to repay.
     * @param _swapParams used for the swap operation: swap path, maximum input amount, and slippage percentage.
     * @param _strategiesParams data for strategies to retrieve collateral from.
     *
     * @return collateralUsed for self-liquidation.
     * @return jUsdAmountRepaid amount repaid.
     */
    function selfLiquidate(
        address _collateral,
        uint256 _jUsdAmount,
        SwapParamsCalldata calldata _swapParams,
        StrategiesParamsCalldata calldata _strategiesParams
    )
        external
        override
        nonReentrant
        whenNotPaused
        validAddress(_collateral)
        validAmount(_jUsdAmount)
        returns (uint256 collateralUsed, uint256 jUsdAmountRepaid)
    {
        // Initialize self-liquidation temporary data struct.
        SelfLiquidateTempData memory tempData = SelfLiquidateTempData({
            holdingManager: _getHoldingManager(),
            stablesManager: _getStablesManager(),
            swapManager: _getSwapManager(),
            holding: address(0),
            isRegistryActive: false,
            registryAddress: address(0),
            totalBorrowed: 0,
            totalAvailableCollateral: 0,
            totalRequiredCollateral: 0,
            totalSelfLiquidatableCollateral: 0,
            totalFeeCollateral: 0,
            jUsdAmountToBurn: 0,
            exchangeRate: 0,
            collateralInStrategies: 0,
            swapPath: _swapParams.swapPath,
            deadline: _swapParams.deadline,
            amountInMaximum: _swapParams.amountInMaximum,
            slippagePercentage: _swapParams.slippagePercentage,
            useHoldingBalance: _strategiesParams.useHoldingBalance,
            strategies: _strategiesParams.strategies,
            strategiesData: _strategiesParams.strategiesData
        });

        // Get precision for computations.
        uint256 precision = LIQUIDATION_PRECISION;

        // Get user's holding.
        tempData.holding = tempData.holdingManager.userHolding(msg.sender);

        // Ensure that user has a holding account in the system.
        require(tempData.holdingManager.isHolding(tempData.holding), "3002");

        // Ensure collateral registry is active.
        (tempData.isRegistryActive, tempData.registryAddress) = tempData.stablesManager.shareRegistryInfo(_collateral);
        require(tempData.isRegistryActive, "1200");

        // Ensure user is solvent.
        tempData.totalBorrowed = ISharesRegistry(tempData.registryAddress).borrowed(tempData.holding);
        require(tempData.stablesManager.isSolvent({ _token: _collateral, _holding: tempData.holding }), "3075");

        // Ensure self-liquidation amount <= borrowed.
        tempData.jUsdAmountToBurn = _jUsdAmount;
        require(tempData.jUsdAmountToBurn <= tempData.totalBorrowed, "2003");

        // Calculate the collateral required for self-liquidation.
        tempData.exchangeRate = ISharesRegistry(tempData.registryAddress).getExchangeRate();
        tempData.totalRequiredCollateral =
            _getCollateralForJUsd(_collateral, tempData.jUsdAmountToBurn, tempData.exchangeRate);

        // Ensure that amountInMaximum is within acceptable range specified by user.
        // See the interface for specs on `slippagePercentage`.

        // Ensure safe computation.
        require(_swapParams.slippagePercentage <= precision, "3081");
        if (
            tempData.amountInMaximum
                > tempData.totalRequiredCollateral
                    + tempData.totalRequiredCollateral.mulDiv(_swapParams.slippagePercentage, precision)
        ) {
            revert("3078");
        }

        // Calculate the self-liquidation fee amount.
        tempData.totalFeeCollateral = tempData.amountInMaximum.mulDiv(selfLiquidationFee, precision, Math.Rounding.Ceil);
        // Calculate the total self-liquidatable collateral required to perform self-liquidation.
        tempData.totalSelfLiquidatableCollateral = tempData.amountInMaximum + tempData.totalFeeCollateral;

        // Retrieve collateral from strategies if needed.
        if (tempData.strategies.length > 0) {
            tempData.collateralInStrategies = _retrieveCollateral({
                _token: _collateral,
                _holding: tempData.holding,
                _amount: tempData.totalSelfLiquidatableCollateral,
                _strategies: tempData.strategies,
                _strategiesData: tempData.strategiesData,
                useHoldingBalance: tempData.useHoldingBalance
            });
        }

        // Set totalAvailableCollateral equal to retrieved collateral or holding's balance as user's specified.
        tempData.totalAvailableCollateral = !tempData.useHoldingBalance
            ? tempData.collateralInStrategies
            : IERC20Metadata(_collateral).balanceOf(tempData.holding);

        // Ensure there's enough available collateral to execute self-liquidation with specified amounts.
        require(tempData.totalAvailableCollateral >= tempData.totalSelfLiquidatableCollateral, "3076");

        // Swap collateral for jUSD.
        uint256 collateralUsedForSwap = tempData.swapManager.swapExactOutputMultihop({
            _tokenIn: _collateral,
            _swapPath: tempData.swapPath,
            _userHolding: tempData.holding,
            _deadline: tempData.deadline,
            _amountOut: tempData.jUsdAmountToBurn,
            _amountInMaximum: tempData.amountInMaximum
        });

        // Compute the final fee amount (if any) to be paid for performing self-liquidation.
        uint256 finalFeeCollateral = collateralUsedForSwap.mulDiv(selfLiquidationFee, precision, Math.Rounding.Ceil);

        // Transfer fees to fee address.
        if (finalFeeCollateral != 0) {
            IHolding(tempData.holding).transfer({
                _token: _collateral,
                _to: manager.feeAddress(),
                _amount: finalFeeCollateral
            });
        }

        // Save the jUSD amount that has been repaid.
        jUsdAmountRepaid = tempData.jUsdAmountToBurn;
        // Save the amount of collateral that has been used to repay jUSD.
        collateralUsed = collateralUsedForSwap + finalFeeCollateral;

        // Repay debt with jUsd obtained from Uniswap.
        tempData.stablesManager.repay({
            _holding: tempData.holding,
            _token: _collateral,
            _amount: jUsdAmountRepaid,
            _burnFrom: tempData.holding
        });

        // Remove collateral from holding.
        tempData.stablesManager.removeCollateral({
            _holding: tempData.holding,
            _token: _collateral,
            _amount: collateralUsed
        });

        // Emit event indicating self-liquidation.
        emit SelfLiquidated({
            holding: tempData.holding,
            token: _collateral,
            amount: jUsdAmountRepaid,
            collateralUsed: collateralUsed
        });
    }

    /**
     * @notice Method used to liquidate stablecoin debt if a user is no longer solvent.
     *
     * @notice Requirements:
     * - `_user` must have holding.
     * - `_user` must be insolvent.
     * - `msg.sender` must have jUSD.
     * - `_jUsdAmount` must be <= user's borrowed amount
     *
     * @notice Effects:
     * - Retrieves collateral from specified strategies if needed.
     * - Sends the liquidator their bonus and underlying collateral.
     * - Repays user's debt in the amount of `_jUsdAmount`.
     * - Removes used `collateralUsed` from `holding`.
     *
     * @notice Emits:
     * - `Liquidated` event indicating liquidation.
     *
     * @param _user address whose holding is to be liquidated.
     * @param _collateral token used for borrowing.
     * @param _jUsdAmount to repay.
     * @param _minCollateralReceive amount of collateral the liquidator wants to get.
     * @param _data for strategies to retrieve collateral from in case the Holding balance is not enough.
     *
     * @return collateralUsed The amount of collateral used for liquidation.
     */
    function liquidate(
        address _user,
        address _collateral,
        uint256 _jUsdAmount,
        uint256 _minCollateralReceive,
        LiquidateCalldata calldata _data
    )
        external
        override
        nonReentrant
        whenNotPaused
        validAddress(_collateral)
        validAmount(_jUsdAmount)
        returns (uint256 collateralUsed)
    {
        // Get protocol's required contracts to interact with.
        IHoldingManager holdingManager = _getHoldingManager();
        IStablesManager stablesManager = _getStablesManager();

        // Get address of the user's Holding involved in liquidation.
        address holding = holdingManager.userHolding(_user);
        // Get configs for collateral used for liquidation.
        (bool isRegistryActive, address registryAddress) = stablesManager.shareRegistryInfo(_collateral);

        // Perform sanity checks.
        require(isRegistryActive, "1200");
        require(holdingManager.isHolding(holding), "3002");
        require(_jUsdAmount <= ISharesRegistry(registryAddress).borrowed(holding), "2003");
        require(stablesManager.isLiquidatable({ _token: _collateral, _holding: holding }), "3073");

        // Calculate collateral required for the specified `_jUsdAmount`.
        collateralUsed = _getCollateralForJUsd({
            _collateral: _collateral,
            _jUsdAmount: _jUsdAmount,
            _exchangeRate: ISharesRegistry(registryAddress).getExchangeRate()
        });

        // Update the required collateral amount if there's liquidator bonus.
        collateralUsed += _user == msg.sender
            ? 0
            : collateralUsed.mulDiv(
                ISharesRegistry(registryAddress).getConfig().liquidatorBonus, LIQUIDATION_PRECISION, Math.Rounding.Ceil
            );

        // If strategies are provided, retrieve collateral from strategies if needed.
        if (_data.strategies.length > 0) {
            _retrieveCollateral({
                _token: _collateral,
                _holding: holding,
                _amount: collateralUsed,
                _strategies: _data.strategies,
                _strategiesData: _data.strategiesData,
                useHoldingBalance: true
            });
        }

        // Check whether the holding actually has enough collateral to pay liquidator bonus.
        collateralUsed = Math.min(IERC20(_collateral).balanceOf(holding), collateralUsed);

        // Ensure the liquidator will receive at least as much collateral as expected when sending the tx.
        require(collateralUsed >= _minCollateralReceive, "3097");

        // Emit event indicating successful liquidation.
        emit Liquidated({ holding: holding, token: _collateral, amount: _jUsdAmount, collateralUsed: collateralUsed });

        // Repay user's debt with jUSD owned by the liquidator.
        stablesManager.repay({ _holding: holding, _token: _collateral, _amount: _jUsdAmount, _burnFrom: msg.sender });
        // Remove collateral from holding.
        stablesManager.forceRemoveCollateral({ _holding: holding, _token: _collateral, _amount: collateralUsed });
        // Send the liquidator the freed up collateral and bonus.
        IHolding(holding).transfer({ _token: _collateral, _to: msg.sender, _amount: collateralUsed });
    }

    /**
     * @notice Method used to liquidate positions with bad debt (where collateral value is less than borrowed amount).
     *
     * @notice Requirements:
     * - Only owner can call this function.
     * - `_user` must have holding.
     * - Holding must have bad debt (collateral value < borrowed amount).
     * - All strategies associated with the holding must be provided.
     *
     * @notice Effects:
     * - Retrieves collateral from specified strategies.
     * - Repays user's total debt with jUSD from msg.sender.
     * - Removes all remaining collateral from holding.
     * - Transfers all remaining collateral to msg.sender.
     *
     * @notice Emits:
     * - `CollateralRetrieved` event for each strategy collateral is retrieved from.
     *
     * @param _user Address whose holding is to be liquidated.
     * @param _collateral Token used for borrowing.
     * @param _data Struct containing arrays of strategies and their associated data for retrieving collateral.
     */
    function liquidateBadDebt(
        address _user,
        address _collateral,
        LiquidateCalldata calldata _data
    ) external override nonReentrant whenNotPaused onlyOwner validAddress(_collateral) {
        // Get protocol's required contracts to interact with.
        IHoldingManager holdingManager = _getHoldingManager();
        IStablesManager stablesManager = _getStablesManager();

        // Get address of the user's Holding involved in liquidation.
        address holding = holdingManager.userHolding(_user);
        // Get configs for collateral used for liquidation.
        (bool isRegistryActive, address registryAddress) = stablesManager.shareRegistryInfo(_collateral);

        // Perform sanity checks.
        require(isRegistryActive, "1200");
        require(holdingManager.isHolding(holding), "3002");

        uint256 totalBorrowed = ISharesRegistry(registryAddress).borrowed(holding);
        uint256 totalCollateral = ISharesRegistry(registryAddress).collateral(holding);

        // If strategies are provided, retrieve collateral from strategies if needed.
        if (_data.strategies.length > 0) {
            _retrieveCollateral({
                _token: _collateral,
                _holding: holding,
                _amount: totalCollateral,
                _strategies: _data.strategies,
                _strategiesData: _data.strategiesData,
                useHoldingBalance: true
            });
        }
        // Update total collateral after retrieving from strategies
        totalCollateral = ISharesRegistry(registryAddress).collateral(holding);

        // Verify holding has bad debt
        if (
            totalCollateral
                >= _getCollateralForJUsd({
                    _collateral: _collateral,
                    _jUsdAmount: totalBorrowed,
                    _exchangeRate: ISharesRegistry(registryAddress).getExchangeRate()
                })
        ) revert("3099");

        // Emit event indicating successful liquidation of bad debt .
        emit BadDebtLiquidated({
            holding: holding,
            token: _collateral,
            amount: totalBorrowed,
            collateralUsed: totalCollateral
        });

        // Repay user's debt with jUSD
        stablesManager.repay({ _holding: holding, _token: _collateral, _amount: totalBorrowed, _burnFrom: msg.sender });
        // Remove collateral from holding.
        stablesManager.forceRemoveCollateral({ _holding: holding, _token: _collateral, _amount: totalCollateral });
        // Send the liquidator the freed up collateral and bonus.
        IHolding(holding).transfer({ _token: _collateral, _to: msg.sender, _amount: totalCollateral });
    }

    // -- Administration --

    /**
     * @notice Sets a new value for the self-liquidation fee.
     * @dev The value must be less than MAX_SELF_LIQUIDATION_FEE.
     * @param _val The new value for the self-liquidation fee.
     */
    function setSelfLiquidationFee(
        uint256 _val
    ) external override onlyOwner {
        require(_val <= MAX_SELF_LIQUIDATION_FEE, "3066");
        emit SelfLiquidationFeeUpdated(selfLiquidationFee, _val);
        selfLiquidationFee = _val;
    }

    /**
     * @notice Triggers stopped state.
     */
    function pause() external override onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     */
    function unpause() external override onlyOwner whenPaused {
        _unpause();
    }

    /**
     * @notice Renounce ownership override to avoid losing contract's ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }

    // -- Private methods --

    /**
     * @notice This function calculates the amount of collateral needed to match a given jUSD amount based on the
     * provided exchange rate.
     *
     * @param _collateral address of the collateral token.
     * @param _jUsdAmount amount of jUSD.
     * @param _exchangeRate collateral to jUSD.
     *
     * @return totalCollateral The total amount of collateral required.
     */
    function _getCollateralForJUsd(
        address _collateral,
        uint256 _jUsdAmount,
        uint256 _exchangeRate
    ) private view returns (uint256 totalCollateral) {
        uint256 EXCHANGE_RATE_PRECISION = manager.EXCHANGE_RATE_PRECISION();
        // Calculate collateral amount based on its USD value.
        totalCollateral = _jUsdAmount.mulDiv(EXCHANGE_RATE_PRECISION, _exchangeRate, Math.Rounding.Ceil);

        // Adjust collateral amount in accordance with current jUSD price.
        totalCollateral =
            totalCollateral.mulDiv(manager.getJUsdExchangeRate(), EXCHANGE_RATE_PRECISION, Math.Rounding.Ceil);

        // Perform sanity check to avoid miscalculations.
        require(totalCollateral > 0, "3079");

        // Transform from 18 decimals to collateral's decimals
        uint256 collateralDecimals = IERC20Metadata(_collateral).decimals();
        if (collateralDecimals > 18) totalCollateral = totalCollateral * (10 ** (collateralDecimals - 18));
        else if (collateralDecimals < 18) totalCollateral = totalCollateral.ceilDiv(10 ** (18 - collateralDecimals));
    }

    /**
     * @notice Method used to force withdraw from strategies. If `useHoldingBalance` is set to true
     * and the holding has enough balance, strategies are ignored.
     *
     * @param _token address to retrieve.
     * @param _holding address from which to retrieve collateral.
     * @param _amount of collateral to retrieve.
     * @param _strategies array from which to retrieve collateral.
     * @param _strategiesData array of data associated with each strategy.
     * @param useHoldingBalance boolean indicating whether to use the holding balance.
     *
     * @return The amount of collateral retrieved.
     */
    function _retrieveCollateral(
        address _token,
        address _holding,
        uint256 _amount,
        address[] memory _strategies,
        bytes[] memory _strategiesData,
        bool useHoldingBalance
    ) private returns (uint256) {
        CollateralRetrievalData memory tempData =
            CollateralRetrievalData({ retrievedCollateral: 0, shares: 0, withdrawResult: 0 });

        // Ensure the holding doesn't already have enough collateral.
        if (useHoldingBalance) if (IERC20(_token).balanceOf(_holding) >= _amount) return _amount;

        // Ensure that extra data for strategies is provided correctly.
        require(_strategies.length == _strategiesData.length, "3026");

        // Iterate over sent strategies and retrieve collateral.
        for (uint256 i = 0; i < _strategies.length; i++) {
            (, tempData.shares) = IStrategy(_strategies[i]).recipients(_holding);

            // Withdraw collateral.
            (tempData.withdrawResult,,,) = _getStrategyManager().claimInvestment({
                _holding: _holding,
                _token: _token,
                _strategy: _strategies[i],
                _shares: tempData.shares,
                _data: _strategiesData[i]
            });

            // Update amount of retrieved collateral.
            tempData.retrievedCollateral += tempData.withdrawResult;

            // Emit event indicating collateral retrieval.
            emit CollateralRetrieved(_token, _holding, _strategies[i], tempData.withdrawResult);

            // Continue withdrawing from strategies only if the required amount has not been reached yet
            if (useHoldingBalance && IERC20(_token).balanceOf(_holding) >= _amount) break;
        }

        // Return the amount of retrieved collateral.
        return tempData.retrievedCollateral;
    }

    /**
     * @notice Utility function do get available StablesManager Contract.
     */
    function _getStablesManager() private view returns (IStablesManager) {
        return IStablesManager(manager.stablesManager());
    }

    /**
     * @notice Utility function do get available HoldingManager Contract.
     */
    function _getHoldingManager() private view returns (IHoldingManager) {
        return IHoldingManager(manager.holdingManager());
    }

    /**
     * @notice Utility function do get available SwapManager Contract.
     */
    function _getSwapManager() private view returns (ISwapManager) {
        return ISwapManager(manager.swapManager());
    }

    /**
     * @notice Utility function do get available StrategyManager Contract.
     */
    function _getStrategyManager() private view returns (IStrategyManager) {
        return IStrategyManager(manager.strategyManager());
    }

    // -- Modifiers --

    /**
     * @notice Modifier to ensure that the provided address is valid (not the zero address).
     * @param _address The address to validate
     */
    modifier validAddress(
        address _address
    ) {
        require(_address != address(0), "3000");
        _;
    }

    /**
     * @notice Modifier to ensure that the provided amount is valid (greater than zero).
     * @param _amount The amount to validate
     */
    modifier validAmount(
        uint256 _amount
    ) {
        require(_amount > 0, "2001");
        _;
    }
}
```
