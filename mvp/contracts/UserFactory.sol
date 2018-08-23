pragma solidity 0.4.24;

import "./1DataStorage.sol";
import "./2Register.sol";
import "./3ContentCreatorFactory.sol";
import "./User.sol";

contract UserFactory {
    DataStorage dataStorage;
    Register register;
    ContentCreatorFactory ccFactory;
    address dataStorageAddress; 
    address registerAddress;
    address owner;

    bool public emergencyStop = false;
    bool public pause = false;

    event LogCreatedUser(address _userAddress, address _contractAddress);
    
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

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier ownerOrRegister {
        require(msg.sender == owner || msg.sender == dataStorage.registryAddress());
        _;
    }
    
    modifier uniqueUserName(string _userName) {
        string[] memory allUserNames = dataStorage.getAllUsersNames();
        for(uint i = 0; i < allUserNames.length; i++){
            require(keccak256(_userName) != keccak256(allUserNames[i]));
        }
        _;
    }

    constructor(address _dataStorage, address _owner, address _ccFactory) 
        public 
    {
        owner = _owner;
        dataStorageAddress = _dataStorage;
        dataStorage = DataStorage(_dataStorage);
        ccFactory = ContentCreatorFactory(_ccFactory);
    }

    function createUser(string _userName) 
        public 
        uniqueUserName(_userName)
        stopInEmergency
        pauseFunction
        returns(address userContractAdd) 
    {
        //address _userWallet,
        //string _userName, 
        //address _userFactory
        address newUser = new User(msg.sender, _userName, this);
        dataStorage.setNewUserData(msg.sender, newUser, _userName);
        
        return newUser;
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
        return true;
    }
    
    function getMinter()
        public
        returns(address)
    {
        return dataStorage.minterAddress();
    }
    
    function getContentCreatorFactory()
        public
        returns(address)
    {
        return dataStorage.ccFactoryAddress();
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