// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {BetterBank} from "../src/BetterBank.sol";
import {BetterBankAttacker} from "../src/BetterBankAttacker.sol";

contract BetterBankTest is Test {
    BetterBank public bank;
    BetterBankAttacker public attacker;
    address public victim = address(0xbeef);

    // Allow test contract to receive funds
    receive() external payable {}

    function setUp() public {
        bank = new BetterBank();

        // Victim deposits 1 ETH
        vm.deal(victim, 1 ether);
        vm.prank(victim);
        bank.deposit{value: 1 ether}();

        // Deploy attacker, owned by this test contract
        attacker = new BetterBankAttacker(bank);
    }

    function testDepositWorks() public {
        // Sanity check - victim has 1 ether recorded
        assertEq(bank.balances(victim), 1 ether);
        assertEq(address(bank).balance, 1 ether);
    }

    function testReentrancyAttackFails() public {
        uint256 bankStart = address(bank).balance;

        // Give this test contract some ETH to fund the attacker
        vm.deal(address(this), 1 ether);

        // Expect the attack to revert entirely b/c the attacker's receive() reverts
        vm.expectRevert("Failed to send");
        attacker.attack{value: 1 ether}();

        // Bank still has victim's funds safe
        assertEq(bankStart, 1 ether, "bank should start with 1 ether from victim");
        assertEq(address(bank).balance, 1 ether, "bank should still have victim's funds");
    }
}
