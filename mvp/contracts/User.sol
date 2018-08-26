pragma solidity 0.4.24;

import "./UserFactory.sol";
import "./3ContentCreatorFactory.sol";
import "./LoveMachine.sol";
import "./ContentCreator.sol";

contract User {
    UserFactory userFactory;
    address public owner;
    string public userName;
    uint public joinedDate;

    bool lock;
    
    //Ensures the sender is the owner. 
    modifier isUser {
        require(msg.sender == owner);
        _;
    }
    
    //Ensures the lock is not true.
    modifier checkLock {
        require(!lock);
        _;
    }
    
    //Ensures only the minter can call the function. 
    modifier onlyMinter {
        require(msg.sender == userFactory.getMinter());
        _;
    }
    
    //Ensures only the dataStorage can call the function.
    modifier onlyDataStorage {
        require(msg.sender == userFactory.getDataStorageAddress());
        _;
    }
    
    //Ensures only the wallet creator can call this function.
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    /**
      * @dev The constructor creates a new User. 
      * @notice The _userWallet is used when deleting account, as 
      *     all the views value will be sent to this address.
      *
      */
    //   / @param _userWallet : The address of the users wallet.
     //     _userName : The users uniqe userName. 
      //     _userFactory : The address of the user factory that 
      //         spawned this contract. 
    constructor(
        address _userWallet,
        string _userName
        ) 
        public 
    {
        owner = _userWallet;
        joinedDate = now;
        userName = _userName;
        userFactory = UserFactory(msg.sender);
    }
    
    /**
      * @return bool : If the contract is currently making 
      *     state changes. 
      */
    function getLock()
        public
        view
        returns(bool)
    {
        return(lock);
    }
    
    /**
      * @dev This allows the dataStorrage to set the user contract 
      *     to locked or unlocked, allowing it to prevent attacks from 
      *     reentry. 
      * @param _lock : What the lock must be set to. 
      */
    function setLock(bool _lock)
        public
        onlyDataStorage
    {
        lock = _lock;
    }
    
    /**
      * @dev Allows the user to buy views. 
      */
    function buyViews()
        public
        payable
        onlyOwner
    {
        LoveMachine minter = LoveMachine(userFactory.getMinter());
        minter.buyViews.value(msg.value)();
    }
    
    /**
      * @dev Allows the user to sell views. 
      * @param _amount : THe amount of views they wish to sell.
      */
    function sellViews(uint _amount)
        public
        onlyOwner
    {
        LoveMachine minter = LoveMachine(userFactory.getMinter());
        minter.sellViews(_amount);
    }
    
    /**
      * @dev Allows a user to transfer views between their creator and 
      *     user contracts. 
      * @param _amount : The amount of views they wish to transfer. 
      */
    function transferToCreatorAccount(uint _amount)
        public 
        onlyOwner
    {
        LoveMachine minter = LoveMachine(userFactory.getMinter());
        minter.TransferViewsToCreatorAccount(_amount);
    }
    
    /**
      * @dev Allows a user to transfer views between their creator and 
      *     user contracts. 
      * @param _amount : The amount of views they wish to transfer. 
      */
    function transferFromCreatorAccount(uint _amount)
        public
        onlyOwner
    {
        LoveMachine minter = LoveMachine(userFactory.getMinter());
        minter.TransferViewsToUserAccount(_amount);
    }
    
    /**
      * @dev Allows a user to become a content creator. 
      * @return bool : If it was successful in creating the 
      *     content creator account. 
      */
    function becomeContentCreator() 
        public
        isUser
        returns(bool) 
    {
        ContentCreatorFactory ccFactory = ContentCreatorFactory(userFactory.getContentCreatorFactory());
        return ccFactory.createContentCreator();
    }
    
    /**
      * @dev Allows the user to delete their account.
      * @notice User has to manyaly withdraw all funds 
      *     from account, as per the pull-over-push pattern.
      * @return bool : If the deletion was successful.
      */
    function deleteUser() 
        public
        isUser
        returns(bool) 
    {
        require(userFactory.deleteUserFinal(this));
        bool pass = userFactory.isCreator();
        if(pass) {
            ContentCreator cc = ContentCreator(userFactory.getCreatorAddress());
            cc.kill();
        }
        selfdestruct(owner);
        return true;
    }
}