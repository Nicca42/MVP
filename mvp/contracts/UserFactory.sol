pragma solidity 0.4.24;

import "./User.sol";
import "./DataStorage.sol";

contract UserFactory {
    DataStorage dataStorage;
    mapping (address => string) public allUsers;
    dataStorage.getAllUsers;
    address[] public usersAddresses;
    string[] public usersNames;
    address owner;
    
    constructor(DataStorage _ds) public {
        owner == msg.sender;
        dataStorage = _ds;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier uniqueUserName(string _userName) {
        for(uint i = 0; i < usersNames.length; i++){
            require(keccak256(_userName) != keccak256(usersNames[i]));
        }
        _;
    }
    
    event LogCreatedUser(address _userAddress, address _contractAddress);

    function createUser(string _userName) 
    public 
    uniqueUserName(_userName)
    returns(address userContractAdd) {
        address newUser = new User(msg.sender, now, _userName, this);
        allUsers[newUser] = _userName;
        usersAddresses.push(newUser);
        usersNames.push(_userName);
        return newUser;
    }
    
    function deleteUserFinal(address _contractAddress)
    public 
    returns(bool) {
        require(msg.sender == _contractAddress);
        require(keccak256(allUsers[_contractAddress]) != keccak256(""));
        allUsers[_contractAddress] = "";
        for(uint i = 0; i < usersAddresses.length; i++) {
            if(usersAddresses[i] == _contractAddress) {
                delete usersAddresses[i];
                delete usersNames[i];
                return true;
            }
        }
        return false;
    }
    
    // function deteteFactory() 
    // public 
    // onlyOwner 
    // returns(bool) {
    //     //loop through all users and call their respective selfdestruct functions,
    //     //sending all Eth/views value to the owners of the user contracts. 
    // }
}