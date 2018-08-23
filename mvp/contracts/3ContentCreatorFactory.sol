pragma solidity 0.4.24;

import "./1DataStorage.sol";
import "./2Register.sol";
import "./LoveMachine.sol";
import "./ContentCreator.sol";

contract ContentCreatorFactory {
    DataStorage dataStorage;
    Register register;
    address dataStorageAddress;
    address registerAddress;
    address owner;

    bool public emergencyStop = false;
    bool public pause = false;
    bool callOnce = false;

    modifier onlyUsers(address _user) {
        bool pass = false;
        address[] memory allUsers = dataStorage.getAllUserAddresses();
        for(uint i = 0; i < allUsers.length; i++) {
            if(allUsers[i] == _user) {
                pass = true;
            }
        }
        require(pass);
        _;
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
        require(!dataStorage.pause());
        _;
    }
    
    modifier onlyCallOnce {
        require(!callOnce, "This contract has already been set up");
        _;
    }

    modifier ownerOrRegister {
        require(msg.sender == owner || msg.sender == dataStorage.registryAddress());
        _;
    }

    constructor() 
        public 
    {
    
    }
    
    function constructorFunction(address _dataStorage, address _owner)
        public
        onlyCallOnce
    {
        owner = _owner;
        dataStorageAddress = _dataStorage;
        dataStorage = DataStorage(_dataStorage);
        callOnce = true;
    }

    function onlyAUser(address _user)
        public
        view
        returns(bool)    
    {
        bool pass = false;
        address[] memory allUsers = dataStorage.getAllUserAddresses();
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
        returns(bool) 
    { 
        LoveMachine minter = LoveMachine(dataStorage.minterAddress());
        return minter.createContentCreatorMinter(msg.sender); 
    }
    
    function getMinter() 
        public
        view
        returns(address)
    {
        return dataStorage.minterAddress();
    }

    function kill(address _minter) 
        public 
        ownerOrRegister 
    {
        selfdestruct(_minter);
    }
}