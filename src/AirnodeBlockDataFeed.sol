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

contract AirnodeBlockDataFeed {
    event AirnodeBlockDataFeedUpdated(bytes32 indexed beaconId, uint256 blockNumber, bytes32 msgRoot);

    mapping(uint256 => bytes32) internal _aggregatedData;
    // beaconId => blockNumber => msgRoot
    mapping(bytes32 => mapping(uint256 => bytes32)) internal _dataFeeds;

    function processBeaconUpdate(bytes32 beaconId, bytes calldata data) internal {
        (uint256 blockNumber, bytes32 msgRoot) = abi.decode(data, (uint256, bytes32));
        _dataFeeds[beaconId][blockNumber] = msgRoot;
        emit AirnodeBlockDataFeedUpdated(beaconId, blockNumber, msgRoot);
    }

    function getDataFeedWithId(bytes32 beaconId, uint256 blockNumber) public view returns (bytes32 msgRoot) {
        return _dataFeeds[beaconId][blockNumber];
    }
}
