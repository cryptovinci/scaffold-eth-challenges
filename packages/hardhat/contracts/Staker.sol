pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    mapping(address => uint256) public balances; // creates an empty map of addresses to unsigned integers

    uint256 constant threshold = 1 ether; // constant threshold of 1 ether

    event Stake(address indexed _stakingAddress, uint256 _balance); // event to emit to frontend

    function stake() public payable {
        balances[msg.sender] += msg.value; // update user's staked balances in mapping
        emit Stake(msg.sender, msg.value); // emit staking event to UI / blockchain
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

    // if the `threshold` was not met, allow everyone to call a `withdraw()` function

    // Add a `withdraw(address payable)` function lets users withdraw their balance

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

    // Add the `receive()` special function that receives eth and calls stake()
}
