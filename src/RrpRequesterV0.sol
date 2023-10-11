// SPDX-License-Identifier: MIT
//
// Inspired: https://github.com/api3dao/airnode/blob/master/packages/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol

pragma solidity 0.8.17;

import "@openzeppelin/contracts@4.9.2/access/Ownable2Step.sol";
import "./interfaces/IAirnodeRrpV0.sol";

/// @title The contract to be inherited to make Airnode RRP requests
contract RrpRequesterV0 is Ownable2Step {
    IAirnodeRrpV0 public airnodeRrp;

    /// @dev Reverts if the caller is not the Airnode RRP contract.
    /// Use it as a modifier for fulfill and error callback methods, but also
    /// check `requestId`.
    modifier onlyAirnodeRrp() {
        require(msg.sender == address(airnodeRrp), "Caller not Airnode RRP");
        _;
    }

    /// @dev Airnode RRP address is set at deployment and is immutable.
    /// RrpRequester is made its own sponsor by default. RrpRequester can also
    /// be sponsored by others and use these sponsorships while making
    /// requests, i.e., using this default sponsorship is optional.
    /// @param _airnodeRrp Airnode RRP contract address
    function setAirnodeRrp(address _airnodeRrp) external onlyOwner {
        airnodeRrp = IAirnodeRrpV0(_airnodeRrp);
        IAirnodeRrpV0(_airnodeRrp).setSponsorshipStatus(address(this), true);
    }
}
