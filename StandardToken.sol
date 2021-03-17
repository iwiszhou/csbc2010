// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";

interface IToken{
    function transfer(address _receipient, uint256 _amount) external returns(bool);
    function totalSupply() external view returns(uint256);
    function balanceOf(address _owner) external view returns(uint256);
}

contract StandardToken is Ownable,IToken{
    using SafeMath for uint256;
    
    mapping(address => uint256) balances;
    uint256 totalSupplyVariable;
    string name;
    string symbol;
    
    constructor(uint256 _totalSupply, string memory _name, string memory _symbol) public{
        symbol = _symbol;
        name = _name;
        totalSupplyVariable = _totalSupply;
        
        balances[owner()] = 10; //init 10$ to the owner
    }
    
    function mint(address _owner, uint256 _amount) public onlyOwner{
        totalSupplyVariable = totalSupplyVariable.add(_amount);
        balances[_owner] = _amount;
    }
    
    function transfer(address _receipient, uint256 _amount) external override returns(bool){
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_receipient] = balances[_receipient].add(_amount);
    }
    
    function totalSupply() external view override returns(uint256)  {
        return totalSupplyVariable;
    }
    
    function balanceOf(address _owner) external view override returns(uint256)  {
        return balances[_owner];
    }
    
    //contract owner - 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // test A - 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
}
