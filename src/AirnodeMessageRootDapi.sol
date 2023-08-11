// This file is part of Darwinia.
// Copyright (C) 2018-2022 Darwinia Network
// SPDX-License-Identifier: GPL-3.0
//
// Darwinia is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Darwinia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.8.17;

import "./interfaces/IFeedOracle.sol";
import "./RrpRequesterV0.sol";
import "./AirnodeMessageRootFeed.sol";
import "@openzeppelin/contracts@4.9.2/access/Ownable2Step.sol";
import "@openzeppelin/contracts@4.9.2/utils/structs/EnumerableSet.sol";

/// @title The contract uses to serve data feeds of arbitrum finalized header
/// @dev dAPI security model is the same as edcsa pallet.
/// @notice AirnodeDapi serves data feeds in the form of BeaconSet.
/// The BeaconSet are only updateable using RRPv0.
contract AirnodeMessageRootDapi is IFeedOracle, Ownable2Step, RrpRequesterV0, AirnodeMessageRootFeed {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    event AddBeacon(bytes32 indexed beaconId, Beacon beacon);
    event RemoveBeacon(bytes32 indexed beaconId);
    event AirnodeRrpRequested(bytes32 indexed beaconId, bytes32 indexed requestId);
    event AirnodeRrpCompleted(bytes32 indexed beaconId, bytes32 indexed requestId, bytes data);
    event AggregatedMessageRoot(bytes32 msgRoot);

    /// @notice Beacon metadata
    /// @param airnode Airnode address
    /// @param endpointId Endpoint ID
    /// @param sponsor Sponsor address
    /// @param sponsorWallet Sponsor wallet address
    struct Beacon {
        address airnode;
        bytes32 endpointId;
        address sponsor;
        address payable sponsorWallet;
    }

    // fee pay to beacon sponsor wallet address for gas
    uint256 public fee;
    // requestId => beaconId
    mapping(bytes32 => bytes32) private _requestIdToBeaconId;
    // beaconId => requestId
    mapping(bytes32 => bytes32) private _beaconIdToRequestId;
    // beaconIdSet
    EnumerableSet.Bytes32Set private _beaconIds;

    /// @param airnodeRrp Airnode RRP address
    /// @param dao Airnode Dao
    /// @param fee_ Beacon request fee for gas
    constructor(
        address airnodeRrp,
        address dao,
        uint256 fee_
    ) RrpRequesterV0(airnodeRrp) {
        _transferOwnership(dao);
        fee = fee_;
    }

    /// @notice Add a beacon to BeaconSet
    function addBeacon(Beacon calldata beacon) external onlyOwner {
        bytes32 beaconId = deriveBeaconId(beacon);
        require(_beaconIds.add(beaconId), "!add");
        emit AddBeacon(beaconId, beacon);
    }

    /// @notice Remove the beacon from BeaconSet
    function removeBeacon(bytes32 beaconId) external onlyOwner {
        require(_beaconIds.remove(beaconId), "!rm");
        emit RemoveBeacon(beaconId);
    }

    /// @notice change the beacon fee
    function setFee(uint256 fee_) external onlyOwner {
        fee = fee_;
    }

    function messageRoot() external view override returns (bytes32) {
        return _aggregatedData;
    }

    /// @notice Fetch request fee
    /// return tokenAddress if tokenAddress is Address(0x0), pay the native token
    ///        fee the request fee
    function getRequestFee() external view returns (address, uint256) {
        return (address(0), fee * beaconsLength());
    }

    /// @notice Fetch beaconId by requestId
    function getBeaconIdByRequestId(bytes32 requestId) external view returns (bytes32) {
        return _requestIdToBeaconId[requestId];
    }

    /// @notice Fetch requestId by beaconId
    function getRequestIdByBeaconId(bytes32 beaconId) external view returns (bytes32) {
        return _beaconIdToRequestId[beaconId];
    }

    /// @notice BeaconSet length
    function beaconsLength() public view returns (uint256) {
        return _beaconIds.length();
    }

    /// @notice Check if the beacon exist by Id
    function isBeaconExist(bytes32 beaconId) public view returns (bool) {
        return _beaconIds.contains(beaconId);
    }

    /// @notice Derives the Beacon ID from the Airnode address and endpoint ID
    /// @param beacon Beacon
    function deriveBeaconId(Beacon calldata beacon) public pure returns (bytes32 beaconId) {
        beaconId = keccak256(abi.encode(beacon));
    }

    function _request(Beacon calldata beacon, bytes32 beaconId) internal {
        beacon.sponsorWallet.transfer(fee);
        bytes32 requestId = airnodeRrp.makeFullRequest(
            beacon.airnode,
            beacon.endpointId,
            beacon.sponsor,
            beacon.sponsorWallet,
            address(this),
            this.fulfill.selector,
            ""
        );
        _requestIdToBeaconId[requestId] = beaconId;
        _beaconIdToRequestId[beaconId] = requestId;
        emit AirnodeRrpRequested(beaconId, requestId);
    }

    /// @notice Create a request for arbitrum finalized header
    ///         Send reqeust to all beacon in BeaconSet
    function requestFinalizedHash(Beacon[] calldata beacons) external payable {
        uint beaconCount = beacons.length;
        require(beaconCount == beaconsLength(), "!all");
        require(msg.value == fee * beaconCount, "!fee");
        for (uint i = 0; i < beaconCount; i++) {
            bytes32 beaconId = deriveBeaconId(beacons[i]);
            require(isBeaconExist(beaconId), "!exist");
            _request(beacons[i], beaconId);
        }
    }

    /// @notice  Called by the ArinodeRRP to fulfill the request
    /// @param requestId Request ID
    /// @param data Fulfillment data (`BlockData` encoded in contract ABI)
    function fulfill(
        bytes32 requestId,
        bytes calldata data
    ) external onlyAirnodeRrp {
        bytes32 beaconId = _requestIdToBeaconId[requestId];
        require(beaconId != bytes32(0), "!requestId");
        if (_beaconIdToRequestId[beaconId] == requestId) {
            delete _requestIdToBeaconId[requestId];
            delete _beaconIdToRequestId[beaconId];
            processBeaconUpdate(beaconId, data);
            emit AirnodeRrpCompleted(beaconId, requestId, data);
        } else {
            delete _requestIdToBeaconId[requestId];
        }
    }

    /// @notice Called to aggregate the BeaconSet and save the result.
    ///         beaconIds should be a supermajor(>2/3) subset of all beacons in contract.
    /// @param beaconIds Beacon IDs should be sorted in ascending order
    function aggregateBeacons(bytes32[] calldata beaconIds) external {
        uint256 beaconCount = beaconIds.length;
        bytes32[] memory allBeaconIds = _beaconIds.values();
        require(beaconCount * 3 > allBeaconIds.length * 2, "!supermajor");
        bytes32[] memory datas = _checkAndGetDatasFromBeacons(beaconIds);
        bytes32 data = datas[0];
        for (uint i = 1; i < beaconCount; i++) {
            require(data == datas[i], "!agg");
        }
        require(_aggregatedData != data, "same");
        _aggregatedData = data;
        emit AggregatedMessageRoot(data);
    }

    function _checkAndGetDatasFromBeacons(bytes32[] calldata beaconIds) internal view returns (bytes32[] memory) {
        uint256 beaconCount = beaconIds.length;
        bytes32[] memory datas = new bytes32[](beaconCount);
        bytes32 last = bytes32(0);
        bytes32 current;
        for (uint i = 0; i < beaconCount; i++) {
            current = beaconIds[i];
            require(current > last && isBeaconExist(current), "!beacon");
            datas[i] = _dataFeeds[current];
            last = current;
        }
        return datas;
    }
}