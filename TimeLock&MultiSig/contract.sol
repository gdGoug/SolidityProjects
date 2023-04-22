// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Timelock{
    uint constant MIN_DELAY = 10;
    uint constant MAX_DELAY = 1 days;
    uint constant GRACE_PERIOD = 1 days; 
    uint constant CONFIRMATIONS_REQUIRE = 4;

    string public  message;
    uint public amount;

    //address[] public owners;

    struct Transaction {
        bytes32 uId;
        address to;
        uint value;
        bytes data;
        bool executed;
        uint confirmations;
    }

    mapping(bytes32 => Transaction) public txs;
    mapping(bytes32 => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;
    mapping(bytes32 => bool) public  queue;



    event Queued(bytes32 txId);
    event Discarded(bytes32 txId);
    event Exucuted(bytes32 txId); 


    modifier onlyOwners(){
        require(isOwner[msg.sender], 'not an owner!');
        _;
    }

    constructor(address[] memory _owners){
        require(_owners.length >= CONFIRMATIONS_REQUIRE, "not enough owners");
        for(uint i = 0; i < _owners.length; i++){
            //address nextOwner = _owners[i];

            require(_owners[i] != address(0), "cant have zero address as owner!");
            require(!isOwner[_owners[i]], "duplicate owner!");
            isOwner[_owners[i]] = true;
            //owners.push(_owners[i]); delete
        }
    }
    function addToQueue(address _to, string calldata _func, bytes calldata _data, uint _value, uint _timestamp) external onlyOwners returns (bytes32){
        require(_timestamp > block.timestamp + MIN_DELAY && _timestamp < block.timestamp + MAX_DELAY, "Invalid timestamp");
        bytes32 txId = calculateHashTxId(_to, _func, _data, _value, _timestamp);

        require(!queue[txId], "alredy queued");

        queue[txId] = true;

        txs[txId] = Transaction({
            uId: txId,
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            confirmations: 0
        });
     

        emit Queued(txId);
        return txId;
    }

    function confirm(bytes32 _txId) external onlyOwners{
        require(queue[_txId], "not queued!");
        require(!confirmations[_txId][msg.sender], "alredy confirned!");

        Transaction storage transaction = txs[_txId];
        transaction.confirmations++;
        confirmations[_txId][msg.sender] = true;

    }

    function cancelConfirmation(bytes32 _txId) external onlyOwners{
        require(queue[_txId], "not queued!");
        require(confirmations[_txId][msg.sender], "not confirned!");

        Transaction storage transaction = txs[_txId];
        transaction.confirmations--;
        confirmations[_txId][msg.sender] = false;

    }

    function execute(address _to, string calldata _func, bytes calldata _data, uint _value, uint _timestamp) external payable onlyOwners returns(bytes memory){
        require(block.timestamp > _timestamp, "too early ");
        require(_timestamp + GRACE_PERIOD > block.timestamp, "tx expire");

        

        bytes32 txId = calculateHashTxId(_to, _func, _data, _value, _timestamp);

        require(queue[txId], "not queued");

        Transaction storage transaction = txs[txId];

        require(transaction.confirmations >= CONFIRMATIONS_REQUIRE, "not enough confirmations!");

        delete queue[txId];

        transaction.executed = true;

        bytes memory data;
        if(bytes(_func).length > 0){
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        } else{
            data = _data;
        }

        (bool success, bytes memory resp) =  _to.call{value: _value}(data);
        require(success);
        emit Exucuted(txId); 
        return resp; 
    }

    function discard(bytes32 _txId) external  onlyOwners {
        require(queue[_txId], "not queued");

        delete queue[_txId];

        emit Discarded(_txId);
    }

    function calculateHashTxId(address _to, string calldata _func, bytes calldata _data, uint _value, uint _timestamp) public pure returns(bytes32){
        return bytes32(keccak256(abi.encode(
            _to,
            _func,
            _data,
            _value,
            _timestamp
        )));

    }

    function demo(string calldata _msg) external payable{
        message = _msg;
        amount = msg.value;
    }

    function getNextTimestamp() external view returns(uint){
        return block.timestamp + 60;
    }

    function prepareData(string calldata _msg) external pure returns(bytes memory){
        return abi.encode(_msg);
    }

}
