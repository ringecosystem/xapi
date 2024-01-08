// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract SubAPISignaturePub {
    event SignatureSubmittion(address indexed signer, bytes signature, bytes data);

    function submit(bytes calldata signature, bytes calldata data) external {
        emit SignatureSubmittion(msg.sender, signature, data);
    }
}
