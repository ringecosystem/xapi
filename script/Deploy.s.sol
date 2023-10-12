// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import "ORMP/script/Common.s.sol";

import "../src/SubAPI.sol";

interface III {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract DeployScript is Common {
    using stdJson for string;
    using ScriptTools for string;

    address immutable ORMP = 0x0000000000BD9dcFDa5C60697039E2b3B28b079b;
    address immutable ADDR = 0x0000001207bC87Df42403F0898efBF79A28222BE;
    bytes32 immutable SALT = 0xa526e97cd16eef26d31b69f973d0d6d4909370e9fdf2fdf0061c1993e4f6cc21;

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
    }

    function deploy() public broadcast returns (address) {
        bytes memory byteCode = type(SubAPI).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ORMP));
        address subapi = _deploy(SALT, initCode);
        require(subapi == ADDR, "!addr");

        require(III(subapi).owner() == deployer);
        console.log("SubAPI  deployed at %s", subapi);
        return subapi;
    }

    function setConfig() public broadcast {
        III(ADDR).transferOwnership(dao);
        require(III(ADDR).pendingOwner() == dao, "!dao");
        // TODO:: dao.acceptOwnership()
    }
}
