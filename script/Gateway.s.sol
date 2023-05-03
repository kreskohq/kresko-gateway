// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {KreskoGateway} from "../src/Gateway.sol";
import {OPGOERLI} from "../src/Deployments.sol";

contract GatewayScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        KreskoGateway gateway = new KreskoGateway(address(OPGOERLI.Kresko), address(OPGOERLI.WETH));

        vm.stopBroadcast();
    }
}
