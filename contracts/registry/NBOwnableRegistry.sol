// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.17;

/// @dev Core dependencies.
import {Auth, Authority} from "solmate/src/auth/Auth.sol";

interface INBModule {
    function canCall(
        bytes memory config,
        address _caller,
        address _target,
        bytes4 _sig
    ) external view returns (bool);
}

interface IOwnable {
    function owner() external view returns (address);
}

/**
 * @title NBOwnableRegistry
 * @dev This is a a registry that allows instant decentralization and usage of Badge-driven 
 *      access moduels by connecting them to targets. All a user has to do is call connect
 *      and then transfer the ownership of the contract to the registry. The registry will
 *      then be able to manage the access control of the target.
 * @notice This is a registry model rather than a factory model. This means that there is no
 *         need for any user to deploy any kind of contract or module to take advantage of
 *         ever-evolving access modules and patterns.
 */
contract NBOwnableRegistry is Auth, Authority {
    /// @dev The schema of node in the authority graph.
    struct Node {
        INBModule base;
        bytes config;
    }

    /// @dev The modules that are enabled in the registry.
    mapping(address => INBModule) public modules;

    /// @dev The schema of node in the authority graph.
    mapping(address => Node) public nodes;

    /// @dev Emitted when a module is enabled.
    event ModuleEnabled(address indexed module);

    /// @dev Emitted when a module is disabled.
    event ModuleDisabled(address indexed module);
    
    /// @dev Emitted when a module is connected to a target.
    event ModuleConnected(
        address indexed target,
        address indexed module,
        Node indexed node
    );

    ////////////////////////////////////////////////////////
    ///                   CONSTRUCTOR                    ///
    ////////////////////////////////////////////////////////

    constructor(address _module) Auth(msg.sender, Authority(address(this))) {
        /// @dev Utilize our own module to enable the management of the registry.
        connect(address(this), _module, Node(INBModule(_module), ""));
    }

    ////////////////////////////////////////////////////////
    ///                     SETTERS                      ///
    ////////////////////////////////////////////////////////

    /**
     * @dev Enable a module.
     * @param _module The address of the module to enable.
     * @notice The module must be deployed and have the correct interface.
     */
    function enableModule(address _module) external requiresAuth {
        modules[_module] = INBModule(_module);

        emit ModuleEnabled(_module);
    }

    /**
     * @dev Disable a module.
     * @notice If an active module is disabled it will not prevent the operation
     *         of already connected ones and will only prevent future connections.
     * @param _module The address of the module to disable.
     */
    function disableModule(address _module) external requiresAuth {
        delete modules[_module];

        emit ModuleDisabled(_module);
    }

    /**
     * @dev Load the configuration of a module.
     * @notice This function is called by the module itself to load its configuration.
     * @param _module The address of the module to load the configuration for.
     * @param _node The configuration of the module.
     */
    function connect(
        address _target,
        address _module,
        Node memory _node
    ) public {
        /// @dev Only the owner of the target can connect a module.
        require(
            IOwnable(_target).owner() == msg.sender,
            "NBOwnableRegistry: NOT_OWNER"
        );

        /// @dev The module must be enabled.
        require(
            modules[_module] != INBModule(address(0)),
            "NBOwnableRegistry: MODULE_NOT_ENABLED"
        );

        /// @dev The module must be the same as the one in the configuration.
        nodes[_target] = _node;

        /// @dev Emit an event.
        emit ModuleConnected(_target, _module, _node);
    }

    /**
     * @dev Call a function on a target contract.
     * @param _target The address of the target contract.
     * @param _data The data of the function.
     * @return The result of the function call.
     */
    function call(address _target, bytes memory _data)
        external
        payable
        returns (bytes memory)
    {
        /// @dev We are checking the target of the contract that is being called which means
        ///      if you owned a protocol, you could transfer the ownership to this contract
        ///      with the added benefit of being able to add additional checks to the
        ///      functions that are being called.
        require(
            canCall(msg.sender, _target, getSig(_data)),
            "NBOWnableWrapper: caller does not have the required credentials"
        );

        /// @dev We are using the `delegatecall` opcode to call the function on the target
        ///      contract. This means that the `msg.sender` will be the target contract.
        (bool success, bytes memory result) = _target.delegatecall(_data);

        /// @dev We are checking if the function call was successful.
        require(success, "NBOWnableWrapper: function call failed");

        /// @dev We are returning the result of the function call.
        return result;
    }

    ////////////////////////////////////////////////////////
    ///                     GETTERS                      ///
    ////////////////////////////////////////////////////////

    /**
     * @dev Get the signature of a function.
     * @param _data The data of the function.
     * @return The signature of the function.
     */
    function getSig(bytes memory _data) public pure returns (bytes4) {
        /// @dev We are getting the first 4 bytes of the data which is the signature.
        bytes4 sig;
        assembly {
            sig := mload(add(_data, 0x20))
        }
        return sig;
    }

    /**
     * @dev Check if a caller can call a function on a target contract.
     * @param _caller The address of the caller.
     * @param _target The address of the target contract.
     * @param _sig The signature of the function.
     * @return True if the caller can call the function.
     */
    function canCall(
        address _caller,
        address _target,
        bytes4 _sig
    ) public view returns (bool) {
        /// @dev Get the node of the caller.
        Node memory node = nodes[_target];

        /// @dev Return if the caller can call the function.
        return node.base.canCall(node.config, _caller, _target, _sig);
    }
}
