// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";

interface IToken{
    function transfer(address _receipient, uint256 _amount) external returns(bool);
    function totalSupply() external view returns(uint256);
    function balanceOf(address _owner) external view returns(uint256);
}

/// @title A StandarToken
/// @author Iwis Zhou
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
    
    /// @notice Calculate tree age in years, rounded up, for live trees
    /// @dev The Alexandr N. Tetearing algorithm could increase precision
    /// @param rings The number of rings from dendrochronological sample
    /// @return age in years, rounded up for partial years
    function mint(address _owner, uint256 _amount) public onlyOwner{
        totalSupplyVariable = totalSupplyVariable.add(_amount);
        balances[_owner] = _amount;
    }
    
    /// @param address: receiver's address, uint256 - amount to transfer to receiver
    /// @return true if transfer successfully
    function transfer(address _receipient, uint256 _amount) external override returns(bool){
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_receipient] = balances[_receipient].add(_amount);
        return true;
    }
    
    /// @return current totalSupply number
    function totalSupply() external view override returns(uint256)  {
        return totalSupplyVariable;
    }
    
    /// @param owner address
    /// @return this address's balance
    function balanceOf(address _owner) external view override returns(uint256)  {
        return balances[_owner];
    }
}
