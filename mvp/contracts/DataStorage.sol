pragma solidity 0.4.24;

import "./UserFactory.sol";
import "./ContentCreatorFactory.sol";
import "./LoveMachine.sol";

contract DataStorage {
    address public owner;
    address private registry;

    UserFactory uf;
    ContentCreatorFactory ccf;
    LoveMachine m;
    Registry r;
    
    mapping (address => uint) public allUsers; //userContract to views
    mapping (address => uint) public UsersTotalViewPurchases;//userContract to total views bought
    mapping (address => uint) public allCreators;//creatorContract to views
    mapping (address => string) public allUserNames;//user contract address to userName
    mapping (address => address) public userContractOwners;//userContract add to user add ress
    mapping (address => address) public creatorsContractOwners;//userContract to creatorContract
    address[] public usersAddresses;//contract addresses
    address[] public creatorsAddresses;//creators contract addresses
    string[] public usersNames;//userNames
    struct Content {
        address creator;
        uint contentLocationIPFS;
        string title;
        string description;
        uint views;
    }
    Content[] public allContent;
    mapping (address => content[]) public CreatorContent;//ccc to array of content
    
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
    event LogContentCreated(uint indexed _position, string indexed _title, address indexed _creator);
    
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

    modifier onlyRegistry() {
        require(msg.sender == registry);
    }
    
    constructor()
        public
    {
        owner = msg.sender;    
        address _userFactory = new UserFactory(this, owner);
        address _contentCreatorFactory = new ContentCreatorFactory(this, owner);
        address _minter = new LoveMachine(this, owner);
        address _registry = new Register(
            _userFactoryAddress,
            _contentCreatorFactory,
            _minter,
            owner,
            this
        );
        this.setUpDataContracts(
            _userFactory,
            _contentCreatorFactory,
            _minter,
            _registry
        );
    }
    
    function getAllUserAddresses() 
        public 
        returns(address[])
    {
        return usersAddresses;
    }

    function getAllCreatorsAddresses() 
        public 
        returns(address[])
    {
        return creatorsAddresses;
    }

    function getAllUsersNames() 
        public 
        returns(string[])
    {
        return usersNames;
    }

    function registryUpdateContractState(address _newUserFactory)
    public
    onlyRegistry
    {

    }

    function getAUsersOwnerData(address _contractAddress)
    public
    returns(address _owner)
    {
        return(userContractOwners[_contractAddress]);
    }

    function getAUsersNameData(address _contractAddress)
        public
        returns(string _userName)
    {
        return(allUserNames[_contractAddress]);
    }

    function setUpDataContracts(
        address _userFactoryAddress, 
        address _creatorFactory,
        address _minter
        address _registry
        )
        public
        onlyOwner 
        neverInEmergency
        returns(bool)
    {
        uf = UserFactory(_userFactoryAddress);
        ccf = ContentCreatorFactory(_creatorFactory);
        m = LoveMachine(_minter);
        r = Registry(_registry);
        
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
        onlyUserFactory 
        neverInEmergency 
        uniqueUserName(_userName) 
        pauseFunction
    {
        allUsers[_userContract] = 0;
        allUserNames[_userContract] = _userName;
        userContractOwners[_userContract] = _user;
        usersAddresses.push(_userContract);
        usersNames.push(_userName);
        
        emit LogUserCreated(_user, _userContract, _userName);
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
        delete userContractOwners[_userContract];
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

    function createContent(
        address _contentCreatorContract, 
        uint _addressIPFS, 
        string _title, 
        string _description
        )
        public
        onlyMinter(1)
    {
        //in the ContentCreator contract the minter is called and paid for the creation
        //the minter then calls this function to compleate the creation of the content

        //for front end to have access to lates and all content
        allContent.push(Content(
            {
                creator: _contentCreatorContract,
                contentLocationIPFS: _addressIPFS,
                title: _title,
                description: _description,
                views: 0
            })); 
            emit LogContentCreated(allContent.length, _title, _contentCreatorContract);
        //For the indervidual conent creators to be able to claim ownership of content
        CreatorContent[_contentCreatorContract] = content.push(Content(
            {
            creator: _contentCreatorContract,
                contentLocationIPFS: _addressIPFS,
                title: _title,
                description: _description,
                views: 0
            }));
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

    //TODO: function isCreator(address _userContract) onlyMinter returns(bool)
            //determins whether a user address is a creator address
            //needs to have near identical modifer onlyCreator

    //TODO: function getCreatorAddressFromUser(address _userContract) onlyMinter onlyCreator(address) returns(address)
            //returns the creators addres from the user 
}