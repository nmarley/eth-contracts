// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SwearJar} from "../src/SwearJar.sol";

contract SwearJarTest is Test {
    SwearJar public swearJar;

    function setUp() public {
        swearJar = new SwearJar();
        // Fund an address for testing withdraw
        vm.deal(address(this), 10 ether);
    }

    // Allow the test contract to receive ETH
    receive() external payable {}

    function test_Receive() public {
        // Send 1 ether via direct call to contract's receive function
        (bool success,) = address(swearJar).call{value: 1 ether}("");
        assertTrue(success, "Call failed");

        // Check contract balance
        assertEq(address(swearJar).balance, 1 ether);
    }

    function test_WithdrawByOwner() public {
        // Send 2 ether to the contract
        (bool success,) = address(swearJar).call{value: 2 ether}("");
        assertTrue(success, "Initial payment failed");

        // Check balance before withdrawal
        uint256 initialBalance = address(this).balance;
        uint256 jarBalance = address(swearJar).balance;
        assertEq(jarBalance, 2 ether);

        // Withdraw funds to this contract (owner)
        swearJar.withdrawToOwner();

        // Contract balance should be 0 after withdrawal
        assertEq(address(swearJar).balance, 0);

        // Owner balance should have increased by approximately 2 ether (less gas fees)
        uint256 finalBalance = address(this).balance;
        assertGe(finalBalance, initialBalance + 2 ether - 0.01 ether);
    }
}
