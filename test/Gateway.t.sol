// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Gateway.sol";
import "./utils/MockWAsset.sol";
import "../src/Deployments.sol";

import {console2} from "forge-std/console2.sol";

contract CounterTest is Test {
    KreskoGateway public gateway;
    MockWAsset public wAsset;

    function setUp() public {
        wAsset = new MockWAsset();
        vm.prank(address(OPGOERLI.Multisig));
        OPGOERLI.Kresko.addCollateralAsset(
                address(wAsset),
                address(0),
                1,
                0xC16679B963CeB52089aD2d95312A5b85E318e9d2,
                0xC16679B963CeB52089aD2d95312A5b85E318e9d2
            );
        gateway = new KreskoGateway(address(OPGOERLI.Kresko), address(wAsset));
    }

    function testDeposit() public {
        vm.deal(address(this), 1 ether);
        assertEq(wAsset.balanceOf(address(OPGOERLI.Kresko)), 0);
        (bool success,) = address(gateway).call{value: 1 ether}("");
        require(success, "KreskoGateway: Failed to deposit");
        assertEq(wAsset.balanceOf(address(OPGOERLI.Kresko)), 1 ether);
    }

    function testFailedDeposit() public {
        vm.expectRevert();
        address(gateway).call{value: 0 ether}("");
    }
}
