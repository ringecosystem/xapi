// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {ECDSA} from "@openzeppelin/contracts@4.9.2/utils/cryptography/ECDSA.sol";
import {OwnerManager} from "@safe-smart-account/base/OwnerManager.sol";
import "./interfaces/IOracle.sol";

contract SubAPIMultiSig is OwnerManager {
    IOracle public immutable ORACLE;

    mapping(bytes32 => bool) doneOf;

    error HashAlreadyUsed(bytes32 hash);
    error OperationExpired(bytes32 hash);

    constructor(address oracle, address[] memory _signers, uint64 _threshold) {
        ORACLE = IOracle(oracle);
        _setupOwners(_signers, _threshold);
    }

    function _checkSigs(uint256 expiration, bytes32 hash, bytes calldata signatures) internal view {
        if (block.timestamp > expiration) {
            revert OperationExpired(hash);
        }
        if (doneOf[hash]) {
            revert HashAlreadyUsed(hash);
        }
        verifySignatures(hash, signatures);
    }

    function importMessageRoot(
        uint256 expiration,
        uint256 chainId,
        uint256 blockNumber,
        bytes32 messageRoot,
        bytes calldata signatures
    ) external {
        bytes memory data = abi.encode(1, expiration, chainId, blockNumber, messageRoot);
        bytes32 hash = keccak256(data);
        _checkSigs(expiration, hash, signatures);
        ORACLE.importMessageRoot(chainId, blockNumber, messageRoot);
    }

    function changeOwner(uint256 expiration, address owner, bytes calldata signatures) external {
        bytes memory data = abi.encode(2, block.chainid, address(this), expiration, owner);
        bytes32 hash = keccak256(data);
        _checkSigs(expiration, hash, signatures);
        ORACLE.changeOwner(owner);
    }

    function setApproved(uint256 expiration, address operator, bool approve, bytes calldata signatures) external {
        bytes memory data = abi.encode(3, block.chainid, address(this), expiration, operator, approve);
        bytes32 hash = keccak256(data);
        _checkSigs(expiration, hash, signatures);
        ORACLE.setApproved(operator, approve);
    }

    function addOwnerWithThreshold(address owner, uint256 _threshold, bytes calldata signatures) external {}

    function verifySignatures(bytes32 _hash, bytes calldata _signatures) public view {
        require(_signatures.length == threshold * 65, "Invalid signature length");
        bytes32 messageDigest = ECDSA.toEthSignedMessageHash(_hash);

        address lastOwner = address(0);
        for (uint256 i = 0; i < threshold; i++) {
            bytes calldata signature = _signatures[i * 65:(i + 1) * 65];
            address currentOwner = ECDSA.recover(messageDigest, signature);
            require(
                currentOwner > lastOwner && owners[currentOwner] != address(0) && currentOwner != SENTINEL_OWNERS,
                "GS026"
            );
            lastOwner = currentOwner;
        }
    }
}
