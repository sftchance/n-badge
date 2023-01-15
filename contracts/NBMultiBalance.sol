// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.17;

/// @dev Core dependencies.
import {Auth, Authority} from "solmate/src/auth/Auth.sol";

/// @dev Helpers.
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract NBMultiBalance is Auth, Authority {
    /// @dev The schema of node in the authority graph.
    struct Node {
        IERC1155 badge;
        uint8 mandatory;
        uint256 id;
        uint256 balance;
    }

    ////////////////////////////////////////////////////////
    ///                      STATE                       ///
    ////////////////////////////////////////////////////////

    /// @dev The number of required badges to access a function.
    uint256 public immutable required;

    /// @dev The nodes that make up the authority.
    Node[] public nodes;

    /// @dev Initialize the ownership of the contract.
    constructor(uint256 _required) Auth(msg.sender, Authority(address(0))) {
        required = _required;
    }

    ////////////////////////////////////////////////////////
    ///                     SETTERS                      ///
    ////////////////////////////////////////////////////////

    /**
     * @dev Allows the authorized owner of the Credential Scanner to add a node to the authority graph.
     * @param badge The badge to add.
     * @param mandatory The number of required badges.
     * @param id The id of the badge.
     * @param balance The balance of the badge.
     */
    function addNode(
        IERC1155 badge,
        uint8 mandatory,
        uint256 id,
        uint256 balance
    ) public requiresAuth {
        /// @dev Add the node to the graph.
        nodes.push(Node(badge, mandatory, id, balance));
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
        /// @dev Load in the stack.
        uint256 carried;
        uint256 i;

        /// @dev Get the node at the current index.
        Node memory node = nodes[carried];

        /// @dev Determine if the user has met the proper conditions of access.
        for(i; i < nodes.length; i++) {
            /// @dev Step through the nodes until we have enough carried or we run out.
            node = nodes[i];

            /// @dev If the user has sufficient balance, account for 1 carried.
            if(node.badge.balanceOf(user, node.id) >= node.balance) carried++;
            /// @dev If the node is required and balance is insufficient, we can't continue.
            else if(node.mandatory == 1) return false; 

            /// @dev Keep on swimming.
        }

        /// @dev Final check if no mandatory badges had an insufficient balance.
        return carried >= required;
    }
}
