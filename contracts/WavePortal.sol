// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    string totalStory = "";

    /*
    * We will be using this below to help generate a random number
    */
    uint256 private seed;

    /*
    * Events are ways to communicate with a client application or front-end website
    * that something has happened on the blockchain
    */
    event NewStory(address indexed from, string textAdded, uint256 timestamp, string message);

    /*
    * I created a struct here named Story.
    * A struct is basically a custom datatype where we can customize what we want to hold inside it.
    */
    struct Story {
        address writter;
        string textAdded;
        uint256 timestamp;
        string message;
    }

    /*
    * I declare a variable stories that lets me store an array of structs.
    * This is what lets me hold all the waves anyone ever sends me!
    */
    Story[] stories;

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedAt;

    constructor() payable{
        console.log("Hello world, this is smart contract!");
        /*
         * Set the initial seed
         */
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function addStory(string memory story, string memory _message) public {
        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Wait 15m"
        );

        /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;
        
        totalStory = string(abi.encodePacked(totalStory, " ", story));
        console.log("%s is an author of this story!", msg.sender);

        /*
        * This is where I actually store the story data in the array.
        */
        stories.push(Story({
            writter: msg.sender,
            textAdded: story,
            timestamp: block.timestamp,
            message: _message
        }));

        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;
            // If require is false, it will quit the function and cancel the transaction.
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            // Sending the money!
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        /*
        * Emit an event to the client application or front-end website
        */
        emit NewStory(msg.sender, story, block.timestamp, _message);
    }

    function getAllStories() public view returns (Story[]memory) {
        return stories;
    }

    function getTotalStory() public view returns (string memory) {
        console.log("The story is: %s", totalStory);
        return totalStory;
    }
}