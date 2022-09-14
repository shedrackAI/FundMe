//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error NotOwner();
contract FundMe {
    using PriceConverter for uint;
    
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    // 21,415 gas - constant
    // 23,515 gas - non-constant

    address[] public funders;
    mapping(address => uint) public addressToAmountFunded;

    address public immutable i_owner;
    //21,508 gas - immutable
    //23,644 gas - non-immutable

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
      // msg.value.getConversionRate();
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough");
        funders.push(msg.sender); 
        addressToAmountFunded[msg.sender] += msg.value;
    } 

    function withdraw() public onlyOwner {
        for (uint funderIndex = 0; funderIndex > funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        
        //reset the Array
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner {
        require(msg.sender == i_owner, "Sendre is not owner");
        if (msg.sendre != !i_owner) { revert NotOwner();}
        _; // Doing the rest of the code
    }

    // what happens if someone sends this contract ETH without calling the fund function

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
