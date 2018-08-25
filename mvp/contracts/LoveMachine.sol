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

    //Ensures only the owner can call the function.
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //Ensures that the function will not work in emergency.
    modifier stopInEmergency() {
        require(!emergencyStop);
        _;
    }

    //Ensures the contract dose not work untill it is set up.
    modifier pauseModifier {
        require(!pause);
        _;
    }
    
    //Ensures set up only ever runs once. 
    modifier onlyCallOnce {
        require(!callOnce, "This contract has already been set up");
        _;
    }
    
    //Ensures only a user can call this function. 
    modifier onlyAUser {
        bool user = dataStorage.isUser(msg.sender);
        require(user);
        _;
    }
    
    //Ensures address is that of a users.
    modifier onlyAUserAddress(address _addressToCheck) {
        bool user = dataStorage.isUser(_addressToCheck);
        require(user, "Address is not a user");
        _;
    }
    
    //Ensures only a creator can call this function.
    modifier onlyACreator {
        bool creator = dataStorage.isCreator(msg.sender);
        require(creator);
        _;
    }
    
    //Ensures address is that of a creators. 
    modifier onlyACreatorAddress(address _addressToCheck) {
        bool creator = dataStorage.isCreator(_addressToCheck);
        require(creator);
        _;
    }

    //Ensures only the owner or register can call the function. 
    modifier ownerOrRegister {
        require(
            msg.sender == owner || msg.sender == dataStorage.registryAddress(),
            "Function can only be called by the owner or the register."
        );
        _;
    }

    /**
      *@dev Called by the DataStorage to create an instance of this contract.
      */
    constructor() 
        public
    {

    }
    
    /**
      * @dev Allows for the set up of the LoveMachine contract. 
      *     This function is required as a contract dose not have
      *     an address untill the constructor has finished executing, 
      *     so the constructor functionality had to be seporated out 
      *     to allow for the various addresses to be created and passed in. 
      */
    function constructorFunction(address _dataStorage) 
        public
        onlyCallOnce
    {
        dataStorage = DataStorage(_dataStorage);
        owner =  dataStorage.owner();
        callOnce = true;
    }

    /**
      * @dev Allows only user contracts to buy views. 
      * @return bool : If the proccess was successful.
      */
    function buyViews()
        public
        payable
        onlyAUser
        returns(bool)
    {
        uint amountPossible = msg.value / 10**13;
        bool updated = dataStorage.buyViewsSave(msg.sender, amountPossible);
        return updated;
    }
    
    /**
      * @dev Allows only user contracts to sell views.
      * @return bool : If the transfer was successful.
      */
    function sellViews(uint _amount)
        public
        onlyAUser
        returns(bool)
    {
        uint weiValue = _amount * 10**13;
        bool viewsSold = dataStorage.sellViewsSave(msg.sender, _amount);
        msg.sender.transfer(_amount);
        
        return viewsSold;
    }
    
    /**
      * @dev Allows a user to transfer views from their user account 
      *     to their creator account.
      * @notice This is needed as a creator dose not have the functionality
      *     of a user. 
      * @param _amount : The amount of views they wish to transfer.
      * @return bool : If the transaction was successful.
      */
    function TransferViewsToCreatorAccount(uint _amount)
        public
        onlyAUser
        returns(bool)
    {
        dataStorage.fromUserToCreator(msg.sender, _amount);
        
        return true;
    }

    /**
      * @dev Allows a creator to send views back to their user acount. 
      * @notice This functionality is needed if the creator wants 
      *     to sell their views. 
      */
    function TransferViewsToUserAccount(uint _amount)
        public
        onlyAUser
        returns(bool)
    {
        dataStorage.fromCreatorToUser(msg.sender, _amount);
        
        return true;
    }
    
    /**
      * @dev Allows a user to like content. 
      * @param _contentCreator : The content the user is liking's creator. 
      *     _userConsumer : The user who is liking the content. 
      */
    function liked(address _contentCreator, address _userConsumer)
        public
        onlyAUser
    {
        dataStorage.storingLikes(DataStorage.ViewsUsed.LIKED, _contentCreator, _userConsumer);
    }

    /**
      * @dev Allows a user to love content. 
      * @param _contentCreator : The content the user is loving's creator. 
      *     _userConsumer : The user who is loving the content. 
      */
    function loved(address _contentCreator, address _userConsumer)
        public
        onlyAUser
    {
        dataStorage.storingLikes(DataStorage.ViewsUsed.LOVED, _contentCreator, _userConsumer);
    }
    
    /**
      * @dev Allows a user to love content. 
      * @param _contentCreator : The content the user is fan loving's creator. 
      *     _userConsumer : The user who is fan loving the content. 
      */
    function fanLoved(address _contentCreator, address _userConsumer)
        public
        onlyAUser
    {
        dataStorage.storingLikes(DataStorage.ViewsUsed.FANLOVED, _contentCreator, _userConsumer);
    }
    
    /**
      * @dev Allows a creator to create content. 
      * @param _addressIPFS : The address of the content in IPFS. 
      *     _title : The title of the content. 
      *     _description : The 'About' of the content. 
      * @return bool : If the transaction was successful. 
      */
    function createContentMinter(
        string _addressIPFS, 
        string _title, 
        string _description
        ) 
        public
        payable
        onlyACreator
        returns(bool)
    {
        dataStorage.createContent(msg.sender, _addressIPFS, _title, _description);
        return true; 
    }

    /**
      * @dev Allows the register or owner to replace the minter by kiling it. 
      * @notice All the other kill's for contract factories send their 
      *     value to this contract, but when this contract is destroyed it 
      *     sends its value to the owner. 
      */
    function kill() 
        public 
        ownerOrRegister 
    {
        selfdestruct(owner);
    }
}