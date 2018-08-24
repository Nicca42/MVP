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
    uint public moderatorViews;
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
    event LogModeriatorFund(address _account, uint _amount);
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
    
    modifier onlyAUser(address _userAddress) {
        require(allUsers[_userAddress] != 0);
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
    
    modifier lockCheck(address _user) {
        User u = User(_user);
        bool lock = u.getLock();
        require(!lock);
        if(this.isCreator(_user)) {
            ContentCreator cc = ContentCreator(this.getCreatorAddressFromUser(_user));
            bool ccLock = cc.getLock();
            require(!ccLock);
        }
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
        ccFactoryAddress = new ContentCreatorFactory();
        userFactoryAddress = new UserFactory();
        minterAddress = new LoveMachine();
        registryAddress = new Register();
        
        ccf = ContentCreatorFactory(ccFactoryAddress);
        uf = UserFactory(userFactoryAddress);
        m = LoveMachine(minterAddress);
        registry = Register(registryAddress);
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
        view
        returns(bool)
    {
        if(creatorsContractOwners[_userAddress] != 0) {
            return true;
        }
        return false;
    }
    
    function isUser(address _userAddress)
        public
        view
        returns(bool)
    {
        if(userContractOwners[_userAddress] != 0) {
            return true;
        }
        return false;
    }
    
    function getCreatorAddressFromUser(address _userAddress)
        public
        view
        returns(address)
    {
        require(creatorsContractOwners[_userAddress] != 0);
        return creatorsContractOwners[_userAddress];
    }

    function getAUsersOwnerData(address _contractAddress)
        public
        view
        returns(address _owner)
    {
        return(userContractOwners[_contractAddress]);
    }

    function getAUsersNameData(address _contractAddress)
        public
        view
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
        
    function setUpDataContracts()
        public
        onlyOwner 
        stopInEmergency
        returns(bool)
    {
        ccf.constructorFunction(this, owner);
        uf.constructorFunction(this, owner, ccFactoryAddress);
        m.constructorFunction(this, owner);
        registry.constructorFunction(
            userFactoryAddress,
            ccFactoryAddress,
            minterAddress,
            owner,
            this
        );
        
        setPause(false);
        
        LogSetUp(userFactoryAddress, ccFactoryAddress, minterAddress);
        
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
        //TODO: create new version before setting object
    }
    
    function registryUpdateMinter(address _newMinter)
    public
    onlyRegistry
    {
        m = LoveMachine(_newMinter);
    }
    
    /**
      * @dev Locks the user so that no other state changes
      *     for that user may occur at the same time, thus preventing reentry attacks 
      *     and other recursion atacks. It also helps with code readability.
      *     As an instance of a User is being created, we have to check the address
      *     dose belong to a user. 
      * @notice creating instances of the users is expensive and inifiecient. Future
      *     versions will allow for the users data to be entirely stored in the 
      *     dataStorage, meaning an instance of the user dose not need to be created 
      *     to check or set their lock. 
      * @param The user who is making the state change. 
      */
    function lockUser(address _user) 
        private
        onlyAUser(_user)
    {
        User u = User(_user);
        u.setLock(true);
        if(this.isCreator(_user)) {
            ContentCreator ccc = ContentCreator(this.getCreatorAddressFromUser(_user));
            ccc.setLock(true);
        }
    }
    
    /**
      * @dev Unlocks the user so they may make other state changes. 
      * @notice creating instances of the users is expensive and inifiecient. Future
      *     versions will allow for the users data to be entirely stored in the 
      *     dataStorage, meaning an instance of the user dose not need to be created 
      *     to check or set their lock. 
      * @param The user who is being unlocked to make state changes.
      */
    function unlockUser(address _user)
        private
        onlyAUser(_user)
    {
         User u = User(_user);
        u.setLock(false);
        if(this.isCreator(_user)) {
            ContentCreator ccc = ContentCreator(this.getCreatorAddressFromUser(_user));
            ccc.setLock(false);
        }
    }
        
    /**
      * @dev Saves a users purchase of views after LoveMachine has been paid.
      * @param address _userContract: The users contract address.
      *     uint _amount: The amount of views the user has already paid for in the 
      *         LoveMachine.
      * @returns bool After it has changed the users balance.
      */
    function buyViewsSave(address _userContract, uint _amount)
        public
        onlyMinter(_amount)
        lockCheck(_userContract)
        returns(bool)
    {
        lockUser(_userContract);
        
        allUsers[_userContract] += _amount;
        
        unlockUser(_userContract);
        return true;
    }
    
    /**
      * @dev Saves a users sale of views before the LoveMachine pays the user the 
      *     value of the views in Ether.
      * @notice the assert is used as a prevention of underflow.
      * @param address _userContract: The users contract address.
      *     uint _amount: The amount of views the user is selling. 
      * @returns bool After it has changed the users balance.
      */
    function sellViewsSave(address _userContract, uint _amount)
        public
        onlyMinter(_amount)
        lockCheck(_userContract)
        returns(bool)
    {
        lockUser(_userContract);
        
        assert(allUsers[_userContract] - _amount > 0);
        
        allUsers[_userContract] -= _amount;
        
        unlockUser(_userContract);
    }
    
    /**
      * @depracated Made the stack too deep.
      */
    // function recivedViews(address _reciver, uint _amount, address _sender)
    //     public
    //     onlyMinter(_amount)
    //     onlyAUser(_reciver)
    //     onlyAUser(_sender)

    //     stopInEmergency
    //     pauseFunction
    //     returns(bool compleated)
    // {
    //     User reciver = User(_reciver);
    //     User sender = User(_sender);
        
    //     reciver.setLock(true);
    //     sender.setLock(true);
        
        
    // }
    
    /**
      * @dev Minter calls this function whenever views are charged (for the creation
      *     of a Creator account, the uploading of content etc). 
      * @notice This fund will pay the moderator in later versions.
      * @param address _userContract: This is included as users will have the 
      *         ability to donate towards the moderator fund and may want 
      *         recognition. 
      *     uint _amount: the amount of views added to the moderator fund so they 
      *         may be tracked in the LoveMachines Ether pool. 
      */
    function usedViews(address _userContract, uint _amount)
        public 
        onlyMinter(_amount) 
        stopInEmergency 
        pauseFunction
        returns(bool)
    {
        moderatorViews += _amount;
        
        emit LogModeriatorFund(_userContract, _amount);
        
        return true;
    }
    
    /**
      * @dev Minter calls this when a user likes content. 
      * @notice Only the user is locked as the content creator should be able to 
      *     recive multipule likes, and should not be licked by each one as this 
      *     would slow down the system sygnificantly.
      */
    function storingLikes(ViewsUsed viewUsedRecived, address _contentOwner, address _user)
        public 
        onlyMinter(1)
        lockCheck(_user)
    {
        lockUser(_user);
        
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
        
        unlockUser(_user);
    }
    
    /** 
      * @dev Called by the users Factory by the users contract to delete the 
      *     users details and send all their views back to them as Ether. 
      * @notice This method implements the lock to ensure no other transactions
      *     are happening before the users Contract is deleted.
      * @param address _user: the address of the users contract. To be removed 
      *         in future versions and the address of the users wallet from 
      *         storage.
      *     address _userContract: The address of the users Contract.
      *     string _usrName: The users name.
      */
    function removeUserData(address _user, address _userContract, string _userName)
        public
        onlyUserFactory 
        beforeDeleteChecksUser(_userContract) 
        stopInEmergency
        pauseFunction
        returns(bool)
    {
        //function is called through the user factory, but the account should 
            //have all funds sent to their users wallets. 
        //TODO: delete creator content as well. 
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
        require(allUsers[_userContract] > 5, "You need to like your own stuff.");
        allUsers[_userContract] -= 5;
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
        creatorContent[_contentCreatorContract].push(Content({creator: _contentCreatorContract,
        contentLocationIPFS: _addressIPFS,
        title: _title,
        description: _description,
        views: 0}));
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
        uint length = creatorContent[_contentCreatorContract].length;
        creatorContent[_contentCreatorContract][length] = Content({
            creator: _contentCreatorContract,
            contentLocationIPFS: _addressIPFS,
            title: _title,
            description: _description,
            views: 0
        });
        
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