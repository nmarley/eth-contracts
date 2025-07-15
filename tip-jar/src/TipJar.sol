// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TipJar is Ownable {
    uint256 public tipCount;
    uint256 public biggestTip;
    address public biggestTipper;

    event TipJarPaid(address indexed from, uint256 amount);
    event JarEmptied(address indexed to, uint256 amount);

    constructor() Ownable(msg.sender) {}

    // Anyone can pay into the tip jar
    receive() external payable {
        require(msg.value > 0, "Payment required");
        tipCount++;
        if (msg.value > biggestTip) {
            biggestTip = msg.value;
            biggestTipper = msg.sender;
        }
        emit TipJarPaid(msg.sender, msg.value);
    }

    // Only the owner can withdraw funds from the contract
    function withdraw(address payable to) public onlyOwner {
        require(to != address(0), "Bad addr");
        uint256 balance = address(this).balance;

        (bool success,) = to.call{value: balance}("");
        require(success, "Withdraw failed");

        emit JarEmptied(to, balance);
    }

    // Convenience function to withdraw to the owner
    function withdrawToOwner() public onlyOwner {
        withdraw(payable(owner()));
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
