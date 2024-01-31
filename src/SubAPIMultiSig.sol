// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./MultiSig.sol";
import "./interfaces/IOracle.sol";

contract SubAPIMultiSig is MultiSig {
    IOracle public immutable ORACLE;

    mapping(bytes32 => bool) doneOf;

    error VerifySignaturesFailed();
    error HashAlreadyUsed(bytes32 hash);
    error OperationExpired(bytes32 hash);

    constructor(address oracle, address[] memory _signers, uint64 _quorum) MultiSig(_signers, _quorum) {
        ORACLE = IOracle(oracle);
    }

    function _checkSigs(uint256 expiration, bytes32 hash, bytes calldata signatures) internal view {
        if (block.timestamp > expiration) {
            revert OperationExpired(hash);
        }
        if (doneOf[hash]) {
            revert HashAlreadyUsed(hash);
        }
        (bool sigsValid,) = verifySignatures(hash, signatures);
        if (!sigsValid) {
            revert VerifySignaturesFailed();
        }
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
}
