// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SimpleBank} from "../src/SimpleBank.sol";
import {SimpleBankAttacker} from "../src/SimpleBankAttacker.sol";

contract SimpleBankTest is Test {
    SimpleBank public bank;
    SimpleBankAttacker public attacker;
    address public victim = address(0xbeef);

    function setUp() public {
        bank = new SimpleBank();

        // Victim deposits 1 ETH
        vm.deal(victim, 1 ether);
        vm.prank(victim);
        bank.deposit{value: 1 ether}();

        // Deploy attacker, owned by this test contract
        attacker = new SimpleBankAttacker(bank);
    }

    function testDepositWorks() public {
        // Sanity check - victim has 1 ether recorded
        assertEq(bank.balances(victim), 1 ether);
        assertEq(address(bank).balance, 1 ether);
    }

    function testReentrancyAttackDrainsBank() public {
        uint256 bankStart = address(bank).balance;

        // Give this test contract some ETH to fund the attacker
        vm.deal(address(this), 1 ether);

        // Start the attack with 1 ether from us
        attacker.attack{value: 1 ether}();

        // At this point, attacker contract should have drained the bank
        uint256 bankEnd = address(bank).balance;
        uint256 attackerBalance = address(attacker).balance;

        assertEq(bankStart, 1 ether, "bank should start with 1 ether from victim");
        assertEq(bankEnd, 0, "bank should be drained");
        assertGt(attackerBalance, 1 ether, "attacker should have more than they put in");

        // Now pull funds out to the test contract to prove control
        uint256 testStart = address(this).balance;
        attacker.withdrawToOwner();
        uint256 testEnd = address(this).balance;

        assertGt(testEnd, testStart, "owner should receive stolen funds");
    }
}
