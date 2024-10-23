// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {StorageKey} from "src/types/CustomTypes.sol";

/// @dev This interface is forked from the uniswap-v4-core repository
interface IExttload {
    /// @notice Called by external contracts to access transient storage of the contract
    /// @param slot Key of slot to tload
    /// @return value The value of the slot as bytes32
    function exttload(StorageKey slot) external view returns (bytes32 value);

    /// @notice Called by external contracts to access sparse transient pool state
    /// @param slots List of slots to tload
    /// @return values List of loaded values
    function exttload(StorageKey[] calldata slots) external view returns (bytes32[] memory values);
}
