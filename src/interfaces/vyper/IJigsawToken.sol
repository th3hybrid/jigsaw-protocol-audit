// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Interface for JigsawToken
/// @author Hovooo (@hovooo)
interface IJigsawToken is IERC20Metadata {
    // Events
    /// @notice event emitted when mining parameters are updated
    event UpdateMiningParameters(uint256 time, uint256 rate, uint256 supply);

    /// @notice event emitted when Minter is set
    event SetMinter(address minter);

    /// @notice event emitted when Admin is set
    event SetAdmin(address admin);

    /// @notice returns current number of tokens in existence (claimed or unclaimed)
    function available_supply() external view returns (uint256);

    /// @notice How much supply is mintable from start timestamp till end timestamp
    /// @param start Start of the time interval (timestamp)
    /// @param end End of the time interval (timestamp)
    /// @return Tokens mintable from `start` till `end`
    function mintable_in_timeframe(uint256 start, uint256 end) external view returns (uint256);

    /// @notice returns current block timestamp
    function block_timestamp() external view returns (uint256);

    /// @notice Update mining rate and supply at the start of the epoch
    /// @dev Callable by any address, but only once per epoch
    /// @notice Total supply becomes slightly larger if this function is called late
    function update_mining_parameters() external;

    /// @notice Get timestamp of the current mining epoch start
    /// while simultaneously updating mining parameters
    /// @return Timestamp of the epoch
    function start_epoch_time_write() external view returns (uint256);

    /// @notice Get timestamp of the next mining epoch start
    /// while simultaneously updating mining parameters
    /// @return Timestamp of the next epoch
    function future_epoch_time_write() external view returns (uint256);

    /// @notice Set the minter address
    /// @dev Only callable once, when minter has not yet been set
    /// @param _minter Address of the minter
    function set_minter(address _minter) external;

    /// @notice Set the new admin.
    /// @dev After all is set up, admin only can change the token name
    /// @param _admin New admin address
    function set_admin(address _admin) external;

    /// @notice Change the token name and symbol to `_name` and `_symbol`
    /// @dev Only callable by the admin account
    /// @param _name New token name
    /// @param _symbol New token symbol
    function set_name(string memory _name, string memory _symbol) external;

    /// @notice Burn `_value` tokens belonging to `msg.sender`
    /// @dev Emits a Transfer event with a destination of 0x00
    /// @param _value The amount that will be burned
    /// @return bool success
    function burn(uint256 _value) external returns (bool);
}
