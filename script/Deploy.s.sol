// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";
import {console2 as console} from "forge-std/console2.sol";

import "../src/SubAPI.sol";

interface III {
    function owner() external view returns (address);
    function name() external view returns (string memory);
    function airnodeRrp() external view returns (address);
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract Deploy is Common {
    using stdJson for string;
    using ScriptTools for string;

    address immutable ORMP = 0x0034607daf9c1dc6628f6e09E81bB232B6603A89;
    address immutable ADDR = 0x0011D025BEe8dA1461d9Ba382461B9DD48f11F1d;
    bytes32 immutable SALT = 0xfa3a7fa313f408af8f6ec8461944703c8062977f27e4789d8814e26dc7df220a;

    string config;
    string instanceId;
    string outputName;
    address deployer;
    address dao;
    string subapiName;
    address rrp;

    function name() public pure override returns (string memory) {
        return "Deploy";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("deploy.c"));
        outputName = "deploy.a";
        config = ScriptTools.readInput(instanceId);

        deployer = config.readAddress(".DEPLOYER");
        dao = config.readAddress(".DAO");
        subapiName = config.readString(".NAME");
        rrp = config.readAddress(".AIRNODE_RRP");
    }

    function run() public {
        require(deployer == msg.sender, "!deployer");

        deploy();
        setConfig();

        ScriptTools.exportContract(outputName, "DAO", dao);
        ScriptTools.exportContract(outputName, "SUBAPI", ADDR);
    }

    function deploy() public broadcast returns (address) {
        bytes memory byteCode = type(SubAPI).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, rrp, ORMP, subapiName));
        address subapi = _deploy3(SALT, initCode);
        require(subapi == ADDR, "!addr");

        require(III(subapi).owner() == deployer, "!deployer");
        require(III(subapi).airnodeRrp() == rrp, "!rrp");
        require(eq(III(subapi).name(), subapiName), "!name");
        console.log("SubAPI deployed: %s", subapi);
        return subapi;
    }

    function setConfig() public broadcast {
        III(ADDR).transferOwnership(dao);
        require(III(ADDR).pendingOwner() == dao, "!dao");
        // TODO:: dao.acceptOwnership()
    }

    function eq(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
