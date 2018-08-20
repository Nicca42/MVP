pragma solidity 0.4.24;

import "./UserFactory.sol";
import "./ContentCreatorFactory.sol";
import "./LoveMachine.sol";

contract DataStorage {
    address public owner;
    
    address public userFactoryAddress;
    UserFactory uf;
    address public creatorFactoryAddress;
    ContentCreatorFactory ccf;
    address public minter;
    LoveMachine m;
    
    mapping (address => uint) public allUsers; //user contract address to views
    mapping (address => uint) public allCreators;//creator contract address to views
    mapping (address => string) public allUserNames;//user contract address to userName
    mapping (address => address) public userContractOwners;//user add to userContract add
    mapping (address => address) public creatorsContractOwners;//userContract to creatorContract
    address[] public usersAddresses;//contract addresses
    address[] public creatorsAddresses;//creators contract addresses
    string[] public usersNames;//userNames
    
    bool public emergencyStop = false;
    bool public pause = true;
    
    event LogEmergency(bool _emergency);
    
    event LogPause(bool _pause);
    
    event LogSetUp(address _userFactoryAddress, address _creatorFactoryAddress, address _minterAddress);
    
    event LogBoughtViewsUser(address _account, uint _amount);
    
    event LogUsedViewsUser(address _account, uint _amount);
    
    event LogUserCreated(address _owner, address _userContract, string _userName);
    
    event LogUserDeleted(address _owner, address _userContract, string _userName);
    
    event LogCreatorCreated(address _userCOwner, address _creatorContract);
    
    event LogCreatorDeleted(address _userContract, address _creatorContract);
    
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
        _;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyUserFactory {
        require(msg.sender == userFactoryAddress);
        _;
    }
    
    modifier onlyCreatorFactory {
        require(msg.sender == creatorFactoryAddress);
        _;
    }
    
    modifier onlyMinter(uint _amount) {
        require(msg.sender == minter);
        require(_amount > 0);
        _;
    }
    
    modifier uniqueUserName(string _userName) {
        for(uint i = 0; i < usersNames.length; i++){
            require(keccak256(_userName) != keccak256(usersNames[i]));
        }
        _;
    }
    
    modifier beforeDeleteChecksUser(address _userContract) {
        require(allUsers[_userContract] == 0);
        _;
    }
    
    modifier beforeDeleteChecksCreator(address _creatorContract) {
        require(allCreators[_creatorContract] == 0);
        _;
    }
    
    constructor()
        public
    {
        owner = msg.sender;    
    }
    
    
    function setUpDataContracts(
        address _userFactoryAddress, 
        address _creatorFactory,
        address _minter)
        public
        onlyOwner neverInEmergency
        returns(bool)
    {
        uf = UserFactory(_userFactoryAddress);
        ccf = ContentCreatorFactory(_creatorFactory);
        m = LoveMachine(_minter);
        
        setPause(false);
        
        LogSetUp(_userFactoryAddress, _creatorFactory, _minter);
        
        return true;
    }
    
    function setEmergency(bool emergencyState)
        public 
        onlyOwner 
        returns(bool)
    {
        emit LogEmergency(emergencyState);
        
        return emergencyStop = emergencyState;
    }
    
    function setPause(bool pauseState) 
        public
        onlyOwner
        returns(bool) 
    {
        emit LogPause(pauseState);
        
        return pause = pauseState;
    }
    
    function setNewUserData(address _user, address _userContract, string _userName)
        public 
        onlyUserFactory neverInEmergency uniqueUserName(_userName) pauseFunction
        returns(bool)
    {
        allUsers[_userContract] = 0;
        allUserNames[_userContract] = _userName;
        userContractOwners[_user] = _userContract;
        usersAddresses.push(_userContract);
        usersNames.push(_userName);
        
        emit LogUserCreated(_user, _userContract, _userName);
        
        return true;
    }
    
    function boughtViews(address _userContract, uint _amount)
        public 
        onlyMinter(_amount) neverInEmergency pauseFunction
        returns(bool)
    {
        allUsers[_userContract] += _amount;
        
        emit LogBoughtViewsUser(_userContract, _amount);
        
        return true;
    }
    
    function usedViews(address _userContract, uint _amount)
        public 
        onlyMinter(_amount) neverInEmergency pauseFunction
        returns(bool)
    {
        allUsers[_userContract] -= _amount;
        
        emit LogUsedViewsUser(_userContract, _amount);
        
        return true;
    }
    
    function removeUserData(address _user, address _userContract, string _userName)
        public
        onlyUserFactory neverInEmergency beforeDeleteChecksUser(_userContract) pauseFunction
        returns(bool)
    {
        delete allUsers[_userContract];
        delete allUserNames[_userContract];
        delete userContractOwners[_user];
        for(uint i = 0; i < usersAddresses.length; i++) {
            if(usersAddresses[i] == _userContract) {
                delete usersAddresses[i];
                break;
            }
        }
        for(uint a = 0; a < usersNames.length; a++) {
            if(keccak256(usersNames[a]) == keccak256(_userName)) {
                delete usersNames[a];
                break;
            }
        }
        
        emit LogUserDeleted(_user, _userContract, _userName);
        
        return true;
    }
    
    function setNewCreatorData(address _userContract, address _creatorContract) 
        public 
        onlyCreatorFactory neverInEmergency pauseFunction
        returns(bool)
    {
        allCreators[_creatorContract] = 0;
        creatorsContractOwners[_userContract] = _creatorContract;
        creatorsAddresses.push(_creatorContract);
        
        emit LogCreatorCreated(_userContract, _creatorContract);
        
        return true;
    }
    
    function removeCreatorData(address _userContract, address _creatorContract) 
        public
        onlyCreatorFactory neverInEmergency beforeDeleteChecksCreator(_creatorContract) pauseFunction
        returns(bool)
    {
        delete allCreators[_creatorContract];
        delete creatorsContractOwners[_userContract];
        for(uint a = 0; a < creatorsAddresses.length; a++) {
            if(creatorsAddresses[a] == _creatorContract) {
                delete creatorsAddresses[a];
                break;
            }
        }
        
        emit LogCreatorDeleted(_userContract, _creatorContract);
        
        return true;
    }
}