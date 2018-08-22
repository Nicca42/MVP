pragma solidity 0.4.24;

import "./User.sol";
import "./ContentCreatorFactory.sol";

contract ContentCreator is User {
    address owner;
    address userContract;
    address ccFactoryAddress;
    ContentCreatorFactory ccf;
    User user;
   
    modifier isUser { 
        require(msg.sender == owner);
        _;
    }

    modifier onlyCCFactory {
        require(msg.sender == ccFactoryAddress);
    }

    modifer onlyAUser(address _user){
        require(ccF.onlyAUser(_user));
    }
   
    constructor(address _userContractAddress, address _contentCreatorFactory) 
        public 
        onlyAUser(msg.sender)
    {
        owner = msg.sender;
        userContract = _userContractAddress;
        ccFactoryAddress = _contentCreatorFactory;
        user = User(_userContractAddress);
        ccf = ContentCreatorFactory(_contentCreatorFactory);
    }

    //TODO: function to create contract 
    //TODO: security all calls in endpoint contracts must have call locks.
    //TODO: EXTRA lock syncroise between user and creator contract so that 
            //withdraw will not work on all contracts. 
            //make the loveFactory require the users or content creators 
            //own lock cannot be locked. 
}