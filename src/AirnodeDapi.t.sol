// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "ds-test/test.sol";

import "./AirnodeDapi.sol";

contract AirnodeDapiTest is DSTest {
    AirnodeDapi dapi;

    function setUp() public {
        dapi = new AirnodeDapi(
            address(0x1),
            address(0x2),
            1e18
        );
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
