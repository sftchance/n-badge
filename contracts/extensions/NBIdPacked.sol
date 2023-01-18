// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.17;

/// @dev Core dependencies.
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract NBIdPacked {
    ////////////////////////////////////////////////////////
    ///                      STATE                       ///
    ////////////////////////////////////////////////////////

    /// @dev The interface of the Badge collection.
    IERC1155 public badge;

    /// @dev The number of bits that are used to store the size of the node.
    /// @dev This means that if your node size is 8, you can only have 32 nodes and
    ///      and a node can have the max value of 255.
    uint256 public nodeSize;

    /// @dev The mask that is used to extract the size of the node.
    /// @dev This is used to extract the value of the node from the node ids.
    ///      For reference, the mask for a node size of 8 is 0xff.
    ///      0xff = 11111111 (8 bits of all 1s)
    ///      0xffff = 1111111111111111 (16 bits of all 1s)
    ///      With this mask we apply it to our shifted numbers and walk across every number.
    ///      If the bit index in our shifted value and mask valued are the same, then it is a 1.
    ///      With the size walked, we then have our value.
    uint256 public nodeMask;

    /// @dev The ids of the Badges that are required to call a function.
    uint256 public nodeIds;

    ////////////////////////////////////////////////////////
    ///                 INTERNAL SETTERS                 ///
    ////////////////////////////////////////////////////////

    /**
     * @dev Set the address of the Badge collection.
     * @param _badge The address of the Badge collection.
     */
    function _setBadge(address _badge) internal {
        /// @dev Go ahead and connect the Badge collection.
        badge = IERC1155(_badge);
    }

    /**
     * @dev Set the size of the node.
     * @notice This is the amount of shift that occurs when traversing token ids.
     */
    function _setNodeSize(uint256 _nodeSize) internal {
        /// @dev Store the size of the node.
        nodeSize = _nodeSize;
    }

    /**
     * @dev Set the mask of the node.
     * @notice This is the mask that is used to extract the value of the node.
     */
    function _setNodeMask(uint256 _nodeMask) internal {
        /// @dev Store the mask of the node.
        nodeMask = _nodeMask;
    }

    /**
     * @dev Set the ids of the badges that will be enforced.
     * @param _nodeIds The ids of the badges that will be enforced.
     */
    function _setNodeIds(uint256 _nodeIds) internal {
        /// @dev Store the ids of the badges that will be enforced.
        nodeIds = _nodeIds;
    }

    ////////////////////////////////////////////////////////
    ///                INTERNAL GETTERS                  ///
    ////////////////////////////////////////////////////////

    /**
     * @dev Determines if a user has the required credentials to call a function.
     * @param user The user to check.
     * @return True if the user has the required credentials, false otherwise.
     */
    function _canCall(
        address user,
        address,
        bytes4
    ) internal view returns (bool) {
        /// @dev Iterate through the node ids.
        for (uint256 i = nodeIds; i != 0; i >>= nodeSize) {
            /// @dev Get the value of the node.
            uint256 value = i & nodeMask;

            /// @dev Check if the user has the required badge.
            if (badge.balanceOf(user, value) == 0) return false;
        }

        /// @dev The user has the required credentials.
        return true;
    }
}
