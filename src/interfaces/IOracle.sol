// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IOracle {
    function importMessageRoot(uint256 chainId, uint256 blockNumber, bytes32 messageRoot) external;
    function changeOwner(address owner_) external;
    function setApproved(address operator, bool approve) external;
}
