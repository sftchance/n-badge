// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.17;

/// @dev Core dependencies.
import {Auth, Authority} from "solmate/src/auth/Auth.sol";

/// @dev Helpers.
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract NBIdPacked is Auth, Authority {
    ////////////////////////////////////////////////////////
    ///                      STATE                       ///
    ////////////////////////////////////////////////////////

    /// @dev The interface of the Badge collection.
    IERC1155 public badge;

    /// @dev The ids of the Badges that are required to call a function.
    uint256 public nodeIds;

    /// @dev Initialize the ownership of the contract.
    constructor(address _badge, uint256 _nodeIds)
        Auth(msg.sender, Authority(address(0)))
    {
        /// @dev Go ahead and connect the Badge collection.
        badge = IERC1155(_badge);

        /// @dev Store the ids of the badges that will be enforced.
        nodeIds = _nodeIds;
    }

    ////////////////////////////////////////////////////////
    ///                     SETTERS                      ///
    ////////////////////////////////////////////////////////

    /**
     * @dev Set the address of the Badge collection.
     * @param _badge The address of the Badge collection.
     */
    function setBadge(address _badge) external requiresAuth {
        /// @dev Go ahead and connect the Badge collection.
        badge = IERC1155(_badge);
    }

    /**
     * @dev Set the ids of the badges that will be enforced.
     * @param _nodeIds The ids of the badges that will be enforced.
     */
    function setNodeIds(uint256 _nodeIds) external requiresAuth {
        /// @dev Store the ids of the badges that will be enforced.
        nodeIds = _nodeIds;
    }

    ////////////////////////////////////////////////////////
    ///                     GETTERS                      ///
    ////////////////////////////////////////////////////////

    /**
     * @dev Determines if a user has the required credentials to call a function.
     * @param user The user to check.
     * @return True if the user has the required credentials, false otherwise.
     */
    function canCall(
        address user,
        address,
        bytes4
    ) public view override returns (bool) {
        /// @dev Iterate through the node ids.
        for(
            uint256 i = nodeIds;
            i != 0;
            i >>= 8
        ) {
            /// @dev Get the value of the node.
            uint256 value = i & 0xff;

            /// @dev Check if the user has the required badge.
            if(badge.balanceOf(user, value) == 0) return false;
        }
    
        /// @dev The user has the required credentials.
        return true;
    }
}
