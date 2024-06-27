// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IManager } from "../interfaces/core/IManager.sol";
import { IManagerContainer } from "../interfaces/core/IManagerContainer.sol";
import { IStablesManager } from "../interfaces/core/IStablesManager.sol";
import { IOracle } from "../interfaces/oracle/IOracle.sol";
import { ISharesRegistry } from "../interfaces/stablecoin/ISharesRegistry.sol";

/**
 * @title SharesRegistry
 *
 * @notice Registers, manages and tracks assets used as collaterals within the Jigsaw Protocol.
 *
 * @author Hovooo (@hovooo), Cosmin Grigore (@gcosmintech).
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract SharesRegistry is ISharesRegistry {
    /**
     * @notice Returns holding's borrowed amount.
     */
    mapping(address holding => uint256 amount) public override borrowed;

    /**
     * @notice Returns holding's available collateral amount.
     */
    mapping(address holding => uint256 amount) public override collateral;

    /**
     * @notice Returns the token address for which this registry was created.
     */
    address public immutable override token;

    /**
     * @notice Collateralization rate for token.
     */
    uint256 public override collateralizationRate;

    /**
     * @notice Returns the address of the manager container contract.
     */
    IManagerContainer public immutable override managerContainer;

    /**
     * @notice Current owner.
     */
    address public override owner;

    /**
     * @notice Possible new owner.
     * @dev If different than `owner` an ownership transfer is in progress and has to be accepted by the new owner.
     */
    address public override temporaryOwner;

    /**
     * @notice Info about the accrued data.
     */
    AccrueInfo public override accrueInfo;

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
    uint256 public override timelockAmount = 2 days; // 2 days by default
    uint256 private _oldTimelock;
    uint256 private _newTimelock;
    uint256 private _newTimelockTimestamp;

    bool private _isOracleActiveChange = false;
    bool private _isOracleDataActiveChange = false;
    bool private _isTimelockActiveChange = false;

    /**
     * @notice Minimal collateralization rate acceptable for registry to avoid computational errors.
     * @dev 20e3 means 20% LTV.
     */
    uint256 private immutable minCR = 20e3;

    /**
     * @notice Creates a SharesRegistry for a specific token.
     *
     * @param _owner The owner of the contract.
     * @param _managerContainer Contract that contains the address of the manager contract.
     * @param _token The address of the token contract, used as a collateral within this contract.
     * @param _oracle The oracle used to retrieve price data for the `_token`.
     * @param _oracleData Extra data for the oracle.
     * @param _collateralizationRate Collateralization value.
     */
    constructor(
        address _owner,
        address _managerContainer,
        address _token,
        address _oracle,
        bytes memory _oracleData,
        uint256 _collateralizationRate
    ) {
        require(_owner != address(0), "3032");
        require(_managerContainer != address(0), "3065");
        require(_token != address(0), "3001");
        require(_oracle != address(0), "3034");
        require(_collateralizationRate >= minCR, "2001");
        require(_collateralizationRate <= IManager(IManagerContainer(_managerContainer).manager()).PRECISION(), "3066");

        owner = _owner;
        token = _token;
        oracle = IOracle(_oracle);
        oracleData = _oracleData;
        managerContainer = IManagerContainer(_managerContainer);
        collateralizationRate = _collateralizationRate;
    }

    // -- User specific methods --

    /**
     * @notice Updates `_holding`'s borrowed amount.
     *
     * @notice Requirements:
     * - `msg.sender` must be the Stables Manager Contract.
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
    function setBorrowed(address _holding, uint256 _newVal) external override onlyStableManager {
        emit BorrowedSet({ _holding: _holding, oldVal: borrowed[_holding], newVal: _newVal });
        borrowed[_holding] = _newVal;
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
    function registerCollateral(address _holding, uint256 _share) external override onlyStableManager {
        collateral[_holding] += _share;
        emit CollateralAdded({ user: _holding, share: _share });
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
    function unregisterCollateral(address _holding, uint256 _share) external override onlyStableManager {
        if (_share > collateral[_holding]) {
            _share = collateral[_holding];
        }
        collateral[_holding] = collateral[_holding] - _share;
        emit CollateralRemoved(_holding, _share);
    }

    // @todo DELETE ?
    /**
     * @notice Accrues the interest on the borrowed tokens and handles the accumulation of fees.
     *
     * @notice Requirements:
     * - `msg.sender` must be the Stables Manager Contract.
     *
     * @notice Effects:
     * - Updates `collateral` mapping.
     *
     * @notice Emits:
     * - `Accrued`.
     *
     * @param _totalBorrow Total borrow amount.
     */
    function accrue(uint256 _totalBorrow) public override onlyStableManager returns (uint256) {
        AccrueInfo memory _accrueInfo = accrueInfo;
        uint256 elapsedTime = block.timestamp - _accrueInfo.lastAccrued;
        if (elapsedTime == 0) return _totalBorrow;

        _accrueInfo.lastAccrued = uint64(block.timestamp);

        if (_totalBorrow == 0) {
            accrueInfo = _accrueInfo;
            return _totalBorrow;
        }

        uint256 extraAmount = (_totalBorrow * _accrueInfo.INTEREST_PER_SECOND * elapsedTime) / 1e18;

        _totalBorrow += extraAmount;
        _accrueInfo.feesEarned += uint128(extraAmount);

        accrueInfo = _accrueInfo;
        emit Accrued(_totalBorrow, extraAmount);

        return _totalBorrow;
    }

    // -- Administration --

    // @todo DELETE
    /**
     * @notice Sets a new interest per second.
     *
     * @notice Effects:
     * - Updates `accrueInfo` state variable.
     *
     * @notice Emits:
     * - `InterestUpdated` event indicating interest update operation.
     *
     * @param _newVal The new value.
     */
    function setInterestPerSecond(uint64 _newVal) external override onlyOwner {
        emit InterestUpdated(accrueInfo.INTEREST_PER_SECOND, _newVal);
        accrueInfo.INTEREST_PER_SECOND = _newVal;
    }

    /**
     * @notice Updates the collateralization rate.
     *
     * @notice Requirements:
     * - `_newVal` must be greater than or equal to minimal collateralization rate - `minCR`.
     * - `_newVal` must be less than or equal to the precision defined by the manager.
     *
     * @notice Effects:
     * - Updates `collateralizationRate` state variable.
     *
     * @notice Emits:
     * - `CollateralizationRateUpdated` event indicating collateralization rate update operation.
     *
     * @param _newVal The new value.
     */
    function setCollateralizationRate(uint256 _newVal) external override onlyOwner {
        require(_newVal >= minCR, "2001");
        require(_newVal <= IManager(managerContainer.manager()).PRECISION(), "3066");
        emit CollateralizationRateUpdated(collateralizationRate, _newVal);
        collateralizationRate = _newVal;
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
        if (_newOracleTimestamp + timelockAmount > block.timestamp) require(!_isOracleActiveChange, "3093");
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
        require(_newOracleTimestamp + timelockAmount <= block.timestamp, "3066");

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
    function requestNewOracleData(bytes calldata _data) external override onlyOwner {
        if (_newOracleTimestamp + timelockAmount > block.timestamp) require(!_isOracleDataActiveChange, "3096");
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
        require(_newOracleDataTimestamp + timelockAmount <= block.timestamp, "3066");

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
    function requestTimelockAmountChange(uint256 _newVal) external override onlyOwner {
        if (_newTimelockTimestamp + _oldTimelock > block.timestamp) require(!_isTimelockActiveChange, "3095");
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
        require(_newTimelockTimestamp + _oldTimelock <= block.timestamp, "3066");

        timelockAmount = _newTimelock;
        emit TimelockAmountUpdated(_oldTimelock, _newTimelock);
        _oldTimelock = 0;
        _newTimelock = 0;
        _newTimelockTimestamp = 0;
    }

    /**
     * @notice Initiates the ownership transferal.
     *
     * @notice Requirements:
     * - `_newOwner` must be different from the current owner.
     *
     * @notice Effects:
     * - Updates `temporaryOwner` state variable.
     *
     * @notice Emits:
     * - `OwnershipTransferred` event indicating ownership transferal initiation.
     *
     * @param _newOwner The address of the new owner.
     */
    function transferOwnership(address _newOwner) external override onlyOwner {
        require(_newOwner != owner, "3035");
        temporaryOwner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }

    /**
     * @notice Finalizes the ownership transferal process.
     *
     * @notice Requirements:
     * - Must be called after `transferOwnership` was executed successfully, by the new temporary owner.
     * - `msg.sender` must be the temporary owner.
     *
     * @notice Effects:
     * - Updates `owner` state variable.
     * - Updates `temporaryOwner` state variable.
     *
     * @notice Emits:
     * - `OwnershipAccepted` event indicating ownership transferal finalization.
     */
    function acceptOwnership() external override {
        require(msg.sender == temporaryOwner, "1000");
        owner = temporaryOwner;
        emit OwnershipAccepted(temporaryOwner);
        temporaryOwner = address(0);
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

    // -- Modifiers --

    /**
     * @notice Modifier to only allow access to a function by the Stables Manager Contract.
     */
    modifier onlyStableManager() {
        require(msg.sender == IManager(managerContainer.manager()).stablesManager(), "1000");
        _;
    }

    /**
     * @notice Modifier to only allow access to a function by the Owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "1000");
        _;
    }
}
