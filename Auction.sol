// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0-rc.0/contracts/access/Ownable.sol";
import "./IAuction.sol";

contract Auction is IAuction{
    
    address owner;
    uint256 startBlock;
    uint256 endBlock;
    uint256 bidIncrement;
    bool cancelled;
    address highestBidder;
    mapping(address => uint256) fundsByBidder;
    uint256 highestBindingBid;
    bool ownerHasWithdrawn;
    
    event LogBid(address sender, uint256 newBid, address highestBidder, uint256 highestBid, uint256 highestBindingBid);
    event LogWithdrawal(address sender, address withdrawalAccount, uint withdrawalAmount);
    event LogCanceled();
    
    modifier onlyAfterStart(){
        require( startBlock < block.number, "bid has not started yet" );
        _;
    }
    
    modifier onlyBeforeEnd(){
        require( endBlock < block.number, "bid is finished" );
        _;
    }
    
    modifier onlyNotCancelled(){
        require( !cancelled, "bid is cancelled" );
        _;
    }
    
    modifier onlyNotOwner(){
        require( msg.sender != owner, "you are the owner. Not allow to bid" );
        _;
    }
    
    modifier onlyEndedOrCanceled {
        require(block.number < endBlock && !cancelled);
        _;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "unauthorized");
        _;
    }
    
    constructor(address _owner, uint _bidIncrement, uint _startBlock, uint _endBlock) {
        require(_bidIncrement > 0, "_bidIncrement need > 0");
        require(_owner != address(0), "invalid address");
        require(_startBlock > block.number , "_startBlock should be a future time");
        require(_endBlock > _startBlock, "_endBlock should > _startBlock");
        
        owner = _owner;
        bidIncrement = _bidIncrement;
        startBlock = _startBlock;
        endBlock = _endBlock;
    }
    
    function min(uint256 a, uint256 b) pure internal returns(uint256){
        if(a > b) {
            return b;
        }
        
        return a;
    }
    
    function placeBid() public override payable
        onlyAfterStart 
        onlyBeforeEnd 
        onlyNotCancelled 
        onlyNotOwner 
    returns(bool){
        // only accept non zero payments
        if (msg.value == 0) {revert();}

        // add the bid sent to make total amount of the bidder            
        uint256 newBid = fundsByBidder[msg.sender] + msg.value;

        // user must send the bid amount greater than equal to 
        // highestBindingBid.
        if (newBid <= highestBindingBid) {revert();}

        // get the bid amount of highestBidder .
        uint256 highestBid = fundsByBidder[highestBidder];

        fundsByBidder[msg.sender] = newBid;

        if (newBid <= highestBid) {
            // Increase the highestBindingBid if the user has 
            // overbid the highestBindingBid but not highestBid. 
            // leave highestBidder alone

            highestBindingBid = min(newBid + bidIncrement, highestBid);
            
        } else {            
            // Make the new user highestBidder
            // if it has overbid highestBid completely

            if (msg.sender != highestBidder) {
                highestBidder = msg.sender;
                highestBindingBid = min(newBid, highestBid + bidIncrement);
            }
            highestBid = newBid;
        }

        emit LogBid(msg.sender, newBid, highestBidder, highestBid, highestBindingBid);
        return true;  
    }
    
    function withdraw() public override payable onlyEndedOrCanceled returns(bool){
        address withdrawalAccount;
        uint withdrawalAmount;

        if (cancelled) {
            // let everyone allow to withdraw if auction is cancelled
            withdrawalAccount = msg.sender;
            withdrawalAmount = fundsByBidder[withdrawalAccount];

        } else {
            // this logic will execute if auction finished
            // without getting cancelled
            if (msg.sender == owner) {
                // allow auction’s owner to withdraw 
                // highestBindingbid
                withdrawalAccount = highestBidder;
                withdrawalAmount = highestBindingBid;
                ownerHasWithdrawn = true;

            } else if (msg.sender == highestBidder) {
                // the highest bidder should only be allowed to 
                // withdraw the excess bid which is difference 
                // between highest bid and the highestBindingBid
                withdrawalAccount = highestBidder;
                if (ownerHasWithdrawn) {
                    withdrawalAmount = fundsByBidder[highestBidder];
                } else {
                    withdrawalAmount = fundsByBidder[highestBidder] - highestBindingBid;
                }

            } else {
                // the bidders who do not win highestBid are allowed
                // to withdraw their full amount
                withdrawalAccount = msg.sender;
                withdrawalAmount = fundsByBidder[withdrawalAccount];
            }
        }

        if (withdrawalAmount == 0) {revert();}

        fundsByBidder[withdrawalAccount] -= withdrawalAmount;

        // transfer the withdrawal amount
        if (!payable(msg.sender).send(withdrawalAmount)) {revert();}

        emit LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);

        return true;
    }
    
    function cancelAuction() public override 
        onlyOwner
        onlyBeforeEnd
        onlyNotCancelled
        returns(bool){
        cancelled = true;
        emit LogCanceled();
        return true;   
    }
}
