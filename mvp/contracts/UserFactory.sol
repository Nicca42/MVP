pragma solidity 0.4.24;

import "./User.sol";
import "./DataStorage.sol";

contract UserFactory {
    DataStorage dataStorage;
    address dataStorageAddress; 
    address owner;

    bool public emergencyStop = false;
    bool public pause = true;

    event LogCreatedUser(address _userAddress, address _contractAddress);
    
    modifier onlyInEmergency {
        require(emergencyStop);
        _;
    }
    
    modifier neverInEmergency {
        require(!emergencyStop);
        _;
    }
    
    modifier pauseFunction {
        require(!pause);
        require(!dataStorage.getPause());
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier uniqueUserName(string _userName) {
        string[] memory allUserNames = dataStorage.getAllUsersNames();
        for(uint i = 0; i < allUserNames.length; i++){
            require(keccak256(_userName) != keccak256(allUserNames[i]));
        }
        _;
    }

    constructor(address _dataStorageAddress) public {
        owner == msg.sender;
        dataStorage = DataStorage(_dataStorageAddress);
    }

    function createUser(string _userName) 
        public 
        uniqueUserName(_userName)
        returns(address userContractAdd) 
    {
        address newUser = new User(msg.sender, now, _userName, this);
        dataStorage.setNewUserData(msg.sender, newUser, _userName);
        
        return newUser;
    }
    
    function deleteUserFinal(address _contractAddress)
        public 
        returns(bool) 
    {
        require(msg.sender == _contractAddress);
        require(keccak256(dataStorage.allUserNames[_contractAddress]) != keccak256(""));
        
        //TODO: call minter to send remaining views to contract creator

        dataStorage.removeUserData(
            dataStorage.getAUsersOwnerData(_contractAddress), 
            _contractAddress,
            dataStorage.getAUsersNameData(_contractAddress));
        return true;
    }
}