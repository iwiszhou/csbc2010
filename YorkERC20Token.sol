// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimals() external returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract  YorkERC20Token is IERC20{
    // Track how many tokens are owned by each address.
    mapping (address => uint256) public override balanceOf;

    string public name = "York Token";
    string public symbol = "YTN";
    uint256 public override decimals = 18;

    uint256 public override totalSupply = 1000000 * (uint256(10) ** decimals);

    // event Transfer(address indexed from, address indexed to, uint256 value);
    // event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor()  {
        // Initially assign all tokens to the contract's 
// creator.
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) public override returns (bool success) {
        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] -= value;  // deduct from 
// sender's balance
        balanceOf[to] += value;          // 
// add to recipient's balance
        emit Transfer(msg.sender, to, value);
        return true;
    }

    

    mapping(address => mapping(address => uint256)) public override allowance;

    function approve(address spender, uint256 value)
        public  override
        returns (bool success)
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        public override
        returns (bool success)
    {
        require(value <= balanceOf[from]);
        require(value <= allowance[from][msg.sender]);

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}
