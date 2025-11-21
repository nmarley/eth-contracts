// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SimpleBank} from "../src/SimpleBank.sol";

contract SimpleBankTest is Test {
    SimpleBank public bank;

    function setUp() public {
        bank = new SimpleBank();
    }

    function testDepositWorks() public {
        // Give the test contract 1 ether so it can deposit
        vm.deal(address(this), 1 ether);

        bank.deposit{value: 1 ether}();
        assertEq(bank.balances(address(this)), 1 ether);
    }
}
