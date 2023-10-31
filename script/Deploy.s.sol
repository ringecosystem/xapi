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

    address immutable ORMP = 0x009D223Aad560e72282db9c0438Ef1ef2bf7703D;
    address immutable ADDR = 0x00d917EC19A6b8837ADFcF8adE3D6faF62e0F587;
    bytes32 immutable SALT = 0xe7849c948ea6e6b8c405d9ca604fc1ab01c9a05c7f7bb268a419e707e2f1d936;

    string config;
    string instanceId;
    string outputName;
    address deployer;
    address dao;
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
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, rrp, ORMP));
        address subapi = _deploy3(SALT, initCode);
        require(subapi == ADDR, "!addr");

        require(III(subapi).owner() == deployer, "!deployer");
        require(III(subapi).airnodeRrp() == rrp, "!rrp");
        console.log("SubAPI deployed: %s", subapi);
        return subapi;
    }

    function setConfig() public broadcast {
        III(ADDR).transferOwnership(dao);
        require(III(ADDR).pendingOwner() == dao, "!dao");
        // TODO:: dao.acceptOwnership()
    }
}
