pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import "./UserFactory.sol";
import "./ContentCreatorFactory.sol";
import "./LoveMachine.sol";
import "./Register.sol";

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
        address userOwner;
        address creator;
        string contentLocationIPFS;
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
    
    event LogEmergency(bool emergency);
    event LogPause(bool pause);
    event LogSetUp(address userFactoryAddress, address creatorFactoryAddress, address minterAddress, address register);
    event LogBoughtViewsUser(address account, uint amount);
    event LogSoldViewsUser(address account, uint amount);
    event LogModeriatorFund(address account, uint amount);
    event LogUserCreated(address owner, address userContract, string userName);
    event LogUserDeleted(address owner, address userContract, string userName);
    event LogCreatorCreated(address userCOwner, address creatorContract);
    event LogCreatorDeleted(address userContract, address creatorContract);
    event LogContentCreated(uint position, string title, address creator);
    // event LogContentCreated(uint indexed position, string indexed title, address indexed creator);
    event LogCheckingData(address userContract);
    
    //Ensures the user can still withdraw during an emergency.
    modifier onlyInEmergency {
        require(emergencyStop);
        _;
    }
    
    //Ensures no sensitive transations happen in an emergency.
    modifier stopInEmergency {
        require(!emergencyStop);
        _;
    }
    
    //Ensures no state changes can happen untill the 
    //contract has finished being set up.
    modifier pauseFunction {
        require(!pause, "Contract requires set-up.");
        _;
    }
    
    //Ensures only the user can call the function.
    modifier onlyOwner {
        require(msg.sender == owner, "Sender is not owner.");
        _;
    }
    
    //Ensures only the owner can call the function 
    // modifier onlyAUser(address _userAddress) {
    //     require(allUsers[_userAddress] != 0, "Address is not a user address.");
    //     _;
    // }
    
    //Ensures only the ContentCreatorFactory can call
    //the function. Calls from register so that the most 
    //up to date contract is always used. 
    modifier onlyCreatorFactory {
        require(
            msg.sender == registry.getContentCreatorFactory(),
            "Sender is not CreatorFacotry."
        );
        _;
    }
    
    //Ensures only the minter may call the function
    modifier onlyMinter(uint _amount) {
        require(msg.sender == registry.getMinter(), "Sender is not Minter");
        require(_amount > 0, "Amount cannot be negative.");
        _;
    }
    
    //Ensures only they UserFactory can call the function.
    modifier onlyUserFactory {
        require(msg.sender == registry.getUserFactory(), "Sender is not UserFactory");
        _;
    }
    
    //Ensures only the Register can call this function.
    modifier onlyRegistry {
        require(msg.sender == registryAddress, "Sender is not Register");
        _;
    }
    
    //Ensures the user is not making another state change. 
    modifier lockCheck(address _user) {
        // require(isUser(_user), "User must be registed");
        User u = User(_user);
        bool lock = u.getLock();
        require(!lock, "Contract currently locked. Please wait.");
        if(this.isCreator(_user)) {
            ContentCreator cc = ContentCreator(this.getCreatorAddressFromUser(_user));
            bool ccLock = cc.getLock();
            require(!ccLock, "Contract currently locked. Please wait.");
        }
        _;
    }
    
    //Ensures the user has no more views before they get deleted. 
    modifier beforeDeleteChecksUser(address _userContract) {
        require(
            allUsers[_userContract] == 0, 
            "User account must be empty before being killed."
        );
        _;
    }
    
    //Ensures the Creator has no more views before 
    //deleteing their account. 
    modifier beforeDeleteChecksCreator(address _creatorContract) {
        require(
            allCreators[_creatorContract] == 0, 
            "Creator account must be empty before being killed."
        );
        _;
    }
    
    /**
      * @dev Creates all the contracts that use this dataStorage. 
      * @notice The constructor and contract setup has been seporated
      *     becuse the constructor dose not create an address for itself
      *     untill the constructor has finished. 
      */
    constructor()
        public
    {
        owner = msg.sender;    
    }
    
    /**
      * @dev This function sets up all the contracts and inputs the 
      *     various addresses they all need after they have all been 
      *     created by blank constructors. 
      * @notice This function sets paused to false and allows the data 
      *     storage to be used for state modification. 
      */
    function setUpDataContracts(
        address _userFactoryAddress,
        address _ccFactoryAddress,
        address _minterAddress,
        address _register
        )
        public
        onlyOwner 
        stopInEmergency
        returns(bool)
    {
        ccf = ContentCreatorFactory(_ccFactoryAddress);
        ccFactoryAddress = _ccFactoryAddress;
        uf = UserFactory(_userFactoryAddress);
        userFactoryAddress = _userFactoryAddress;
        m = LoveMachine(_minterAddress);
        minterAddress = _minterAddress;
        registry = Register(_register);
        
        setPause(false);
        
        emit LogSetUp(_userFactoryAddress, _ccFactoryAddress, _minterAddress, _register);
        
        return true;
    }

    /**
      * @param _userAddress : The address of the user 
      *     that is being checked as a creator. 
      * @return bool : Wether they are a creator or not.      
      */
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
    
    /**
      * @param _addressToCheck : The address to be checked. 
      * @return bool : Wether the address is a user. 
      */
    function isUser(address _addressToCheck)
        public
        view
        returns(bool)
    {
        if(userContractOwners[_addressToCheck] != 0) {
            return true;
        }
        return false;
    }
    
    event LogIsUser(string usedIn, bool passed);
    //TO REMOVE
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
      * @param _user : The user who is making the state change. 
      */
    function lockUser(address _user) 
        private
        pauseFunction
    {
        User u;
        u = User(_user);
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
      * @param _user : The user who is being unlocked to make state changes.
      */
    function unlockUser(address _user)
        private
        pauseFunction
    {
        User u;
        u = User(_user);
        u.setLock(false);
        if(this.isCreator(_user)) {
            ContentCreator ccc = ContentCreator(this.getCreatorAddressFromUser(_user));
            ccc.setLock(false);
        }
    }
    
    /**
      * @return address : The address of the minter.
      */
    function getUserFactory()
        public
        view
        returns(address)
    {
        return registry.getUserFactory();
    }

    /**
      * @return address : The address of the minter.
      */
    function getCCFactory()
        public
        view
        returns(address)
    {
        return registry.getContentCreatorFactory();
    }

    /**
      * @return address : The address of the minter.
      */
    function getMinter()
        public
        view
        returns(address)
    {
        return registry.getMinter();
    }
    
    /**
      * @return address[] : The addresses of all Users. 
      */
    function getAllUserAddresses() 
        public 
        view
        returns(address[])
    {
        return usersAddresses;
    }

    /**
      * @return address[] : The addresses of all creators. 
      */
    function getAllCreatorsAddresses() 
        public 
        view
        returns(address[])
    {
        return creatorsAddresses;
    }

    /**
      * @return string[] : All user names registered. 
      */
    function getAllUsersNames() 
        public 
        view
        returns(string[])
    {
        return usersNames;
    }
    
    /**
      * @param _user : The address of the user whos 
      *     name is wanted.  
      * @return string : A users name. 
      */
    function getAUsersName(address _user)
        public
        view
        returns(string)    
    {
        //require(isUser(_user));
        return(allUserNames[_user]);
    }
    
    /**
      * @param _userAddress : The user address
      * @return address : The address of the users Creator contract. 
      */
    function getCreatorAddressFromUser(address _userAddress)
        public
        view
        returns(address)
    {
        require(creatorsContractOwners[_userAddress] != 0);
        return creatorsContractOwners[_userAddress];
    }

    /**
      * @param _contractAddress : The address of the users contract. 
      * @return address : The address of the owner.
      */
    function getAUsersOwnerData(address _contractAddress)
        public
        view
        returns(address)
    {
        require(userContractOwners[_contractAddress] != 0);
        return(userContractOwners[_contractAddress]);
    }

    /**
      * @param _contractAddress : The address of the useowner.
      * @return string : The users UserName. 
      */
    function getAUsersNameData(address _contractAddress)
        public
        view
        returns(string)
    {
        //require(allUsers[_contractAddress] != 0);
        return(allUserNames[_contractAddress]);
    }
    
    /**
      * @dev This function dose not need user locks or safy checks 
      *     as it is mearly a counter for views dispenced and the users 
      *     total amount of views purchased. 
      * @param _user : The users address.
      *     _amount : The amount of views purchased. 
      */
    function setTotalViewsDispenced(address _user, uint _amount) 
        public 
        onlyMinter(_amount)
        stopInEmergency
        pauseFunction
    {
        UsersTotalViewPurchases[_user] += _amount;
        totalViewCreated += _amount;
    }
    
    /**
      * @dev For when a content creator whishes to delete their account.
      * @param _ccc : The content creator contract address.
      *     _userContract : The address of the users account.
      */
    function moveAllFundsToUser(address _ccc, address _userContract)
        public
        onlyCreatorFactory
        lockCheck(_userContract)
    {
        lockUser(_userContract);
        
        uint allFunds = allCreators[_ccc];
        allCreators[_ccc] -= allFunds;
        
        allUsers[_userContract] += allFunds;
        
        unlockUser(_userContract);
    }
    
    /**
      * @dev Called when views are being taken out of an account 
      *     and  do not need to be paid to a creator.
      * @param _adder : Whom ever is being 'charged' the View.
      *     _amount : The amount of views being taken from the adder. 
      * @return bool : Compleated function. 
      */
    function addToModeratorFund(address _adder, uint _amount)
        internal 
        returns(bool)
    {
        require(_amount > 0);
        moderatorViews += _amount;
        
        emit LogModeriatorFund(_adder, _amount);
    }
    
    /**
      * @dev Allows for the owner to set the emergency state. 
      * @notice This function takes in a bool instead of being two 
      *     functions (one that sets true and one that sets false) 
      *     as to simplify access. 
      * @param _emergencyState : The state to set emergency to. 
      * @return bool : Returns true once function compleate.
      */
    function setEmergency(bool _emergencyState)
        public 
        onlyOwner 
        pauseFunction
        returns(bool)
    {
        emit LogEmergency(_emergencyState);
        
        emergencyStop = _emergencyState;
        return true;
    }
    
    /**
      * @dev Sets the pause function. Is not stopped during emergency 
      *     to allow for state mutability to be changed during an emergency. 
      */
    function setPause(bool pauseState) 
        public
        onlyOwner
        returns(bool) 
    {
        emit LogPause(pauseState);
        
        return pause = pauseState;
    }
    
    /**
      * @dev used to update the dataStorages instance of the ccontract.
      * @param _newUserFactory : The address of the new contract. 
      */
    function registryUpdateUserFactory(address _newUserFactory)
        public
        onlyRegistry
        pauseFunction
    {
        uf = UserFactory(_newUserFactory);
        userFactoryAddress = _newUserFactory;
    }
    
    /**
      * @dev used to update the dataStorages instance of the ccontract.
      * @param _newCCFactory : The address of the new contract. 
      */
    function registryUpdateCCFactory(address _newCCFactory)
        public
        onlyRegistry
        pauseFunction
    {
        ccf = ContentCreatorFactory(_newCCFactory);
        ccFactoryAddress = _newCCFactory;
    }
    
    /**
      * @dev used to update the dataStorages instance of the ccontract.
      * @param _newMinter : The address of the new contract. 
      */
    function registryUpdateMinter(address _newMinter)
        public
        onlyRegistry
        pauseFunction
    {
        m = LoveMachine(_newMinter);
        minterAddress = _newMinter;
    }

    /**
      * @dev Creates a new userUser. 
      * @notice Only the user factory can call the creation of a new 
      *     user, so that the user has to be registed to the system 
      *     and to ensure that the user is an actual user and belongs to 
      *     the  UserFactory.
      * @param _user : The address of the creators wallet. 
      *     _userContract : The address of the users created user contract.
      *     _userName : The users chosen userName. 
      */
    function setNewUserData(address _user, address _userContract, string _userName)
        public 
        onlyUserFactory
        lockCheck(_userContract)
        stopInEmergency
        pauseFunction
    {
        lockUser(_userContract);
        
        allUsers[_userContract] = 0;
        allUserNames[_userContract] = _userName;
        userContractOwners[_userContract] = _user;
        usersAddresses.push(_userContract);
        usersNames.push(_userName);
        
        emit LogUserCreated(_user, _userContract, _userName);
        
        unlockUser(_userContract);
    }
    
    /** 
      * @dev Called by the users Factory by the users contract to delete the 
      *     users details and send all their views back to them as Ether. 
      * @notice This method implements the lock to ensure no other transactions
      *     are happening before the users Contract is deleted.
      * @param _user : The address of the users contract. To be removed 
      *         in future versions and the address of the users wallet from 
      *         storage.
      *     _userContract : The address of the users Contract.
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
        
        emit LogUserDeleted(_user, _userContract, _userName);
        
        return true;
    }
    
    /**
      * @dev This allows a new creator to be finalized and stored.
      * @notice The 'transaction fee' of a like (5 views) is taken 
      *     and added to the moderator fund, to help pay for the 
      *     moderation of content. 
      *     This method can only be called by the minter as the minter 
      *     needs to handle all payable methods values.
      * @param _userContract : The address of the users contract.
      *     _creatorContract : The address of the new Creators contract.
      */
    function setNewCreatorData(address _userContract, address _creatorContract) 
        public 
        //onlyMinter(1) 
        stopInEmergency 
        pauseFunction
        returns(bool)
    {
        // require(
        //     allUsers[_userContract] > 5, 
        //     "You need to be able to like your own stuff."
        // );
        allUsers[_userContract] -= 5;
        moderatorViews += 5;
        
        addToModeratorFund(_userContract, 5);
        
        allCreators[_creatorContract] = 0;
        creatorsContractOwners[_userContract] = _creatorContract;
        creatorsAddresses.push(_creatorContract);
        
        emit LogCreatorCreated(_userContract, _creatorContract);
        
        return true;
    }

    /**
      * @dev Removes the creators data and deletes all their information off 
      *     the system. It requires that the user has already cleared their 
      *     balance. This function deletes the user information and the 
      *     creator information. 
      * @param _userContract : The address of the user contract. 
      *     _creatorContract : The address of the creators contract. 
      * @return bool : After the function has been completed. 
      */
    function removeCreatorData(address _userContract, address _creatorContract) 
        public
        onlyCreatorFactory 
        beforeDeleteChecksCreator(_creatorContract) 
        beforeDeleteChecksUser(_userContract)
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

    /**
      * @dev Saves a users purchase of views after LoveMachine has been paid.
      * @param _userContract : The users contract address.
      *     _amount : The amount of views the user has already paid for in the 
      *         LoveMachine.
      * @return bool After it has changed the users balance.
      */
    function buyViewsSave(address _userContract, uint _amount)
        public
        //onlyMinter(_amount)
        lockCheck(_userContract)
        stopInEmergency
        pauseFunction
        returns(bool)
    {
        lockUser(_userContract);
        
        allUsers[_userContract] += _amount - 5;
        setTotalViewsDispenced(_userContract, _amount - 5);
        
        addToModeratorFund(_userContract, 5);
        
        emit LogBoughtViewsUser(_userContract, _amount - 5);
        
        unlockUser(_userContract);
        return true;
    }
    
    /**
      * @dev Saves a users sale of views before the LoveMachine pays the user the 
      *     value of the views in Ether.
      * @notice the assert is used as a prevention of underflow.
      * @param _userContract : The users contract address.
      *     _amount : The amount of views the user is selling. 
      * @return bool After it has changed the users balance.
      */
    function sellViewsSave(address _userContract, uint _amount)
        public
        //onlyMinter(_amount)
        lockCheck(_userContract)
        stopInEmergency
        pauseFunction
        returns(bool)
    {
        lockUser(_userContract);
        
        //assert(allUsers[_userContract] - _amount > 0);
        
        allUsers[_userContract] = allUsers[_userContract] - _amount;

        emit LogSoldViewsUser(_userContract, _amount);
        
        unlockUser(_userContract);
        return true;
    }
    
    /**
      * @dev Allows a creator to send views from their user contract (where they can 
      *     buy and sell views) to their creator contract.
      * @notice This function is nessasary as the seporation of user contracts from 
      *     creator contracts prevents some reentry attacks. 
      * @param _user : The users contracts account. 
      *     _amount: The amount of views they wish to transfer from their user contract 
      *         to their creator accouhnt. Amount is set in the LoveMachine, and 
      *         check here. 
      * @return bool After the function has compleated. 
      */
    function fromUserToCreator(address _user, uint _amount) 
        public
        onlyMinter(_amount)
        lockCheck(_user)
        stopInEmergency
        pauseFunction
        returns(bool)
    {
        lockUser(_user);
        
        require(isCreator(_user));
        require(allUsers[_user] > _amount);
        allUsers[_user] -= _amount;
        allCreators[getCreatorAddressFromUser(_user)] += _amount;
        
        unlockUser(_user);
        return true;
        
    }
    
    /**
      * @dev Allows the creator to send views from their creator account to their
      *     user contract account so they can sell them back for Ether, or so they 
      *     can view and consume contennt. 
      * @notice This function is nessasary for the compleate seporation of consurns 
      *     and to prevent various weaknesses and attack points through reeentry. 
      *     No views are being bought or sold and therefore there are no emits or 
      *     logs of any kind. 
      *     Function checks that the _amount is not more than the creator address has. 
      * @param _user : The users contract address.
      *     _amount : The amount of views they wish to transfer. 
      */
    function fromCreatorToUser(address _user, uint _amount)
        public
        onlyMinter(_amount)
        lockCheck(_user)
        stopInEmergency
        pauseFunction
        returns(bool)
    {
        lockUser(_user);
        
        require(isCreator(_user));
        require(allCreators[getCreatorAddressFromUser(_user)] > _amount);
        allCreators[getCreatorAddressFromUser(_user)] -= _amount;
        allUsers[_user] += _amount;
        
        unlockUser(_user);
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
        //onlyMinter(1)
        lockCheck(_user)
        stopInEmergency
        pauseFunction
    {
        lockUser(_user);
        
        if (viewUsedRecived == ViewsUsed.LIKED) {
            require(allUsers[_user] > 5);
            allUsers[_user] -= 5;
            allCreators[_contentOwner] += 5;
            
            emit LogBoughtViewsUser(_user, 5);
        }
        if (viewUsedRecived == ViewsUsed.LOVED) {
            require(allUsers[_user] > 15);
            allUsers[_user] -= 15;
            allCreators[_contentOwner] += 15;
            addToModeratorFund(_user, 15);
            
            emit LogBoughtViewsUser(_user, 15);
        }
        if (viewUsedRecived == ViewsUsed.FANLOVED) {
            require(allUsers[_user] > 25);
            allUsers[_user] -= 25;
            allCreators[_contentOwner] += 25;
            addToModeratorFund(_user, 25);
            
            emit LogBoughtViewsUser(_user, 25);
        }
        
        unlockUser(_user);
    }

    /**
      * @dev This function allows for the storage of newly created content. 
      * @notice This contract can only be called by the minter as the 
      *     minter handles a;; calles that have the potential for value 
      *     transfer.
      */
    function createContent(
        address _userContract,
        address _contentCreatorContract, 
        string _addressIPFS, 
        string _title, 
        string _description
        )
        public
        //onlyMinter(1)
        lockCheck(_userContract)
        stopInEmergency
        pauseFunction
    {
        lockUser(_userContract);
        //reducing balance of content creator
        //require(allCreators[_contentCreatorContract] > 5);
        allCreators[_contentCreatorContract] -= 5;
        moderatorViews += 5;
        
        addToModeratorFund(_contentCreatorContract, 5);
        
        creatorContent[_contentCreatorContract].push(Content({
            userOwner: _userContract,
            creator: _contentCreatorContract,
            contentLocationIPFS: _addressIPFS,
            title: _title,
            description: _description,
            views: 0
        }));
        allContent.push(Content({
            userOwner: _userContract,
            creator: _contentCreatorContract,
            contentLocationIPFS: _addressIPFS,
            title: _title,
            description: _description,
            views: 0
        })); 
        //for front end to have access to lates and all content
        //For the indervidual conent creators to be able to claim ownership of content
        // uint length = creatorContent[_contentCreatorContract].length;
        // creatorContent[_contentCreatorContract][length] = Content({
        //     userOwner: _userContract,
        //     creator: _contentCreatorContract,
        //     contentLocationIPFS: _addressIPFS,
        //     title: _title,
        //     description: _description,
        //     views: 0
        // });
        
        // Content[] storage temp = creatorContent[_contentCreatorContract];
        // temp.push(Content({
        //     userOwner: _userContract,
        //     creator: _contentCreatorContract,
        //     contentLocationIPFS: _addressIPFS,
        //     title: _title,
        //     description: _description,
        //     views: 0
        // }));

        emit LogContentCreated(allContent.length, _title, _contentCreatorContract);

        unlockUser(_userContract);
    }    

    function getContent(address _ccc)
        public
        view
        returns(
            address userContractAddress,
            address cCCAddress, 
            string addressIPFS, 
            string title, 
            string description,
            uint views
        )
    {
        uint latestContent = creatorContent[_ccc].length-1;

        userContractAddress = creatorContent[_ccc][latestContent].userOwner;
        cCCAddress = creatorContent[_ccc][latestContent].creator;
        addressIPFS = creatorContent[_ccc][latestContent].contentLocationIPFS;
        title = creatorContent[_ccc][latestContent].title;
        description = creatorContent[_ccc][latestContent].description;
        views = creatorContent[_ccc][latestContent].views;
    }

    /**
      * @dev This function allows the register to replace itself. 
      * @notice The function in the register that allows it to be 
      *     replaced can only be called by the owner. 
      * @param _newRegister : The address of the new register. 
      */
    function updateRegister(address _newRegister) 
        onlyRegistry
        pauseFunction
        public
    {
        registry = Register(_newRegister);
    } 
}