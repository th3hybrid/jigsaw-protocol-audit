// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @notice common operations
library OperationsLib {
    uint256 internal constant FEE_FACTOR = 10_000;

    /// @notice gets the amount used as a fee
    function getFeeAbsolute(uint256 amount, uint256 fee) internal pure returns (uint256) {
        return (amount * fee) / FEE_FACTOR;
    }

    /// @notice approves token for spending
    function safeApprove(address token, address to, uint256 value) internal {
        (bool successEmtptyApproval,) =
            token.call(abi.encodeWithSelector(bytes4(keccak256("approve(address,uint256)")), to, 0));
        require(successEmtptyApproval, "OperationsLib::safeApprove: approval reset failed");

        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(bytes4(keccak256("approve(address,uint256)")), to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "OperationsLib::safeApprove: approve failed");
    }
}
