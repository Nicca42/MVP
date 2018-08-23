pragma solidity 0.4.24;

import "./1DataStorage.sol";
import "./2Register.sol";
import "./User.sol";
import "./ContentCreator.sol";

contract LoveMachine {
    DataStorage dataStorage;
    address owner;
    
    enum viewsUsed {LIKED, LOVED, FANLOVED}

    bool emergencyStop = false;
    bool pause = false;
    bool callOnce = false;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier stopInEmergency() {
        require(!emergencyStop);
        _;
    }

    modifier pauseModifier {
        require(!pause);
        _;
    }
    
    modifier onlyCallOnce {
        require(!callOnce, "This contract has already been set up");
        _;
    }
    
    modifier onlyAUser {
        bool user = dataStorage.isUser(msg.sender);
        require(user);
        _;
    }
    
    modifier onlyACreator {
        bool creator = dataStorage.isCreator(msg.sender);
        require(creator);
        _;
    }

    /**
        so that users cannot withdraw from their creator and user
        account simultaniously 
     */
    modifier lockUser(address _user) {
        User u = User(_user);
        bool lock = u.getLock();
        require(!lock);
        if(dataStorage.isCreator(_user)) {
            ContentCreator cc = ContentCreator(dataStorage.getCreatorAddressFromUser(_user));
            bool ccLock = cc.getLock();
            require(!ccLock);
        }
        _;
    }

    modifier ownerOrRegister {
        require(msg.sender == owner || msg.sender == dataStorage.registryAddress());
        _;
    }

    constructor() 
        public
        stopInEmergency
    {

    }
    
    function constructorFunction(address _dataStorage, address _owner) 
        public
        onlyCallOnce
    {
        dataStorage = DataStorage(_dataStorage);
        owner = _owner;
        callOnce = true;
    }

    function buyViews(address _userContract, uint _amount) 
        public 
        payable
        lockUser(_userContract)
        stopInEmergency
        pauseModifier
        returns(bool)
    {
        uint amountPossible = msg.value / 10**13;
        require(amountPossible > 0, "Amount entered not possible");
        dataStorage.boughtViews(_userContract, amountPossible);
        dataStorage.setTotalViewsDispenced(_userContract, _amount);
    }

     //TODO: !! buyViewsFor(Uint _amount, address _reciver)
                //lockUser
    function byViewsFor(address _reciver, uint _amount) 
        public 
        payable 
        lockUser(msg.sender)
        stopInEmergency
        pauseModifier
    {
        
    }
   
    //TODO: !! sellViews(uint _amount)
                //lockUser

    //TODO: !! giveViewsTo(uint _amount, address _reciver)
                //lockUser

    //TODO: !! getContentViews() => puts views into userContract so they can be withdrawn. 
                //can only be called from contentCreatorContractg 
                //lockUser
                //onlyCreator

    function liked(address _contentCreator, address _userConsumer)
        public
        onlyAUser
    {
        dataStorage.storingLikes(DataStorage.ViewsUsed.LIKED, _contentCreator, _userConsumer);
    }

    function loved(address _contentCreator, address _userConsumer)
        public
        onlyAUser
    {
        dataStorage.storingLikes(DataStorage.ViewsUsed.LOVED, _contentCreator, _userConsumer);
    }
    
    function fanLoved(address _contentCreator, address _userConsumer)
        public
        onlyAUser
    {
        dataStorage.storingLikes(DataStorage.ViewsUsed.FANLOVED, _contentCreator, _userConsumer);
    }
    
    function createContentCreatorMinter(address _userAccount)
        public
        payable
        lockUser(_userAccount)
        onlyAUser
        returns(bool)
    {
        address ccc = new ContentCreator(msg.sender, this);
        dataStorage.setNewCreatorData(_userAccount, ccc);
    }
    
    function createContentMinter(
        address _contentCreatorContract, 
        uint _addressIPFS, 
        string _title, 
        string _description
        ) 
        public
        payable
        onlyACreator
        lockUser(msg.sender)
        returns(bool)
    {
        dataStorage.createContent(_contentCreatorContract, _addressIPFS, _title, _description);
    }

    function kill() 
        public 
        ownerOrRegister 
    {
        selfdestruct(owner);
    }
}