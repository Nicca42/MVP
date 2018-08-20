pragma solidity 0.4.24;

import "./User.sol";

contract ContentCreator is User {
    address owner;
    address userContract;
    uint[] keysToContent; //v1 hashes of content in ipfs
   
    modifier isUser { 
        require(msg.sender == owner);
        _;
    }
   
    constructor(address _UserContractAddress) 
    public {
        owner = msg.sender;
        userContract = _UserContractAddress;
    }
}