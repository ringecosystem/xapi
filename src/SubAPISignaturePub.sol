// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract SubAPISignaturePub {
    event SignatureSubmittion(
        uint256 indexed chainId, uint256 indexed msgIndex, address indexed signer, bytes signature, bytes data
    );

    function submit(uint256 chainId, uint256 msgIndex, bytes calldata signature, bytes calldata data) external {
        emit SignatureSubmittion(chainId, msgIndex, msg.sender, signature, data);
    }
}
