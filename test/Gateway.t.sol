// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Gateway.sol";
import "../src/Deployments.sol";

import {console2} from "forge-std/console2.sol";

contract GatewayTest is Test {
    KreskoGateway public gateway;

    function setUp() public {
        gateway = new KreskoGateway(address(OPGOERLI.Kresko), address(OPGOERLI.WETH));
    }

    function testDeposit() public {
        vm.deal(address(this), 1 ether);
        uint256 balance = OPGOERLI.WETH.balanceOf(address(OPGOERLI.Kresko));
        (bool success,) = address(gateway).call{value: 1 ether}("");
        require(success, "KreskoGateway: Failed to deposit");
        assertEq(OPGOERLI.WETH.balanceOf(address(OPGOERLI.Kresko)), balance + 1 ether);
    }

    function test_RevertIf_ZeroValueDeposit() public {
        vm.expectRevert(bytes("KreskoGateway: No value sent"));
        (bool status, ) = address(gateway).call{value: 0 ether}("");
        assertTrue(status, "expectRevert: call did not revert");
    }
}
