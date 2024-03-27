// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// Remove Chainlink import statement

import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    // Remove PriceConverter library usage

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value >= MINIMUM_USD, "You need to spend more ETH!");
        
        if (addressToAmountFunded[msg.sender] == 0) {
            funders.push(msg.sender);
        }

        addressToAmountFunded[msg.sender] += msg.value;
    }
    
    modifier onlyOwner {
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        i_owner = newOwner;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address ; // Initialize with empty array
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
