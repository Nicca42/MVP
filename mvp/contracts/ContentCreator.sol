pragma solidity 0.4.24;

import "./1DataStorage.sol";
import "./User.sol";
import "./3ContentCreatorFactory.sol";
import "./LoveMachine.sol";

contract ContentCreator {
    ContentCreatorFactory ccFactory;
    User user;
    address owner;
    address userContract;
    address ccFactoryAddress;
    
    bool ccLock;
   
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
    
    modifier checkLock {
        require(!user.getLock());
        require(!ccLock);
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
    
    function creatConent(
        address _contentCreatorContract, 
        uint _addressIPFS, 
        string _title, 
        string _description
        )
        public
        payable
        checkLock
        returns(bool)
    {
        LoveMachine minter = LoveMachine(ccFactory.getMinter());
        address(minter).transfer(msg.value);
        return minter.createContentMinter(this, _addressIPFS, _title, _description);
    }
    
    function getLock()
        public
        view
        returns(bool)
    {
        return(ccLock);
    }
}