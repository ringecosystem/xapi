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
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract Deploy is Common {
    using stdJson for string;
    using ScriptTools for string;

    address immutable ORMP = 0x0034607daf9c1dc6628f6e09E81bB232B6603A89;
    address immutable ADDR = 0x00945C032A37454333d7044a52a5A42Aa0f6c608;
    bytes32 immutable SALT = 0x19203b2192e701e6d2310d9b28561240cfd7ed56dada781c033d5854f2159ae5;

    string config;
    string instanceId;
    string outputName;
    address deployer;
    address dao;

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
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ORMP));
        address subapi = _deploy3(SALT, initCode);
        require(subapi == ADDR, "!addr");

        require(III(subapi).owner() == deployer);
        console.log("SubAPI deployed: %s", subapi);
        return subapi;
    }

    function setConfig() public broadcast {
        III(ADDR).transferOwnership(dao);
        require(III(ADDR).pendingOwner() == dao, "!dao");
        // TODO:: dao.acceptOwnership()
    }
}
