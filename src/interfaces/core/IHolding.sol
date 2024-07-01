// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IManagerContainer } from "./IManagerContainer.sol";

/**
 * @title IHolding
 * @dev Interface for the Holding Contract.
 */
interface IHolding {
    /**
     * @notice Contract that contains the address of the manager contract.
     */
    function managerContainer() external view returns (IManagerContainer);

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
     * @notice Mints Jigsaw Token.
     *
     * @notice Requirements:
     * - The caller must be allowed.
     *
     * @notice Effects:
     * - Calls `mint` on the `_minter` with `_gauge`.
     *
     * @param _minter IMinter address.
     * @param _gauge Gauge to mint for.
     */
    function mint(address _minter, address _gauge) external;

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
    ) external returns (bool success, bytes memory result);
}
