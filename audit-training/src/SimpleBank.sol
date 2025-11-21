// TRAINING CONTRACT #1 — Reentrancy
pragma solidity ^0.8.0;

contract SimpleBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // Bug: sends ETH before updating balance
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "Failed to send");

        balances[msg.sender] = 0;
    }
}
