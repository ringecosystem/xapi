// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract SubAPISignaturePub {
    event SignatureSubmittion(
        uint256 indexed chainId,
        address indexed channel,
        address indexed signer,
        uint256 msgIndex,
        bytes signature,
        bytes data
    );

    function submit(uint256 chainId, address channel, uint256 msgIndex, bytes calldata signature, bytes calldata data)
        external
    {
        emit SignatureSubmittion(chainId, channel, msg.sender, msgIndex, signature, data);
    }
}
