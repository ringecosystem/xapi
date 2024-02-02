// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {ECDSA} from "@openzeppelin/contracts@4.9.2/utils/cryptography/ECDSA.sol";
import {OwnerManager} from "@safe-smart-account/base/OwnerManager.sol";

contract SubAPIMultiSig is OwnerManager {
    event ExecutionResult(bytes32 indexed hash, bool result);

    mapping(bytes32 => bool) public doneOf;

    receive() external payable {}

    constructor(address[] memory signers, uint64 threshold) {
        setupOwners(signers, threshold);
    }

    function verifySignatures(bytes32 hash, bytes calldata signatures) public view {
        require(signatures.length == threshold * 65, "invalid signature length");
        bytes32 messageDigest = ECDSA.toEthSignedMessageHash(hash);

        address lastOwner = address(0);
        for (uint256 i = 0; i < threshold; i++) {
            bytes calldata signature = signatures[i * 65:(i + 1) * 65];
            address currentOwner = ECDSA.recover(messageDigest, signature);
            require(
                currentOwner > lastOwner && owners[currentOwner] != address(0) && currentOwner != SENTINEL_OWNERS,
                "invalid signature"
            );
            lastOwner = currentOwner;
        }
    }

    function _checkSigs(uint256 expiration, bytes32 hash, bytes calldata signatures) internal view {
        require(block.timestamp < expiration, "operation expired");
        require(!doneOf[hash], "hash already used");
        verifySignatures(hash, signatures);
    }

    function exec(address to, uint256 value, uint256 expiration, bytes memory data, bytes calldata signatures)
        external
        payable
    {
        bytes memory txData = abi.encode(block.chainid, address(this), to, value, expiration, data);
        bytes32 hash = keccak256(txData);
        _checkSigs(expiration, hash, signatures);
        (bool success,) = to.call{value: value}(data);
        doneOf[hash] = true;
        emit ExecutionResult(hash, success);
    }
}
