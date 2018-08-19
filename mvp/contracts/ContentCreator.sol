pragma solidity 0.4.24;

contract ContentCreator {
    address owner;
    address userContract;
    uint[] keysToContent; //v1 hashes of content in ipfs
     uint totalViewsToWithdraw;
    uint totalWithdrawnViews;
    uint totalViewsAccumulated;
   
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