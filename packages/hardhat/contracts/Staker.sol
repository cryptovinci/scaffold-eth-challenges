pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

// Reference: https://dev.to/stermi/scaffold-eth-challenge-1-staking-dapp-4ofb
contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    mapping(address => uint256) public balances; // creates an empty map of addresses to unsigned integers

    uint256 constant threshold = .005 ether; // constant threshold of 1 ether

    event Stake(address indexed _stakingAddress, uint256 _balance); // event to emit to frontend

    // modifier checking if deadline has been met
    modifier deadlineReached() {
        uint256 timeRemaining = timeLeft();
        // require format: (condition, error message if not met)
        require(timeRemaining == 0, "Deadline not reached yet");
        _;
    }

    // modifier checking if deadline has been met
    modifier deadlineNotReached() {
        uint256 timeRemaining = timeLeft();
        // require format: (condition, error message if not met)
        require(timeRemaining > 0, "Deadline reached");
        _;
    }

    // modifier checking if staking has been completed
    modifier stakeNotCompleted() {
        bool notCompleted = !exampleExternalContract.completed();
        require(notCompleted, "staking completed");
        _;
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable deadlineNotReached stakeNotCompleted {
        balances[msg.sender] += msg.value; // update user's staked balances in mapping
        emit Stake(msg.sender, msg.value); // emit staking event to UI / blockchain
    }

    // After some `deadline` allow anyone to call an `execute()` function
    uint256 deadline = block.timestamp + 30 seconds;

    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
    function execute() public deadlineReached {
        // if this contract's balance is larger than the threshold, call external contract
        require(address(this).balance >= threshold, "threshold not reached!");
        exampleExternalContract.complete{value: address(this).balance}();
    }

    // Add a `withdraw(address payable)` function lets users withdraw their balance
    function withdraw(address payable)
        public
        deadlineReached
        stakeNotCompleted
    {
        uint256 userBalance = balances[msg.sender];

        require(userBalance > 0, "You don't have balance to withdraw");

        balances[msg.sender] = 0;

        // call = method to send funds to an address
        (bool sent, ) = msg.sender.call{value: userBalance}("");
        require(sent, "failed to send user balance back to user"); // error handling
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256 timeleft) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }

    // Add the `receive()` special function that receives eth and calls stake()
}
