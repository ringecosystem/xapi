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

contract AirnodeDapi is IFeedOracle, Ownable2Step {
    event AirnodeRrpRequested(uint64 indexed beaconId, bytes32 indexed requestId);
    event AirnodeRrpCompleted(uint64 indexed beaconId, bytes32 indexed requestId, BlockData data);

    struct Beacon {
        address airnode;
        bytes32 endpointId;
        address sponsor;
        address sponsorWallet;
    }

    uint256 public fee;
    // requestId => beaconId
    mapping(bytes32 => bytes32) private _requestIdToBeaconId;
    // beaconId => airnode
    mapping(bytes32 => Beacon) private _beaconDatas;
    // beaconSet
    EnumerableSet.Bytes32Set private _beaconIds;

    address immutable public AIRNODE_RRP;

    constructor(address airnodeRrp, address dao) {
        _transferOwnership(dao);
        AIRNODE_RRP = airnodeRrp;
    }

    function latestAnswer() external view override returns (uint256 block_number, bytes32 state_root) {
        return (_aggregatedData.blockNumber, _aggregatedData.stateRoot);
    }

    function beaconsLength() external view returns (uint256) {
        return _beaconIds.length();
    }

    function getBeaconAtIndex(uint256 index) external view returns (Beacon memory) {
        bytes32 beaconId = _beaconIds.at(index);
        return _beaconDatas[beaconId];
    }

    function getBeaconById(bytes32 beaconId) external view returns (Beacon memory) {
        return _beaconDatas[beaconId];
    }

    function isBeaconExist(bytes32 beaconId) external view returns (bool) {
        return _beaconIds.contains(beaconId);
    }

    function addBeacon(Beacon calldata beacon) external onlyOwner {
        bytes32 beaconId = deriveBeaconId(beacon.airnode, beacon.endpointId);
        require(_beaconIds.add(beaconId), "!add");
        _beaconDatas[beaconId] = beacon;
    }

    function removeBeacon(bytes32 beaconId) external onlyOwner {
        require(_beaconIds.remove(beaconId), "!rm");
        delete _beaconDatas[beaconId];
    }

    function deriveBeaconId(
        address airnode,
        bytes32 endpointId
    ) internal pure returns (bytes32 beaconId) {
        beaconId = keccak256(abi.encodePacked(airnode, endpointId));
    }

    function getRequestFee() external pure override returns (address, uint256) {
        return (address(0), fee * beaconsLength());
    }

    function dataOf(uint64 requestId) external view override returns (uint256, bytes32) {
        BlockData memory data = fulfilledData[requestId];
        return (data.blockNumber, data.stateRoot);
    }

    function _request(bytes32 beaconId) internal {
        Beacon memory beacon = _beaconDatas[beaconId];
        beacon.sponsorWallet.transfer(fee);
        bytes32 requestId = AIRNODE_RRP.makeFullRequest(
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

    function requestFinalizedHash() external payable override returns (uint64 requestId) {
        bytes32[] memory beaconIds = _beaconIds.values();
        uint beaconCount = beaconIds.length;
        require(msg.value == fee * beaconCount, "!fee");
        for (uint i = 0; i < beaconCount; i++) {
            bytes32 beaconId = beaconId[i];
            _request(beaconId);
        }
    }

    function fulfill(
        bytes32 requestId,
        bytes calldata data
    ) external onlyAirnodeRrp {
        bytes32 beaconId = _requestIdToBeaconId[requestId];
        require(beaconId != bytes32(0), "!requestId");
        delete _requestIdToBeaconId[requestId];
        processBeaconUpdate(beaconId, data);
        emit AirnodeRrpCompleted(beaconId, requestId, decodedData);
    }

}
