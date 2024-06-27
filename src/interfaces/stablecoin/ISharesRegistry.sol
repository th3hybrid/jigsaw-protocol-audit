// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IOracle} from "../oracle/IOracle.sol";
import {IManagerContainer} from "../core/IManagerContainer.sol";

/// @title Interface for SharesRegistry contract
/// @author Cosmin Grigore (@gcosmintech)
/// @dev based on MIM CauldraonV2 contract
interface ISharesRegistry {
    /// @notice event emitted when contract new ownership is accepted
    event OwnershipAccepted(address indexed newOwner);
    /// @notice event emitted when contract ownership transferal was initated
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    /// @notice event emitted when collateral was registered
    event CollateralAdded(address indexed user, uint256 share);
    /// @notice event emitted when collateral was unregistered
    event CollateralRemoved(address indexed user, uint256 share);
    /// @notice event emitted when the collateralization rate is updated
    event CollateralizationRateUpdated(uint256 oldVal, uint256 newVal);
    /// @notice event emitted when accrue was called
    event Accrued(uint256 updatedTotalBorrow, uint256 extraAmount);
    /// @notice oracle data updated
    event OracleDataUpdated();
    /// @notice emitted when new oracle data is requested
    event NewOracleDataRequested(bytes newData);
    /// @notice emitted when new oracle is requested
    event NewOracleRequested(address newOracle);
    /// @notice oracle updated
    event OracleUpdated();
    /// @notice event emitted when borrowed amount is set
    event BorrowedSet(address indexed _holding, uint256 oldVal, uint256 newVal);
    // @notice event emitted when timelock amount is updated
    event TimelockAmountUpdated(uint256 oldVal, uint256 newVal);
    // @notice event emitted when a new timelock amount is requested
    event TimelockAmountUpdateRequested(uint256 oldVal, uint256 newVal);
    /// @notice event emitted when interest per second is updated
    event InterestUpdated(uint256 oldVal, uint256 newVal);

    /// @notice accure info data
    struct AccrueInfo {
        uint64 lastAccrued;
        uint128 feesEarned;
        // solhint-disable-next-line var-name-mixedcase
        uint64 INTEREST_PER_SECOND;
    }

    /// @notice borrowed amount for holding; holding > amount
    function borrowed(address _holding) external view returns (uint256);

    /// @notice info about the accrued data
    function accrueInfo() external view returns (uint64, uint128, uint64);

    /// @notice current timelock amount
    function timelockAmount() external view returns (uint256);

    /// @notice current owner
    function owner() external view returns (address);

    /// @notice possible new owner
    /// @dev if different than `owner` an ownership transfer is in  progress and has to be accepted by the new
    /// owner
    function temporaryOwner() external view returns (address);

    /// @notice interface of the manager container contract
    function managerContainer() external view returns (IManagerContainer);

    /// @notice returns the token address for which this registry was created
    function token() external view returns (address);

    /// @notice oracle contract associated with this share registry
    function oracle() external view returns (IOracle);

    /// @notice returns the up to date exchange rate
    function getExchangeRate() external view returns (uint256);

    /// @notice updates the colalteralization rate
    /// @param _newVal the new value
    function setCollateralizationRate(uint256 _newVal) external;

    /// @notice collateralization rate for token
    // solhint-disable-next-line func-name-mixedcase
    function collateralizationRate() external view returns (uint256);

    /// @notice returns the collateral shares for user
    /// @param _user the address for which the query is performed
    function collateral(address _user) external view returns (uint256);

    /// @notice requests a change for the oracle address
    /// @param _oracle the new oracle address
    function requestNewOracle(address _oracle) external;

    /// @notice sets new oracle for the oracle address
    function setOracle() external;

    /// @notice sets new interest per second
    /// @param _newVal the new value
    function setInterestPerSecond(uint64 _newVal) external;

    /// @notice requests a timelock update
    /// @param _newVal the new value in seconds
    function requestTimelockAmountChange(uint256 _newVal) external;

    /// @notice updates the timelock amount
    function acceptTimelockAmountChange() external;

    /// @notice requests a change for oracle data
    /// @param _data the new data
    function requestNewOracleData(bytes calldata _data) external;

    /// @notice sets a new value for borrowed
    /// @param _holding the address of the user
    /// @param _newVal the new amount
    function setBorrowed(address _holding, uint256 _newVal) external;

    /// @notice updates the AccrueInfo object
    /// @param _totalBorrow total borrow amount
    function accrue(uint256 _totalBorrow) external returns (uint256);

    /// @notice registers collateral for token
    /// @param _holding the user's address for which collateral is registered
    /// @param _share amount of shares
    function registerCollateral(address _holding, uint256 _share) external;

    /// @notice registers a collateral removal operation
    /// @param _holding the address of the user
    /// @param _share the new collateral shares
    function unregisterCollateral(address _holding, uint256 _share) external;

    /// @notice initiates the ownership transferal
    /// @param _newOwner the address of the new owner
    function transferOwnership(address _newOwner) external;

    /// @notice finalizes the ownership transferal process
    /// @dev must be called after `transferOwnership` was executed successfully, by the new temporary onwer
    function acceptOwnership() external;
}
