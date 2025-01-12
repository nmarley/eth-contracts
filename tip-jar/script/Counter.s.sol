// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TipJar} from "../src/TipJar.sol";

contract TipJarScript is Script {
    TipJar public tipJar;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        tipJar = new TipJar();

        vm.stopBroadcast();
    }
}
