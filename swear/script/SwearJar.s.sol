// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SwearJar} from "../src/SwearJar.sol";

contract SwearJarScript is Script {
    SwearJar public swearJar;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        swearJar = new SwearJar();

        vm.stopBroadcast();
    }
}
