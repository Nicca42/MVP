pragma solidity 0.4.24;

import "./DataStorage.sol";
import "./Register.sol";
import "./ContentCreator.sol";

contract ContentCreatorFactory {
    DataStorage dataStorage;
    Register register;
    address dataStorageAddress;
    address registerAddress;
    address owner;

    bool public emergencyStop = false;
    bool public pause = false;

    modifier onlyUsers(address _user) {
        bool pass = false;
        address[] allUsers = dataStorage.getAllUserAddresses();
        for(uint i = 0; i < allUsers.length; i++) {
            if(allUsers[i] == _user) {
                pass = true;
            }
        }
        require(pass);
    }
    
    modifier onlyInEmergency {
        require(emergencyStop);
        _;
    }
    
    modifier stopInEmergency {
        require(!emergencyStop);
        _;
    }
    
    modifier pauseFunction {
        require(!pause);
        require(!dataStorage.getPause());
        _;
    }

    modifier ownerOrRegister {
        require(msg.sender == owner || msg.sender == dataStorage.registerAddress);
        _;
    }

    constructor(address _dataStorage, address _owner) 
        public 
    {
        owner = _owner;
        dataStorageAddress = _dataStorage;
        dataStorage = DataStorage(_dataStorage);
    }

    function onlyAUser(address _user)
        public
        returns(bool)    
    {
        bool pass = false;
        address[] allUsers = dataStorage.getAllUserAddresses();
        for(uint i = 0; i < allUsers.length; i++) {
            if(allUsers[i] == _user) {
                pass = true;
            }
        }
        return(pass);
    } 
     
    function createContentCreator()
        public 
        payable
        onlyUsers(msg.sender)
        stopInEmergency
        pauseFunction
        returns(address) 
    {
        //need to call the minter to take care of values. 
        address ccc = new ContentCreator(msg.sender);
        dataStorage.setNewCreatorData(msg.sender, ccc); 
        return ccc;
    }

    function kill(address _minter) 
        public 
        ownerOrRegister 
    {
        selfdestruct(_minter);
    }
}