// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Lesson_13.IERC20.sol";

contract ERC20 is IERC20{
    uint trxFee = 1;
    uint totalTokens;
    address owner;
    address[] addrs;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    string _name;
    string _symbol;

    function transactionFee() external view returns(uint){
        return trxFee;
    }

    function setTrxFee(uint _trxFee) external onlyOwner{
        trxFee = _trxFee;
    }

    function name() external view returns(string memory){
        return _name;
    }

    function symbol() external view returns(string memory){
        return _symbol;
    }

    function decimals() external pure returns(uint){
        return 18;
    }

    function totalSupply() external view returns(uint){
        return totalTokens;
    }


    modifier enoughTokens(address _from, uint _amount){
        require(balanceOf(_from) >= _amount, "not enogh tokens!");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not an owner!");
        _;
    }

    constructor(string memory name_ , string memory symbol_ , uint initialSupply, address shop){
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        mint(initialSupply, shop);

    }

    function balanceOf(address account) public view returns(uint){
       return balances[account];
    }

    function transfer(address to, uint amount) external enoughTokens(msg.sender, amount) {

        bool isExistingArrs;
        for (uint i = 0; i < addrs.length; i++) {
            if (addrs[i] == to) {
                isExistingArrs = true;
            }
        }
        if(isExistingArrs == false){
            addrs.push(to);
        }
        

        _beforeTokenTransfer(msg.sender, to, amount);

        balances[msg.sender] -= amount;
        balances[to] += (amount - calculateTrxFee(amount));

        for (uint i = 0; i < addrs.length; i++) {
            if(balances[addrs[i]] > 0 && balances[addrs[i]] != balances[msg.sender] && balances[addrs[i]] != balances[to]){
                balances[addrs[i]] += calculateTrxFee(amount) / addrs.length;
            }
                
        }

        emit Transfer(msg.sender, to, amount);
    }



    function calculateTrxFee(uint _amount) public view returns (uint){
        return (_amount / 100 ) * trxFee;
    }


    function mint(uint amount, address shop) public onlyOwner{
        _beforeTokenTransfer(address(0), shop, amount);
        balances[shop] += amount;
        totalTokens += amount;

        emit Transfer(address(0), shop, amount);

    }

    function burn(address _from, uint amount) public onlyOwner{
        _beforeTokenTransfer(_from, address(0), amount);
        balances[_from] -= amount;
        totalTokens -= amount;
    }

    function allowance(address _owner, address spender) public view returns(uint){
        return allowances[_owner][spender];
    }

    function approve(address spender, uint amount) public{
        _approve(msg.sender, spender, amount);
    }

    function _approve(address sender, address spender, uint amount) internal virtual {
        allowances[sender][spender] = amount;
        emit Approve(sender, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) public enoughTokens(sender, amount){
        _beforeTokenTransfer(sender, recipient, amount);
        
        allowances[sender][msg.sender] -= amount;

        balances[sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);


    }

    function _beforeTokenTransfer(
        address from,
        address to, 
        uint amount
    ) internal virtual {}

    fallback() external {}
}

contract piPhychyToken is ERC20{
    string constant name = "piPhychy";
    string constant symbol = "PPH";
    uint constant INITIAL_SUPPLY = 10000000000;

    constructor(address shop) ERC20(name, symbol, INITIAL_SUPPLY, shop) {}

}

contract PhychyShop{
    IERC20 public token;
    address payable public owner;
    event Bought(uint _amount, address indexed _buyer);
    event Sold(uint _amount, address indexed _seller);

    constructor(){
        token = new piPhychyToken(address(this));
        owner = payable(msg.sender);
    }

    

    modifier onlyOwner(){
        require(msg.sender == owner, "not an owner!");
        _;
    }

    function sell(uint _amountToSell) external{
        require(_amountToSell > 0 && token.balanceOf(msg.sender) >= _amountToSell, "incorrect amount!" );

        uint allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amountToSell, "check allowance!");

        token.transferFrom(msg.sender, address(this), _amountToSell);

        payable(msg.sender).transfer(_amountToSell);

        emit Sold(_amountToSell, msg.sender);
    }



    receive() external payable{
        uint tokensToBuy = msg.value / 10000000000;
        require(tokensToBuy > 0, "not enough funds!");   

        require(tokenBalance() >= tokensToBuy, "not enough tokens!");

        token.transfer(msg.sender, tokensToBuy);
        emit Bought(tokensToBuy, msg.sender);
    }

    fallback() external payable{}

    function tokenBalance() public view returns(uint){
        return token.balanceOf(address(this));
    }

    function withdraw() external onlyOwner{
        owner.transfer(address(this).balance);
    }
}
