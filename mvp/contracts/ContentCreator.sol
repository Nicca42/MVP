pragma solidity 0.4.24;

import "./User.sol";
import "./3ContentCreatorFactory.sol";
import "./LoveMachine.sol";

contract ContentCreator {
    ContentCreatorFactory ccFactory;
    User user;
    address public owner;
    address public userContract;
    address public ccFactoryAddress;
    
    bool ccLock;
   
   //Ensures the caller of the function is the userContract
   //that created it. 
    modifier isUser { 
        require(msg.sender == owner);
        _;
    }

    //Ensures the caller of the function is the 
    //ConetentCreatorFactory that spawner it. 
    modifier onlyCCFactory {
        require(msg.sender == ccFactoryAddress);
        _;
    }

    //Ensures the address is a user contract address.
    modifier onlyAUser(address _user){
        require(ccFactory.onlyAUser(_user));
        _;
    }
    
    //Ensures the lock is false.
    modifier checkLock {
        require(!user.getLock());
        require(!ccLock);
        _;
    }
    
    //Ensures the caller of the function is the minter. 
    modifier onlyMinter {
        address minter = ccFactory.getMinter();
        require(msg.sender == minter);
        _;
    }
    
    //Ensures only the dataStorage can call this function
    modifier onlyDataStorage {
        address dataStorage = ccFactory.getDataStorage();
        require(msg.sender == dataStorage);
        _;
    }
    
    /**
      * @dev Creates a new Conent creator. 
      * @notice This is called by the Content Creator Facotry, which 
      *     in turn is called by a user account. 
      * @param _userAccount : The user contract that called the 
      *         Content Creator Factory to become a content creator. 
      *     _contentCreatorFactory : The address of the content 
      *         creator factory. 
      */
    constructor(address _userAccount, address _contentCreatorFactory) 
        public 
        // onlyAUser(_userAccount)
    {
        owner = _userAccount;
        userContract = _userAccount;
        ccFactoryAddress = _contentCreatorFactory;
        user = User(_userAccount);
        ccFactory = ContentCreatorFactory(_contentCreatorFactory);
    }
    
    /**
      * @dev This allows the content creator to create content. 
      * @param _addressIPFS : The address of the content in IPFS. 
      *     _title : The title of the content.
      *     _description : The description or the 'About' for the content.
      * @return bool : If the minter created the content. 
      */
    function creatConent( 
        string _addressIPFS, 
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
        return minter.createContentMinter(_addressIPFS, _title, _description);
    }
    
    /**
      * @dev To ensure that the creator is not making any other state changes.  
      * @return bool : If the creator is locked. 
      */
    function getLock()
        public
        view
        returns(bool)
    {
        return(ccLock);
    }
    
    /**
      * @dev Sets the lock to the value given. 
      * @notice This is only changable by the dataStorage as 
      *     the dataStorage is the only thing able to do state 
      *     changes, it is the only thing able to lock users and 
      *     creators. 
      * @param _lock : The new vaule for lock. 
      */
    function setLock(bool _lock)
        public
        onlyDataStorage
    {
        ccLock = _lock;
    }
    
    /**
      * @return address : The address of the user contract that 
      *     created this creator account. 
      */
    function getOwner()
        public
        view
        returns(address)
    {
        return owner;
    }
    
    /**
      * @dev Allows the creator to destroy their account. 
      * @notice the killingContract() function transefers all  
      *     views to the user contract that created it, and 
      *     also sends any value in the contract to the user 
      *     contract as well. 
      */
    function kill() 
        public
        isUser
    {
        ccFactory.killingCreator();
        selfdestruct(owner);
    }
}