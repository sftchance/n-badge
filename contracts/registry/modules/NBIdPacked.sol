// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.17;

/// @dev Core dependencies.
import {INBModule} from "../interfaces/INBModule.sol";

/// @dev Helpers.
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract NBIdPacked is INBModule {
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
        (IERC1155 badge, uint256 nodeIds) = abi.decode(
            config,
            (IERC1155, uint256)
        );

        /// @dev Iterate through the node ids.
        for (uint256 i = nodeIds; i != 0; i >>= 8) {
            /// @dev Get the value of the node.
            uint256 value = i & 0xff;

            /// @dev Check if the user has the required badge.
            if (badge.balanceOf(user, value) == 0) return false;
        }

        /// @dev The user has the required credentials.
        return true;
    }
}
