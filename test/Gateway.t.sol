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

        // grant manager role to gateway
        vm.startPrank(address(OPGOERLI.Multisig));
        OPGOERLI.Kresko.grantRole(0x46925e0f0cc76e485772167edccb8dc449d43b23b55fc4e756b063f49099e6a0, address(gateway));
        vm.stopPrank();
        assertTrue(OPGOERLI.Kresko.hasRole(0x46925e0f0cc76e485772167edccb8dc449d43b23b55fc4e756b063f49099e6a0, address(gateway)), "No manager role");
    }

    function testDeposit() public {
        vm.deal(address(this), 1 ether);
        
        uint256 balance = OPGOERLI.WETH.balanceOf(address(OPGOERLI.Kresko));
        gateway.deposit{value: 1 ether}(address(this));
        assertEq(OPGOERLI.WETH.balanceOf(address(OPGOERLI.Kresko)), balance + 1 ether);
    }

    function testWithdraw() public {
        // deposit setup
        vm.deal(address(this), 1 ether);
        gateway.deposit{value: 1 ether}(address(this));

        // approve gateway withdrawal
        OPGOERLI.WETH.approve(address(gateway), type(uint256).max);

        // withdraw should work
        assertEq(address(this).balance, 0);
        gateway.withdraw(address(this), 1 ether);
        assertEq(address(this).balance, 1 ether);
    }

    function test_RevertIf_ZeroValueDeposit() public {
        vm.expectRevert(bytes("KreskoGateway: No value sent"));
        gateway.deposit{value: 0 ether}(address(this));
    }

    function test_RevertIf_WithdrawNoManagerRole() public {
        vm.deal(address(this), 1 ether);
        gateway.deposit{value: 1 ether}(address(this));

        vm.expectRevert();
        gateway.withdraw(address(this), 1 ether);
    }

    function test_RevertIf_WithdrawMoreThanDeposit() public {
        vm.deal(address(this), 1 ether);
        gateway.deposit{value: 1 ether}(address(this));

        vm.expectRevert();
        gateway.withdraw(address(this), 2 ether);
    }

    receive() external payable {
    }
}
