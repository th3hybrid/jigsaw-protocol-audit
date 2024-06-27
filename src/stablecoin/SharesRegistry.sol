// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IOracle} from "../interfaces/oracle/IOracle.sol";
import {IStablesManager} from "../interfaces/core/IStablesManager.sol";
import {IManager} from "../interfaces/core/IManager.sol";
import {ISharesRegistry} from "../interfaces/stablecoin/ISharesRegistry.sol";
import {IManagerContainer} from "../interfaces/core/IManagerContainer.sol";

/// @title SharesRegistry contract
/// @author Cosmin Grigore (@gcosmintech)
// solhint-disable-next-line max-states-count
contract SharesRegistry is ISharesRegistry {
    /// @notice returns the address of the manager container contract
    IManagerContainer public immutable override managerContainer;

    /// @notice collateralization rate for token
    uint256 public override collateralizationRate;

    /// @notice registry token
    address public immutable override token;

    /// @notice current owner
    address public override owner;

    /// @notice possible new owner
    /// @dev if different than `owner` an ownership transfer is in  progress and has to be accepted by the new
    /// owner
    address public override temporaryOwner;

    /// @notice borrowed amount for holding; holding > amount
    mapping(address => uint256) public override borrowed;

    /// @notice total collateral for Holding (Holding=>collateral amount)
    mapping(address => uint256) public override collateral;

    /// @notice info about the accrued data
    AccrueInfo public override accrueInfo;

    /// @notice oracle contract associated with this share registry
    IOracle public override oracle;
    address private _newOracle;
    uint256 private _newOracleTimestamp;

    /// @notice extra oracle data if needed
    bytes public oracleData;
    bytes private _newOracleData;
    uint256 private _newOracleDataTimestamp;

    /// @notice timelock amount in seconds for changing the oracle data
    uint256 public override timelockAmount = 2 * 86400; //2 days by default
    uint256 private _oldTimelock;
    uint256 private _newTimelock;
    uint256 private _newTimelockTimestamp;

    bool private _isOracleActiveChange = false;
    bool private _isOracleDataActiveChange = false;
    bool private _isTimelockActiveChange = false;

    // @notice minimal collateralization rate acceptable for registry to avoid computational errors
    // @dev 20e3 means 20% LTV
    uint256 private immutable minCR = 20e3;

    /// @notice creates a SharesRegistry for a specific token
    /// @param _owner the owner of the contract
    /// @param _managerContainer contract that contains the address of the manager contract
    /// @param _token the parent token of this contract
    /// @param _oracle the oracle used to retrieve price data for this token
    /// @param _oracleData extra data for the oracle
    /// @param _collateralizationRate collateralization value
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
        require(
            _collateralizationRate <= IManager(IManagerContainer(_managerContainer).manager()).PRECISION(),
            "3066"
        );

        owner = _owner;
        token = _token;
        oracle = IOracle(_oracle);
        oracleData = _oracleData;
        managerContainer = IManagerContainer(_managerContainer);
        collateralizationRate = _collateralizationRate;
    }

    // -- Owner specific methods --
    /// @notice requests a change for the oracle address
    /// @param _oracle the new oracle address
    function requestNewOracle(address _oracle) external override onlyOwner {
        // Handle the case when oracle was requested but never set
        if (_newOracleTimestamp + timelockAmount > block.timestamp) {
            require(!_isOracleActiveChange, "3093");
        }
        require(!_isTimelockActiveChange, "3095");
        require(_oracle != address(0), "3000");
        _isOracleActiveChange = true;
        _newOracle = _oracle;
        _newOracleTimestamp = block.timestamp;
        emit NewOracleRequested(_oracle);
    }

    /// @notice updates the oracle
    function setOracle() external onlyOwner {
        require(_isOracleActiveChange, "3094");
        require(_newOracleTimestamp + timelockAmount <= block.timestamp, "3066");
        oracle = IOracle(_newOracle);
        _isOracleActiveChange = false;
        _newOracle = address(0);
        _newOracleTimestamp = 0;
        emit OracleUpdated();
    }

    /// @notice sets an new interest per second
    /// @param _newVal the new value
    function setInterestPerSecond(uint64 _newVal) external onlyOwner {
        emit InterestUpdated(accrueInfo.INTEREST_PER_SECOND, _newVal);
        accrueInfo.INTEREST_PER_SECOND = _newVal;
    }

    /// @notice requests a timelock update
    /// @param _newVal the new value in seconds
    function requestTimelockAmountChange(uint256 _newVal) external onlyOwner {
        // Handle the case when new timelock was requested but never set
        if (_newTimelockTimestamp + _oldTimelock > block.timestamp) {
            require(!_isTimelockActiveChange, "3095");
        }
        require(!_isOracleActiveChange, "3093");
        require(!_isOracleDataActiveChange, "3096");
        require(_newVal != 0, "2001");
        _isTimelockActiveChange = true;
        _oldTimelock = timelockAmount;
        _newTimelock = _newVal;
        _newTimelockTimestamp = block.timestamp;
        emit TimelockAmountUpdateRequested(_oldTimelock, _newTimelock);
    }

    /// @notice updates the timelock amount
    function acceptTimelockAmountChange() external onlyOwner {
        require(_isTimelockActiveChange, "3094");
        require(_newTimelockTimestamp + _oldTimelock <= block.timestamp, "3066");
        timelockAmount = _newTimelock;
        emit TimelockAmountUpdated(_oldTimelock, _newTimelock);
        _oldTimelock = 0;
        _newTimelock = 0;
        _newTimelockTimestamp = 0;
    }

    /// @notice updates the colalteralization rate
    /// @param _newVal the new value
    function setCollateralizationRate(uint256 _newVal) external override onlyOwner {
        require(_newVal >= minCR, "2001");
        require(_newVal <= IManager(managerContainer.manager()).PRECISION(), "3066");
        emit CollateralizationRateUpdated(collateralizationRate, _newVal);
        collateralizationRate = _newVal;
    }

    /// @notice requests a change for oracle data
    /// @param _data the new data
    function requestNewOracleData(bytes calldata _data) external onlyOwner {
        // Handle the case when oracle data was requested but never set
        if (_newOracleTimestamp + timelockAmount > block.timestamp) {
            require(!_isOracleDataActiveChange, "3096");
        }
        require(!_isTimelockActiveChange, "3095");
        _isOracleDataActiveChange = true;
        _newOracleData = _data;
        _newOracleDataTimestamp = block.timestamp;
        emit NewOracleDataRequested(_newOracleData);
    }

    /// @notice updates the oracle data
    function setOracleData() external onlyOwner {
        require(_isOracleDataActiveChange, "3094");
        require(_newOracleDataTimestamp + timelockAmount <= block.timestamp, "3066");
        oracleData = _newOracleData;
        _isOracleDataActiveChange = false;
        delete _newOracleData;
        _newOracleDataTimestamp = 0;
        emit OracleDataUpdated();
    }

    /// @notice initiates the ownership transferal
    /// @param _newOwner the address of the new owner
    function transferOwnership(address _newOwner) external override onlyOwner {
        require(_newOwner != owner, "3035");
        temporaryOwner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }

    /// @notice finalizes the ownership transferal process
    /// @dev must be called after `transferOwnership` was executed successfully, by the new temporary onwer
    function acceptOwnership() external override {
        require(msg.sender == temporaryOwner, "1000");
        owner = temporaryOwner;
        emit OwnershipAccepted(temporaryOwner);
        temporaryOwner = address(0);
    }

    // -- View type methods --
    /// @notice returns the up to date exchange rate
    function getExchangeRate() external view override returns (uint256) {
        (bool updated, uint256 rate) = oracle.peek(oracleData);
        require(updated, "3037");
        require(rate > 0, "2100");

        return rate;
    }

    // -- Write type methods --

    /// @notice sets a new value for borrowed
    /// @param _holding the address of the user
    /// @param _newVal the new amount
    function setBorrowed(address _holding, uint256 _newVal) external override onlyStableManager {
        emit BorrowedSet(_holding, borrowed[_holding], _newVal);
        borrowed[_holding] = _newVal;
    }

    /// @notice registers collateral for user
    /// @param _holding the address of the user
    /// @param _share the new collateral shares
    function registerCollateral(address _holding, uint256 _share) external override onlyStableManager {
        collateral[_holding] += _share;
        emit CollateralAdded(_holding, _share);
    }

    /// @notice registers a collateral removal operation
    /// @param _holding the address of the user
    /// @param _share the new collateral shares
    function unregisterCollateral(address _holding, uint256 _share) external override onlyStableManager {
        if (_share > collateral[_holding]) {
            _share = collateral[_holding];
        }
        collateral[_holding] = collateral[_holding] - _share;
        emit CollateralRemoved(_holding, _share);
    }

    /// @notice Accrues the interest on the borrowed tokens and handles the accumulation of fees.
    /// @param _totalBorrow total borrow amount
    function accrue(uint256 _totalBorrow) public override onlyStableManager returns (uint256) {
        AccrueInfo memory _accrueInfo = accrueInfo;
        // Number of seconds since accrue was called
        uint256 elapsedTime = block.timestamp - _accrueInfo.lastAccrued;
        if (elapsedTime == 0) {
            return _totalBorrow;
        }
        _accrueInfo.lastAccrued = uint64(block.timestamp);

        if (_totalBorrow == 0) {
            accrueInfo = _accrueInfo;
            return _totalBorrow;
        }

        // Accrue interest
        uint256 extraAmount = (_totalBorrow * _accrueInfo.INTEREST_PER_SECOND * elapsedTime) / 1e18;

        _totalBorrow += extraAmount;
        _accrueInfo.feesEarned += uint128(extraAmount);

        accrueInfo = _accrueInfo;
        emit Accrued(_totalBorrow, extraAmount);

        return _totalBorrow;
    }

    modifier onlyStableManager() {
        require(msg.sender == IManager(managerContainer.manager()).stablesManager(), "1000");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "1000");
        _;
    }
}
