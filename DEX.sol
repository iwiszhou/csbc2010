// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./YorkERC20Token.sol";

contract DEX {

    IERC20 public token;
    address public owner;
    uint256 public price; // Indicate how much each token in Wei

    event Bought(uint256 amount);
    event Sold(uint256 amount);
    

    constructor(IERC20 _tokenContract) {
        token = _tokenContract;
        owner = msg.sender;
        //NOTE - In this cotract we defined price = 10^18 (Wei), which means buying 1 token need 10^18 Wei ( 10^18 Wei = 1 eth)
        price = (uint256(10) ** 18);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "unauthrozied");
        _;
    }
    
    function toUnit(uint256 _token) public returns(uint256){
        return _token * (uint256(10) ** token.decimals());
    }
    
    function buy(uint256 numberOfToken) payable public{
        //msg.value is how much Wei the buy passed
        //check msg.value should have enough Wei
        //eg: msg.value = 10^18 (1eth) and numberOfToken should be 1.
        //eg: msg.value = 2 * 10^18 (2eth) and numberOfToken should be 2.
        require(msg.value == numberOfToken * price, "insufficent");
        
        address _buyer = msg.sender;
        
        //conver token to unit
        uint256 _unitToBuy =  toUnit(numberOfToken);
        
        //check whether this contract has enought amount
        require(token.balanceOf(address(this)) >= _unitToBuy, "DEX doesn't have enough toke to sell");
        
        //transfer token to buyer, if error, revert
        require(token.transfer(_buyer,_unitToBuy), "Transfer failed - revert");
        
        //success, emit event
        emit Bought(_unitToBuy);
        
    }
    
    function sell(uint256 numberOfToken) payable public {
        uint256 _unitToSell = toUnit(numberOfToken); // 1 eth = 1 token
        address payable _caller = payable(msg.sender);
        
        require(token.balanceOf(_caller) >= _unitToSell, "insufficent");
        
        require(address(this).balance >= numberOfToken*price, "not enough eth");
        
        //let contract as spender. _caller allow contract to spend _amountTokenToSell
        // require(token.approve(address(this), _unitToSell), "Approve failed - revert");
        
        //update the balance in IERC20 - transfer token from _caller to contract
        require(token.transferFrom(_caller, address(this), _unitToSell), "Transfer failed - revert");

        
        //send eth back to _caller
        _caller.transfer(numberOfToken*price);
        
        //sucess, emit event
        emit Sold(_unitToSell);
    }
    
    //@dev Helper function - return how many token left in this contract
    function checkContractBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    //Unit Test
    
    //Before
    //by default YorkERC20Token has 1000000 token = 1000000 * 10^18 unit (decimals=18)
    
    //who deploy YorkERC20Token -   0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (Acct 1)
    //YorkERC20Token deloy address -0xd9145CCE52D386f254917e481eB44e9943F39138
    
    //who deply DEX -               0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (Acct 1)
    //DEX deploy address -          0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
    
    //Buyer address -               0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 (Acct 2)
    

    
    //Test case 0  - transfer 10 token = 10*10^18 unit to DEX
    // - balanceOf(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4) = 999990*10^18 = 999990000000000000000000
    // - balanceOf(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8) = 10*10^18 = 10000000000000000000
    
    //Test case 1 - Acct2 buy 4 token. need to pay 4 eth ( Because DEX price = 10^18 )
    // - Acct2
    //      - expect balanceOf(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2) = 4 * 10^18
    //      - expect account have 96 eth
    // - DEX
    //      - expect balanceOf(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8) = 6 * 10^18
    //      - expect this address have 4 eth
    
    //Test case 2 - Acct2 approve DEX as spender, and then Acct2 sell 1 token
    // - Acct2
    //      - expect balanceOf(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2) = 3 * 10^18
    //      - expect account have 97 eth
    // - DEX
    //      - expect balanceOf(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8) = 7 * 10^18
    //      - expect this address have 5 eth
    
}

