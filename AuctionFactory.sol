// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Auction.sol";

contract AuctionFactory{
    address[] public auctions;
    event AuctionCreated(address auctionContract, address owner);
    
    function allAuctions() public view returns (address[] memory) {
        return auctions;
    }
    
    function createAuction(uint bidIncrement, uint startBlock, uint endBlock) public {
        Auction newAuction = new Auction(msg.sender, bidIncrement, startBlock, endBlock);
        auctions.push(address(newAuction));

        emit AuctionCreated(address(newAuction), msg.sender);
    }
}
