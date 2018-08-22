pragma solidity 0.4.24;

import "./1DataStorage.sol";
import "./2Register.sol";
import "./User.sol";
import "./ContentCreator.sol";

contract LoveMachine {
    DataStorage dataStorage;
    User u;
    address owner;

    bool emergencyStop = false;
    bool pause = false;

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

    //TODO: modifer so that only a content creator can use.

    modifier ownerOrRegister {
        require(msg.sender == owner || msg.sender == dataStorage.registryAddress());
        _;
    }

    constructor(address _dataStorage, address _owner) 
        public
        stopInEmergency
    {
        dataStorage = DataStorage(_dataStorage);
        owner = _owner;
    }

    function buyViews(address _userContract, uint _amount) 
        public 
        payable
        lockUser(_userContract)
        stopInEmergency
        pauseModifier
    {
        uint amountPossible = msg.value / 10**13;
        dataStorage.boughtViews(_userContract, amountPossible);
        dataStorage.setTotalViewsDispenced(_userContract, _amount);
    }

    //TODO: !! buyViewsFor(Uint _amount, address _reciver)
                //lockUser

    //TODO: !! sellViews(uint _amount)
                //lockUser

    //TODO: !! giveViewsTo(uint _amount, address _reciver)
                //lockUser

    //TODO: !! getContentViews() => puts views into userContract so they can be withdrawn. 
                //can only be called from contentCreatorContractg 
                //lockUser
                //onlyCreator

    //TODO: !! finalizeConent(address _contentCreator, string _title, string _desc, string IPFSAddres)
            /**
                    data to add to finalize content method
                function createContent(
                    address _contentCreatorContract, 
                    uint _addressIPFS, 
                    string _title, 
                    string _description
                    )
                    public
                    onlyMinter(1)
                    {
                        founction
                    }
             */

    //TODO: !! liked(address _contentCreator, _userConsumer)

    //TODO: !! loved(address _contentCreator, _userConsumer)

    //TODO: !! fanLoved(address _contentCreator, _userConsumer)

    function kill() 
        public 
        ownerOrRegister 
    {
        selfdestruct(owner);
    }
}