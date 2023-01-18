// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.17;

/// @dev Core dependencies.
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract NBMultiBalancePoints {
    /// @dev The schema of node in the authority graph.
    struct Node {
        IERC1155 badge;
        uint256 id;
        uint256 balance;
        uint256 points;
    }

    ////////////////////////////////////////////////////////
    ///                      STATE                       ///
    ////////////////////////////////////////////////////////

    /// @dev The number of required badges to access a function.
    uint256 public required;

    /// @dev The nodes that make up the authority.
    Node[] public nodes;

    ////////////////////////////////////////////////////////
    ///                INTERNAL SETTERS                  ///
    ////////////////////////////////////////////////////////

    /**
     * @dev Allows the authorized owner to update the required badges.
     * @param _required The new required badges.
     */
    function _setRequired(uint256 _required) internal {
        required = _required;
    }

    /**
     * @dev Allows the authorized owner to update the nodes.
     * @param _nodes The new nodes.
     */
    function _setNodes(Node[] memory _nodes) internal {
        nodes = _nodes;
    }

    ////////////////////////////////////////////////////////
    ///                 INTERNAL GETTERS                 ///
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
        /// @dev Load in the stack.
        uint256 points;
        uint256 i;

        /// @dev Get the node at the current index.
        Node memory node = nodes[0];

        /// @dev Determine if the user has met the proper conditions of access.
        for (i; i < nodes.length; i++) {
            /// @dev Step through the nodes until we have enough points or we run out.
            node = nodes[i];

            /// @dev If the user has sufficient balance, account for 1 points.
            if (node.badge.balanceOf(user, node.id) >= node.balance)
                points += node.points;

            /// @dev If enough points have been accumulated, return true.
            if (points >= required) i = nodes.length;

            /// @dev Keep on swimming.
        }

        /// @dev Final check if no mandatory badges had an insufficient balance.
        return points >= required;
    }
}
