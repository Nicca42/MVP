pragma solidity 0.4.24;

import "./DataStorage.sol";
import "./Register.sol";
import "./LoveMachine.sol";
import "./ContentCreator.sol";

contract ContentCreatorFactory {
    DataStorage dataStorage;
    Register register;
    address dataStorageAddress;
    address registerAddress;
    address owner;
     address[] public creatorAddresses;

    bool public emergencyStop = false;
    bool public pause = false;
    bool callOnce = false;

    //Ensures the address is a user address.
    modifier onlyUsers(address _user) {
        bool pass = false;
        pass = dataStorage.isUser(_user);
        require(pass);
        _;
    }
    
    //Ensures function is only used in emergency.
    modifier onlyInEmergency {
        require(emergencyStop);
        _;
    }
    
    //Ensures function is stopped during an emergency.
    modifier stopInEmergency {
        require(!emergencyStop);
        _;
    }
    
    //Ensures the contract has been set up
    modifier pauseFunction {
        require(!pause);
        require(!dataStorage.pause());
        _;
    }
    
    //Ensures the setUp function is only called once. 
    modifier onlyCallOnce {
        require(!callOnce, "This contract has already been set up");
        _;
    }

    //Ensures function is only called by owner or register.
    modifier ownerOrRegister {
        require(msg.sender == owner || msg.sender == dataStorage.registryAddress());
        _;
    }
    
    //Ensures only the creator can call this function
    modifier onlyCreator(address _ccc) {
        require(dataStorage.isCreator(msg.sender));
        require(msg.sender == _ccc);
        _;
    }

    /**
      * @dev Creates the contract.
      * @notice The constructor and contract setup has been seporated
      *     becuse the constructor dose not create an address for itself
      *     untill the constructor has finished. 
      */
    constructor(address _dataStorage) 
        public 
    {
        dataStorageAddress = _dataStorage;
        dataStorage = DataStorage(_dataStorage);
        owner = dataStorage.owner();
        
        callOnce = true;
    }
    
    // /**
    //   * @dev This function is used to set up the contract after the 
    //   *     constructor has created the contract address.
    //   * @notice The owner is set to the owner of the DataStorage. 
    //   *     This function can only be called once. 
    //   * @param _dataStorage : The address of the dataStorage that 
    //   *             created it. 
    //   */
    // function constructorFunction)
    //     public
    //     onlyCallOnce
    // {
        
    // }

    /**
      * @dev Used to check if an address is a user. 
      * @param _addressToCheck : The address to check.
      * @return bool : If the address is a user. 
      */
    function onlyAUser(address _addressToCheck)
        public
        view
        returns(bool)    
    {
        bool pass = false;
        address[] memory allUsers = dataStorage.getAllUserAddresses();
        for(uint i = 0; i < allUsers.length; i++) {
            if(allUsers[i] == _addressToCheck) {
                pass = true;
                break;
            }
        }
        return(pass);
    } 
     
     /**
       * @dev Creates a conent creator.
       * @notice Can only be called by a user. This function is 
       *    called directly from the users contract. 
       * @return bool : Returns what the minter function to 
       *    creator a creator returns. 
       */
    function createContentCreator()
        public 
        payable
        // onlyUsers(msg.sender)
        stopInEmergency
        pauseFunction
        returns(bool) 
    { 
        address ccc = new ContentCreator(msg.sender, this);
        creatorAddresses.push(ccc);
        return dataStorage.setNewCreatorData(msg.sender, ccc);
    }
    
    /**
      * @return address : The address of the current minter 
      *     from the dataStorage.  
      */
    function getMinter() 
        public
        view
        returns(address)
    {
        return dataStorage.getMinter();
    }
    
    function getDataStorage()
        public
        view
        returns(address)
    {
        return dataStorageAddress;
    }
    
    /**
      * @dev Sends all funds to user contract and then deletes
      *     all the content creators data. 
      */
    function killingCreator()
        public
        onlyCreator(msg.sender)
    {
        ContentCreator cc = ContentCreator(msg.sender);
        dataStorage.moveAllFundsToUser(msg.sender, cc.getOwner());
        dataStorage.removeCreatorData(cc.getOwner(), msg.sender);
    }

    /**
      * @dev Kills this contract and sends any finds to the 
      *     minter. 
      * @notice Can only be called by the 
      */
    function kill(address _minter) 
        public 
        ownerOrRegister 
    {
        selfdestruct(_minter);
    }
}