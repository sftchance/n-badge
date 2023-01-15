// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.17;

/// @dev Core dependencies.
import {INBModule} from "../interfaces/INBModule.sol";

/// @dev Helpers.
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract NBMultiBalancePoints is INBModule {
    /// @dev The schema of node in the authority graph.
    struct Node {
        IERC1155 badge;
        uint256 id;
        uint256 balance;
        uint256 points;
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
        bytes memory config,
        address user,
        address,
        bytes4
    ) public view returns (bool) {
        /// @dev Load in the stack.
        (
            uint256 required,
            uint256 points,
            uint256 i,
            Node[] memory nodes
        ) = abi.decode(config, (uint256, uint256, uint256, Node[]));

        /// @dev Get the node at the current index.
        Node memory node = nodes[0];

        /// @dev Determine if the user has met the proper conditions of access.
        for (i; i < nodes.length; i++) {
            /// @dev Step through the nodes until we have enough carried or we run out.
            node = nodes[i];

            /// @dev If the user has sufficient balance, account for 1 carried.
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
