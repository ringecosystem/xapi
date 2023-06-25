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
import "./AirnodeDataFeed.sol";
import "@openzeppelin/contracts@4.9.2/access/Ownable2Step.sol";
import "@openzeppelin/contracts@4.9.2/utils/structs/EnumerableSet.sol";

/// @title The contract uses to serve data feeds of arbitrum finalized header
/// @notice AirnodeDapi serves data feeds in the form of BeaconSet.
/// The BeaconSet are only updateable using RRPv0.
contract AirnodeDapi is IFeedOracle, Ownable2Step, RrpRequesterV0, AirnodeDataFeed {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    event AirnodeRrpRequested(bytes32 indexed beaconId, bytes32 indexed requestId);
    event AirnodeRrpCompleted(bytes32 indexed beaconId, bytes32 indexed requestId, bytes data);
    event AggregatedBlockData(BlockData data);

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
    // beaconId => beacon
    mapping(bytes32 => Beacon) private _beaconDatas;
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

    /// @notice Latest aggregated arbitrum finalized header from BeaconSet
    function latestAnswer() external view override returns (uint256 block_number, bytes32 state_root) {
        return (_aggregatedData.blockNumber, _aggregatedData.stateRoot);
    }

    /// @notice Fetch beaconId by requestId
    function getBeaconIdByRequestId(bytes32 requestId) external view returns (bytes32) {
        return _requestIdToBeaconId[requestId];
    }

    /// @notice BeaconSet length
    function beaconsLength() public view returns (uint256) {
        return _beaconIds.length();
    }

    /// @notice Fetch beacon metadata by index
    function getBeaconAtIndex(uint256 index) external view returns (Beacon memory) {
        bytes32 beaconId = _beaconIds.at(index);
        return _beaconDatas[beaconId];
    }

    /// @notice Fetch beacon metadata by beaconId
    function getBeaconById(bytes32 beaconId) external view returns (Beacon memory) {
        return _beaconDatas[beaconId];
    }

    /// @notice Check if the beacon exist by Id
    function isBeaconExist(bytes32 beaconId) external view returns (bool) {
        return _beaconIds.contains(beaconId);
    }

    /// @notice Add a beacon to BeaconSet
    function addBeacon(Beacon calldata beacon) external onlyOwner {
        bytes32 beaconId = deriveBeaconId(beacon.airnode, beacon.endpointId);
        require(_beaconIds.add(beaconId), "!add");
        _beaconDatas[beaconId] = beacon;
    }

    /// @notice Remove the beacon from BeaconSet
    function removeBeacon(bytes32 beaconId) external onlyOwner {
        require(_beaconIds.remove(beaconId), "!rm");
        delete _beaconDatas[beaconId];
    }

    /// @notice change the beacon fee
    function setFee(uint256 fee_) external onlyOwner {
        fee = fee_;
    }

    /// @notice Derives the Beacon ID from the Airnode address and endpoint ID
    /// @param airnode Airnode address
    /// @param endpointId Endpoint ID
    /// @return beaconId Beacon ID
    function deriveBeaconId(address airnode, bytes32 endpointId) public pure returns (bytes32 beaconId) {
        beaconId = keccak256(abi.encodePacked(airnode, endpointId));
    }

    /// @notice Fetch request fee
    /// return tokenAddress if tokenAddress is Address(0x0), pay the native token
    ///        fee the request fee
    function getRequestFee() external view returns (address, uint256) {
        return (address(0), fee * beaconsLength());
    }

    function _request(bytes32 beaconId) internal {
        Beacon memory beacon = _beaconDatas[beaconId];
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
        emit AirnodeRrpRequested(beaconId, requestId);
    }

    /// @notice Create a request for arbitrum finalized header
    ///         Send reqeust to each beacon in BeaconSet
    function requestFinalizedHash() external payable {
        bytes32[] memory beaconIds = _beaconIds.values();
        uint beaconCount = beaconIds.length;
        require(msg.value == fee * beaconCount, "!fee");
        for (uint i = 0; i < beaconCount; i++) {
            bytes32 beaconId = beaconIds[i];
            _request(beaconId);
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
        delete _requestIdToBeaconId[requestId];
        processBeaconUpdate(beaconId, data);
        emit AirnodeRrpCompleted(beaconId, requestId, data);
    }

    /// @notice Called to aggregate the BeaconSet and save the result
    /// @param beaconIds Beacon IDs
    function aggregateBeacons(bytes32[] memory beaconIds) external {
        uint256 beaconCount = beaconIds.length;
        bytes32[] memory allBeaconIds = _beaconIds.values();
        require(beaconCount * 3 > allBeaconIds.length * 2, "!supermajor");
        BlockData[] memory datas = getDatasFromBeacons(beaconIds);
        BlockData memory data = datas[0];
        for (uint i = 1; i < beaconCount; i++) {
            require(eq(data, datas[i]), "!agg");
        }
        _aggregatedData = data;
        emit AggregatedBlockData(data);
    }
}
