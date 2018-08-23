pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import "./UserFactory.sol";
import "./3ContentCreatorFactory.sol";
import "./LoveMachine.sol";
import "./2Register.sol";

contract DataStorage {
    address public owner;

    UserFactory uf;
    ContentCreatorFactory ccf;
    LoveMachine m;
    Register registry;

    address public userFactoryAddress;
    address public ccFactoryAddress;
    address public minterAddress;
    address public registryAddress;
    
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
    mapping (address => Content[]) public creatorContent;//ccc to array of content
    uint private totalViewCreated;
    
    enum ViewsUsed {LIKED, LOVED, FANLOVED}
    ViewsUsed liked = ViewsUsed.LIKED;
    ViewsUsed loved = ViewsUsed.LOVED;
    ViewsUsed fanLoved = ViewsUsed.FANLOVED;
    
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
    
    modifier stopInEmergency {
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
        require(msg.sender == ccFactoryAddress);
        _;
    }
    
    modifier onlyMinter(uint _amount) {
        require(msg.sender == minterAddress);
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

    modifier onlyRegistry {
        require(msg.sender == registryAddress);
        _;
    }
    
    constructor()
        public
    {
        owner = msg.sender;    
        address _contentCreatorFactory = new ContentCreatorFactory(this, owner);
        ccFactoryAddress = _contentCreatorFactory;

        address _userFactory = new UserFactory(this, owner, _contentCreatorFactory);
        userFactoryAddress = _userFactory;

        address _minter = new LoveMachine(this, owner);
        minterAddress = _minter;

        address _registry = new Register(
            _userFactory,
            _contentCreatorFactory,
            _minter,
            owner,
            this
        );
        registryAddress = _registry;

        this.setUpDataContracts(
            _userFactory,
            _contentCreatorFactory,
            _minter,
            _registry
        );
    }
    
    function getAllUserAddresses() 
        public 
        view
        returns(address[])
    {
        return usersAddresses;
    }

    function getAllCreatorsAddresses() 
        public 
        view
        returns(address[])
    {
        return creatorsAddresses;
    }

    function getAllUsersNames() 
        public 
        view
        returns(string[])
    {
        return usersNames;
    }
    
    function getAUsersName(address _user)
        public
        view
        
        returns(string)    
    {
        return(allUserNames[_user]);
    }
    
    function isCreator(address _userAddress)
        public
        returns(bool)
    {
        if(creatorsContractOwners[_userAddress] != 0) {
            return true;
        }
        return false;
    }
    
    function isUser(address _userAddress)
        public
        returns(bool)
    {
        if(userContractOwners[_userAddress] != 0) {
            return true;
        }
        return false;
    }
    
    function getCreatorAddressFromUser(address _userAddress)
        public
        returns(address)
    {
        require(creatorsContractOwners[_userAddress] != 0);
        return creatorsContractOwners[_userAddress];
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
    
    function setTotalViewsDispenced(address _user, uint _amount) 
        public 
        onlyMinter(_amount)
    {
        UsersTotalViewPurchases[_user] += _amount;
        totalViewCreated += _amount;
    }
        
    function setUpDataContracts(
        address _userFactoryAddress, 
        address _creatorFactory,
        address _minter,
        address _registry
        )
        public
        onlyOwner 
        stopInEmergency
        returns(bool)
    {
        ccf = ContentCreatorFactory(_creatorFactory);
        uf = UserFactory(_userFactoryAddress);
        m = LoveMachine(_minter);
        registry = Register(_registry);
        
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
        uniqueUserName(_userName) 
        stopInEmergency
        pauseFunction
    {
        allUsers[_userContract] = 0;
        allUserNames[_userContract] = _userName;
        userContractOwners[_userContract] = _user;
        usersAddresses.push(_userContract);
        usersNames.push(_userName);
        
        emit LogUserCreated(_user, _userContract, _userName);
    }
    
    function registryUpdateUserFactory(address _newUserFactory)
    public
    onlyRegistry
    {
        uf = UserFactory(_newUserFactory);
    }
    
    function registryUpdateCCFactory(address _newCCFactory)
    public
    onlyRegistry
    {
        ccf = ContentCreatorFactory(_newCCFactory);
    }
    
    function registryUpdateMinter(address _newMinter)
    public
    onlyRegistry
    {
        m = LoveMachine(_newMinter);
    }
    
    function boughtViews(address _userContract, uint _amount)
        public 
        onlyMinter(_amount) 
        stopInEmergency 
        pauseFunction
        returns(bool)
    {
        allUsers[_userContract] += _amount;
        
        emit LogBoughtViewsUser(_userContract, _amount);
        
        return true;
    }
    
    function usedViews(address _userContract, uint _amount)
        public 
        onlyMinter(_amount) 
        stopInEmergency 
        pauseFunction
        returns(bool)
    {
        allUsers[_userContract] -= _amount;
        
        emit LogUsedViewsUser(_userContract, _amount);
        
        return true;
    }
    
    function storingLikes(ViewsUsed viewUsedRecived, address _contentOwner, address _user)
        public 
        onlyMinter(1)
    {
        if (viewUsedRecived == ViewsUsed.LIKED) {
            require(allUsers[_user] > 5);
            allUsers[_user] -= 5;
            allCreators[_contentOwner] += 5;
        }
        if (viewUsedRecived == ViewsUsed.LOVED) {
            require(allUsers[_user] > 15);
            allUsers[_user] -= 15;
            allCreators[_contentOwner] += 15;
        }
        if (viewUsedRecived == ViewsUsed.FANLOVED) {
            require(allUsers[_user] > 25);
            allUsers[_user] -= 25;
            allCreators[_contentOwner] += 25;
        }
    }
    
    function removeUserData(address _user, address _userContract, string _userName)
        public
        onlyUserFactory 
        beforeDeleteChecksUser(_userContract) 
        stopInEmergency
        pauseFunction
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
        onlyMinter(1) 
        stopInEmergency 
        pauseFunction
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
        //reducing balance of content creator
        require(allCreators[_contentCreatorContract] > 5);
        allCreators[_contentCreatorContract] -= 5;
        
        allContent.push(Content({
            creator: _contentCreatorContract,
            contentLocationIPFS: _addressIPFS,
            title: _title,
            description: _description,
            views: 0
        })); 
        //for front end to have access to lates and all content
        emit LogContentCreated(allContent.length, _title, _contentCreatorContract);
        //For the indervidual conent creators to be able to claim ownership of content
        Content[] storage temp = creatorContent[_contentCreatorContract];
        temp.push(Content({
            creator: _contentCreatorContract,
            contentLocationIPFS: _addressIPFS,
            title: _title,
            description: _description,
            views: 0
        }));
    }
    
    function removeCreatorData(address _userContract, address _creatorContract) 
        public
        onlyCreatorFactory 
        beforeDeleteChecksCreator(_creatorContract) 
        stopInEmergency
        pauseFunction
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

    function updateRegister(address _newRegister) 
        onlyRegistry
        public
    {
        registry = Register(_newRegister);
    } 
}