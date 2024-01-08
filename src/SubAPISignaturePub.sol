// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract SubAPISignaturePub {
    event SignatureSubmittion(address indexed signer, uint256 chainId, bytes signature, bytes data);

    function submit(uint256 chainId, bytes calldata signature, bytes calldata data) external {
        emit SignatureSubmittion(chainId, msg.sender, signature, data);
    }
}
