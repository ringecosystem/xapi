// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";
import {console2 as console} from "forge-std/console2.sol";

import "../src/SubAPIMultiSig.sol";

contract MultiSigDeploy is Common {
    using stdJson for string;
    using ScriptTools for string;

    address ADDR;
    bytes32 SALT;

    string c3;
    string config;
    string instanceId;
    string outputName;
    address deployer;

    function name() public pure override returns (string memory) {
        return "MultiSigDeploy";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("multisig_deploy.c"));
        outputName = "multisig_deploy.a";
        config = ScriptTools.readInput(instanceId);
        c3 = ScriptTools.readInput("../c3");
        ADDR = c3.readAddress(".SUBAPIMULTISIG_ADDR");
        SALT = c3.readBytes32(".SUBAPIMULTISIG_SALT");

        deployer = config.readAddress(".DEPLOYER");
    }

    function run() public {
        require(deployer == msg.sender, "!deployer");

        deploy();

        ScriptTools.exportContract(outputName, "SUBAPI_MULTISIG", ADDR);
    }

    function deploy() public broadcast returns (address) {
        bytes memory byteCode = type(SubAPIMultiSig).creationCode;
        address[] memory signers = config.readAddressArray(".SIGNERS");
        uint64 quorum = uint64(config.readUint(".QUORUM"));
        bytes memory initCode = bytes.concat(byteCode, abi.encode(signers, quorum));
        address subapi = _deploy3(SALT, initCode);
        require(subapi == ADDR, "!addr");

        console.log("SubAPI deployed: %s", subapi);
        return subapi;
    }
}
