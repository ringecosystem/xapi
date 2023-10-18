// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IORMP {
    function root() external view returns (bytes32);
    function messageCount() external view returns (uint256);
}

contract ORMPWrapper {
    address public immutable ORMP;

    constructor(address ormp) {
        ORMP = ormp;
    }

    function localCommitment() external view returns (bytes memory) {
        uint256 count = IORMP(ORMP).messageCount();
        bytes32 root = IORMP(ORMP).root();
        return abi.encodePacked(count, root);
    }
}
