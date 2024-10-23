// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import {StorageKey} from "src/types/CustomTypes.sol";

/// @dev This interface is forked from the uniswap-v4-core repository
interface IExtsload {
    /// @notice Called by external contracts to access granular pool state
    /// @param slot Key of slot to sload
    /// @return value The value of the slot as bytes32
    function extsload(StorageKey slot) external view returns (bytes32 value);

    /// @notice Called by external contracts to access granular pool state
    /// @param slot Key of slot to start sloading from
    /// @param nSlots Number of slots to load into return value
    /// @return value The value of the sload-ed slots concatenated as dynamic bytes
    function extsload(StorageKey slot, uint256 nSlots) external view returns (bytes memory value);

    /// @notice Called by external contracts to access sparse pool state
    /// @param slots List of slots to SLOAD from.
    /// @return values List of loaded values.
    function extsload(StorageKey[] calldata slots) external view returns (bytes32[] memory values);
}
