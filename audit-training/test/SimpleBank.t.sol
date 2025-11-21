// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SimpleBank} from "../src/SimpleBank.sol";

contract SimpleBankTest is Test {
    SimpleBank public bank;
    address public victim = address(0xbeef);

    function setUp() public {
        bank = new SimpleBank();

        // Give the victim some ETH and have them deposit
        vm.deal(victim, 1 ether);
        vm.prank(victim);
        bank.deposit{value: 1 ether}();
    }

    function testDepositWorks() public {
        // Sanity check - victim has 1 ether recorded
        assertEq(bank.balances(victim), 1 ether);
        assertEq(address(bank).balance, 1 ether);
    }
}
