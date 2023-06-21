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

contract AirnodeDataFeed {
    event AirnodeDataFeedUpdated(bytes32 indexed beaconId, BlockData data);

    struct BlockData {
        uint256 blockNumber;
        bytes32 stateRoot;
    }

    BlockData internal _aggregatedData;
    // beaconId => blockData
    mapping(bytes32 => BlockData) internal _dataFeeds;

    function getDatasFromBeacons(bytes32[] memory beaconIds) public view returns (BlockData[] memory) {
        uint256 beaconCount = beaconIds.length;
        BlockData[] memory datas = new BlockData[](beaconCount);
        for (uint i = 0; i < beaconCount; i++) {
            bytes32 beaconId = beaconIds[i];
            datas[i] = _dataFeeds[beaconId];
        }
        return datas;
    }

    function processBeaconUpdate(bytes32 beaconId, bytes calldata data) internal {
        BlockData memory oldData = _dataFeeds[beaconId];
        BlockData memory newData = abi.decode(data, (BlockData));
        if (newData.blockNumber > oldData.blockNumber) {
            _dataFeeds[beaconId] = newData;
            emit AirnodeDataFeedUpdated(beaconId, newData);
        }
    }

    function eq(BlockData memory a, BlockData memory b) internal pure returns (bool) {
        return a.blockNumber == b.blockNumber && a.stateRoot == b.stateRoot;
    }

    function getDataFeedWithId(bytes32 beaconId) public view returns (uint256 blockNumber, bytes32 stateRoot) {
        BlockData memory data = _dataFeeds[beaconId];
        return (data.blockNumber, data.stateRoot);
    }
}
