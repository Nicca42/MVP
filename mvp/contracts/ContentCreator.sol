pragma solidity 0.4.24;

import "./User.sol";
import "./ContentCreatorFactory.sol";

contract ContentCreator is User {
    address owner;
    address userContract;
    ContentCreatorFactory ccf;
   
    modifier isUser { 
        require(msg.sender == owner);
        _;
    }
   
    constructor(address _UserContractAddress, address _ContentCreatorFactory) 
        public 
    {
        owner = msg.sender;
        userContract = _UserContractAddress;
        ccf = ContentCreatorFactory(_ContentCreatorFactory);
    }

    //TODO: function to create contract 
    //TODO: security all calls in endpoint contracts must have call locks.
    //TODO: EXTRA lock syncroise between user and creator contract so that 
            //withdraw will not work on all contracts. 
            //make the loveFactory require the users or content creators 
            //own lock cannot be locked. 
}