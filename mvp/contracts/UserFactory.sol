pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import "./DataStorage.sol";
import "./Register.sol";
import "./ContentCreatorFactory.sol";
import "./User.sol";

contract UserFactory {
    DataStorage dataStorage;
    Register register;
    ContentCreatorFactory ccFactory;
    address dataStorageAddress; 
    address registerAddress;
    address owner;
    address[] public userAddresses;

    bool public emergencyStop = false;
    bool public pause = false;
    bool private callOnce = false;

    event LogCreatedUser(address _userAddress, address _contractAddress);
    
    //Ensures the function is only used in an emergency.
    modifier onlyInEmergency {
        require(emergencyStop);
        _;
    }
    
    //Ensures the function stops in an emergency.
    modifier stopInEmergency {
        require(!emergencyStop);
        _;
    }
    
    //Ensures the function is paused untill set-up.
    modifier pauseFunction {
        require(!pause);
        require(!dataStorage.pause());
        _;
    }
    
    //Ensures the function is only called nce.
    modifier onlyCallOnce {
        require(!callOnce, "This contract has already been set up");
        _;
    }

    //Ensures only the owner can call the function.
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //Ensures only the owner or the register can call this function. 
    modifier ownerOrRegister {
        require(msg.sender == owner || msg.sender == dataStorage.registryAddress());
        _;
    }
    
    /**
      * @dev The constructor for the UserFactory. 
      */
    constructor(address _dataStorage, address _owner, address _ccFactory) 
        public 
    {
        dataStorageAddress = _dataStorage;
        dataStorage = DataStorage(_dataStorage);
        owner = _owner;
        ccFactory = ContentCreatorFactory(_ccFactory);
    }
    
    // function constructorFunction(address _dataStorage, address _owner, address _ccFactory)
    //     public
    //     onlyCallOnce
    // {
    //     owner = _owner;
    //     dataStorageAddress = _dataStorage;
    //     dataStorage = DataStorage(_dataStorage);
    //     ccFactory = ContentCreatorFactory(_ccFactory);
    //     callOnce = true;
    // }
    
    
    /**
      * @return address : The address of the current LoveMahcine.
      */
    function getMinter()
        public
        view
        returns(address)
    {
        return dataStorage.minterAddress();
    }
    
    /**
      * @return address : The current address of the 
      *     ContentCreatorFactory. 
      */
    function getContentCreatorFactory()
        public
        view
        returns(address)
    {
        return dataStorage.ccFactoryAddress();
    }
    
    /**
      * @return bool : If the msg.sender is a creator. 
      */
    function isCreator()
        public 
        view
        returns(bool)
    {
        return dataStorage.isCreator(msg.sender);
    }
    
    /**
      * @return address : The address of this users creator 
      *     contract. 
      */
    function getCreatorAddress()
        public
        view
        returns(address)
    {
        return dataStorage.getCreatorAddressFromUser(msg.sender);
    }
    
    /**
      * @return address : The address of the dataStorage. 
      */
    function getDataStorageAddress()
        public
        view 
        returns(address)
    {
        return dataStorageAddress;
    }
    
    /**
      * @dev The function that creates a new user.
      * @notice The user name is checked for uniqueness in the 
      *     dataStorage. 
      *     The contract is created before this and 
      * @param _userName : The user name the user has entered. 
      * @return address : The address of the new user contract. 
      */
    function createUser(string _userName) 
        public 
        // stopInEmergency
        // pauseFunction
        // returns(address) 
    {
        //require(dataStorage.isUnique(_userName), "The user name is not unique.");
        address newUser = new User(msg.sender, _userName);
        userAddresses.push(newUser);
        dataStorage.setNewUserData(msg.sender, newUser, _userName);
        
        // return newUser;
    }
    
    function deleteUserFinal(address _contractAddress)
        public 
        stopInEmergency
        pauseFunction
        returns(bool) 
    {
        require(msg.sender == _contractAddress);
        string memory _userName = dataStorage.getAUsersName(_contractAddress);
        require(keccak256(_userName) != keccak256(""));
        
        //TODO: call minter to send remaining views to contract creator

        dataStorage.removeUserData(
            dataStorage.getAUsersOwnerData(_contractAddress), 
            _contractAddress,
            dataStorage.getAUsersNameData(_contractAddress));
            
            //TODO: needs to check if user is a creator and delete creator too
        return true;
    }

    function kill(address _minter) 
        public 
        ownerOrRegister 
    {
        selfdestruct(_minter);
        //v2 could just have a 
        //bool death private;
        //that needs 
        //to be false and when its set to true the contract 
        //is dead.
    }
}