// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract SubAPISignaturePub {
    event SignatureSubmittion(uint256 indexed chainId, address indexed signer, bytes signature, bytes data);

    function submit(uint256 chainId, bytes calldata signature, bytes calldata data) external {
        emit SignatureSubmittion(chainId, msg.sender, signature, data);
    }
}
