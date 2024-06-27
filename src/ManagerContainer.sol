// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import { IManagerContainer } from "./interfaces/core/IManagerContainer.sol";

/**
 * @title Swap Manager
 *
 * @notice This contract stores up-to-date address of the Manager Contract.
 *
 * @dev This contract inherits functionalities from `Ownable`.
 *
 * @author Hovooo (@hovooo), Cosmin Grigore (@gcosmintech).
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract ManagerContainer is IManagerContainer, Ownable {
    /**
     * @notice Returns the address of the Manager Contract.
     */
    address public override manager;

    /**
     * @notice Creates a new ManagerContainer Contract.
     * @param _manager The address of the Manager Contract.
     */
    constructor(address _manager) {
        require(_manager != address(0), "3000");
        manager = _manager;
    }

    /**
     * @notice Updates the Manager Contract's address.
     *
     * @notice Requirements:
     * - `_newManager` should be non zero address.
     * - `_newManager` should be different from old Manager address.
     *
     * @notice Effects:
     * - Updates the `manager` state variable.
     *
     * @notice Emits:
     * - `ManagerUpdated` event indicating successful Manager update operation.
     *
     * @param _newManager The new address of the Manager contract.
     */
    function updateManager(address _newManager) external override onlyOwner {
        require(_newManager != address(0), "3003");
        require(_newManager != manager, "3062");
        emit ManagerUpdated(manager, _newManager);
        manager = _newManager;
    }

    /**
     * @notice Override to avoid losing contract ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }
}
