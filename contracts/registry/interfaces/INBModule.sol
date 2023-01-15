// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.17;

interface INBModule {
    function canCall(
        bytes memory config,
        address _caller,
        address _target,
        bytes4 _sig
    ) external view returns (bool);
}
