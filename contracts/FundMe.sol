// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error NotOwner();

contract FundMe{
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50*1e18;
    // 21,415 GAS - constant
    // 23,515 gas - non-constant

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    // function callMeRightAway(){

    // }
    address public immutable i_owner;
    // 21,508 gas - immutable
    // 23,644 gas - non-immutable

    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress){
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // Limit tinkering / triaging to 20 min
    // Take at least 15 min yourself -> or be 100% sure
    // you exhausted all options

    // 1. Tinker and try to pinpoint exactly what's goint on
    // 2. Google the exact error
    // 2.5 Got to our Github repo discussions and/or updates
    // 3 Ask a question on a forum like Stack Exchange ETH and Stack Overlow

    function fund() public payable{
        // Want to be able to set a minimum fund amount in USD
        // 1. How do we send ETH to this contract?

        require(msg.value.getConversionRate(priceFeed) >= MINIMUM_USD, "Didn't send enough!"); //1e18 == 1*10 ** 18 == weig
        // 18 decimals
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
        // What is reverting?
        // undo any action before, and send remaining gas back
    }

    function Withdraw() public onlyOwner{
        // require(msg.sender == owner, "Sender is not owner!");
        for(uint256 idx = 0; idx < funders.length; idx++){
            address funder = funders[idx];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);
        // actually withdraw the funds

        // transfer
        // msg.sender = address
        // payable(msg.sender) = payable address
        // payable(msg.sender).transfer(address(this).balance);
        
        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner{
        // require(msg.sender==i_owner,"Sender is not owner!");
        if(msg.sender!=i_owner){revert NotOwner();}
        _;
    }

    // What happens if someone sends this contract ETH without calling the fund function

    receive() external payable{
        fund();
    }

    fallback() external payable{
        fund();
    }
}