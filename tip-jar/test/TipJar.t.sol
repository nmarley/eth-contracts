// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TipJar} from "../src/TipJar.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TipJarTest is Test {
    TipJar public tipJar;

    function setUp() public {
        tipJar = new TipJar();
        // Fund an address for testing withdraw
        vm.deal(address(this), 10 ether);
    }

    // Allow the test contract to receive ETH
    receive() external payable {}

    function test_Receive() public {
        // Send 1 ether via direct call to contract's receive function
        (bool success,) = address(tipJar).call{value: 1 ether}("");
        assertTrue(success, "Call failed");

        // Check contract balance
        assertEq(address(tipJar).balance, 1 ether);
    }

    function test_WithdrawByOwner() public {
        // Send 2 ether to the contract
        (bool success,) = address(tipJar).call{value: 2 ether}("");
        assertTrue(success, "Initial payment failed");

        // Check balance before withdrawal
        uint256 initialBalance = address(this).balance;
        uint256 jarBalance = address(tipJar).balance;
        assertEq(jarBalance, 2 ether);

        // Withdraw funds to this contract (owner)
        tipJar.withdrawToOwner();

        // Contract balance should be 0 after withdrawal
        assertEq(address(tipJar).balance, 0);

        // Owner balance should have increased by approximately 2 ether (less gas fees)
        uint256 finalBalance = address(this).balance;
        assertGe(finalBalance, initialBalance + 2 ether - 0.01 ether);
    }

    function test_WithdrawNotOwner() public {
        // Create a new address to simulate a non-owner
        address nonOwner = address(0x1234beef);
        vm.deal(nonOwner, 5 ether);

        // Send 1 ether to the contract first
        (bool success,) = address(tipJar).call{value: 1 ether}("");
        assertTrue(success, "Payment failed");

        // Attempt withdrawal by non-owner, expecting revert
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, nonOwner));
        tipJar.withdraw(payable(nonOwner));
    }

    function test_TipCounter() public {
        // Send 3 separate tips
        (bool success,) = address(tipJar).call{value: 1 ether}("");
        assertTrue(success);

        (success,) = address(tipJar).call{value: 0.5 ether}("");
        assertTrue(success);

        (success,) = address(tipJar).call{value: 2 ether}("");
        assertTrue(success);

        // Check tip count
        assertEq(tipJar.tipCount(), 3);
    }

    function test_BiggestTipAndTipper() public {
        address tipper1 = address(0x1111);
        address tipper2 = address(0x2222);
        address tipper3 = address(0x3333);

        vm.deal(tipper1, 5 ether);
        vm.deal(tipper2, 5 ether);
        vm.deal(tipper3, 5 ether);

        // Initial state: no tips yet
        assertEq(tipJar.biggestTip(), 0);
        assertEq(tipJar.biggestTipper(), address(0));

        // First tip: 1 ether
        vm.prank(tipper1);
        (bool success,) = address(tipJar).call{value: 1 ether}("");
        assertTrue(success);
        assertEq(tipJar.biggestTip(), 1 ether);
        assertEq(tipJar.biggestTipper(), tipper1);

        // Second tip: 0.5 ether (smaller, should not update)
        vm.prank(tipper2);
        (success,) = address(tipJar).call{value: 0.5 ether}("");
        assertTrue(success);
        assertEq(tipJar.biggestTip(), 1 ether);
        assertEq(tipJar.biggestTipper(), tipper1);

        // Third tip: 2 ether (bigger, should update)
        vm.prank(tipper3);
        (success,) = address(tipJar).call{value: 2 ether}("");
        assertTrue(success);
        assertEq(tipJar.biggestTip(), 2 ether);
        assertEq(tipJar.biggestTipper(), tipper3);

        // Fourth tip: equal to biggest (should not update)
        vm.prank(tipper1);
        (success,) = address(tipJar).call{value: 2 ether}("");
        assertTrue(success);
        assertEq(tipJar.biggestTip(), 2 ether);
        assertEq(tipJar.biggestTipper(), tipper3);
    }
}
