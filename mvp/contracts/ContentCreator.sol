pragma solidity 0.4.24;

import "./User.sol";
import "./2Register.sol";
import "./3ContentCreatorFactory.sol";

contract ContentCreator is User {
    ContentCreatorFactory ccFactory;
    User user;
    address owner;
    address userContract;
    address ccFactoryAddress;
   
    modifier isUser { 
        require(msg.sender == owner);
        _;
    }

    modifier onlyCCFactory {
        require(msg.sender == ccFactoryAddress);
        _;
    }

    modifier onlyAUser(address _user){
        require(ccFactory.onlyAUser(_user));
        _;
    }
    
    constructor(address _userContractAddress, address _contentCreatorFactory) 
        public 
        onlyAUser(msg.sender)
    {
        owner = msg.sender;
        userContract = _userContractAddress;
        ccFactoryAddress = _contentCreatorFactory;
        user = User(_userContractAddress);
        ccFactory = ContentCreatorFactory(_contentCreatorFactory);
    }

    //TODO: function to create contract 
    //TODO: security all calls in endpoint contracts must have call locks.
    //TODO: EXTRA lock syncroise between user and creator contract so that 
            //withdraw will not work on all contracts. 
            //make the loveFactory require the users or content creators 
            //own lock cannot be locked. 
}