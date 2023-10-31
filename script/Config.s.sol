// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

interface III {
    function fee() external view returns (uint256);
    function name() external view returns (string memory);
    function airnodeRrp() external view returns (address);
    function setFee(uint256 fee_) external;
    function setName(string memory name_) external;
    function setAirnodeRrp(address _airnodeRrp) external;
}

contract Config is Common {
    using stdJson for string;
    using ScriptTools for string;

    string instanceId;
    string config;
    string deployedContracts;
    address dao;
    address subapi;

    function name() public pure override returns (string memory) {
        return "Config";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("config.c"));
        config = ScriptTools.readInput(instanceId);
        deployedContracts = ScriptTools.readOutput("deploy.a");
        dao = deployedContracts.readAddress(".DAO");
        subapi = deployedContracts.readAddress(".SUBAPI");
    }

    function run() public {
        require(dao == msg.sender, "!dao");
        setName();
        setFee();
    }

    function setName() public broadcast {
        string memory name_ = config.readString(".name");
        III(subapi).setName(name_);
        require(eq(III(subapi).name(), name_), "!name");
    }

    function setFee() public broadcast {
        uint256 fee = config.readUint(".fee");
        III(subapi).setFee(fee);
        require(III(subapi).fee() == fee, "!fee");
    }

    function eq(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
