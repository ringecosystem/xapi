// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract AirnodeMessageRootFeed {
    event AirnodeMessageRootFeedUpdated(bytes32 indexed beaconId, bytes32 msgRoot);

    bytes32 internal _aggregatedData;
    // beaconId => msgRoot
    mapping(bytes32 => bytes32) internal _dataFeeds;

    function processBeaconUpdate(bytes32 beaconId, bytes calldata data) internal {
        (bytes32 msgRoot) = abi.decode(data, (bytes32));
        _dataFeeds[beaconId] = msgRoot;
        emit AirnodeMessageRootFeedUpdated(beaconId, msgRoot);
    }

    function getDataFeedWithId(bytes32 beaconId) public view returns (bytes32 msgRoot) {
        return _dataFeeds[beaconId];
    }
}
