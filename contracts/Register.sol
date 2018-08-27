pragma solidity 0.4.24;


import "./DataStorage.sol";
import "./UserFactory.sol";
import "./ContentCreatorFactory.sol";
import "./LoveMachine.sol";

contract Register {
    DataStorage dataStorage;
    UserFactory userFactory;
    ContentCreatorFactory ccFactory;
    LoveMachine minter;

    address public backendUserFactory;
    address[] previousUserFactories;
    address public backendContentCreatorFactory;
    address[] previousContentCreatorFactories;
    address public backendMinter;
    address[] previousMinters;
    address public owner;

    bool public emergencyStop = false;
    bool public pause = true;
    bool callOnce = false;

    event LogNewUserFactory(address newContract, address oldContract);
    event LogNewContract(
        address _newContentCreatorFactory, 
        address backendContentCreatorFactory
    );

    //Restricts functions use to when there is an emergency 
    modifier onlyInEmergency {
        require(emergencyStop);
        _;
    }
    
    //Restricts functions to only when there is not an emergency.
    modifier stopInEmergency {
        require(!emergencyStop);
        _;
    }
    
    //pauses all functionality untill contract set up is compleate.
    modifier pauseFunction {
        require(!pause);
        require(!dataStorage.pause());
        _;
    }
    
    //This allows the set up to only run once.
    modifier onlyCallOnce {
        require(!callOnce, "This contract has already been set up");
        _;
    }

    //Restricts the function to only be called by the owner.
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //The empty constructor function allowing for the address to be created.
    constructor(
        address _backendUserFactory, 
        address _backendContentCreatorFactory, 
        address _backendMinter, 
        address _owner,
        address _dataStorage
        ) 
        public 
    {
        owner = _owner;
        dataStorage = DataStorage(_dataStorage);
        backendUserFactory = _backendUserFactory;
        userFactory = UserFactory(_backendUserFactory);
        backendContentCreatorFactory = _backendContentCreatorFactory;
        ccFactory = ContentCreatorFactory(_backendContentCreatorFactory);
        backendMinter = _backendMinter;
        minter = LoveMachine(_backendMinter);
        
        pause = false;
    }
    
    /**
      * @dev Allows the owner to upgrade the UserFactory contract by entering the new address
      *     into this method.
      * @param _newUserFactory : The address of the new UserFactory address.
      * @return bool Letting the owner know if it successfully updated the UserFactory. 
      */
    function changeUserFactory(address _newUserFactory) 
        public
        //onlyOwner()
        stopInEmergency
        pauseFunction
        returns(bool) 
    {
        if(_newUserFactory != backendUserFactory) {
            
            emit LogNewContract(_newUserFactory, backendUserFactory);
            
            previousUserFactories.push(backendUserFactory);
            // userFactory.kill(backendUserFactory);
            backendUserFactory = _newUserFactory;
            userFactory = UserFactory(backendUserFactory);
            // dataStorage.registryUpdateUserFactory(backendUserFactory);
            return true;
        }
        return false;
    }
    
    /**
      * @return address The address of the current userFactory.
      */
    function getUserFactory()
        public
        view
        returns(address)
    {
        return backendUserFactory;
    }

    /**
      * @dev Allows the owner to upgrade the ContentCreatorFactory contract by entering 
      *     the new address into this method.
      * @param _newContentCreatorFactory : The address of the new ContentCreatorFactory 
      *         address.
      * @return bool Letting the owner know if it successfully updated the 
      *     ContentCreatorFactory. 
      */
    function changeContentCreatorFactory(address _newContentCreatorFactory) 
        public
        // onlyOwner()
        stopInEmergency
        pauseFunction
        returns(bool) 
    {
        if(_newContentCreatorFactory != backendContentCreatorFactory) {
            
            emit LogNewContract(
                _newContentCreatorFactory, 
                backendContentCreatorFactory
            );
            
            previousContentCreatorFactories.push(backendUserFactory);
            // ccFactory.kill(backendMinter);
            backendContentCreatorFactory = _newContentCreatorFactory;
            ccFactory = ContentCreatorFactory(backendContentCreatorFactory);
            // dataStorage.registryUpdateCCFactory(backendContentCreatorFactory);
            return true;
        }
        return false;
    }
    
    /**
      * @return address The address of the current contentCreatorFactory.
      */
    function getContentCreatorFactory()
        public
        view
        returns(address)
    {
        return backendContentCreatorFactory;
    }

    /**
      * @dev Allows the owner to upgrade the Minter contract by entering  the 
      *     new address into this method.
      * @param _newMinter : The address of the new Minter 
      *         address.
      * @return bool Letting the owner know if it successfully updated the 
      *     Minter. 
      */
    function changeMinter(address _newMinter) 
        public
        // onlyOwner()
        stopInEmergency
        pauseFunction
        returns(bool) 
    {
        if(_newMinter != backendMinter) {
            
            emit LogNewContract(_newMinter, backendMinter);
            
            previousMinters.push(backendMinter);
            // ccFactory.kill(_newMinter);
            backendMinter = _newMinter;
            minter = LoveMachine(backendMinter);
            // dataStorage.registryUpdateMinter(backendMinter);
            return true;
        }
        return false;
    }
    
    /**
      * @return address The address of the current Minter.
      */
    function getMinter()
        public
        view
        returns(address)
    {
        return backendMinter;
    }
    
    /**
      * @dev Only callable by the onwer, this allows the owner to
      *     upgrade the register itself. Calling this function may require 
      *     some set up to be changed in the fornt end, for example the 
      *     front ends pointer to the current Register. 
      * @param _newRegister : The address of the replacing register. 
      */
    function kill(address _newRegister) 
        public
        onlyOwner
        pauseFunction
    {
        dataStorage.updateRegister(_newRegister);
        selfdestruct(owner);
    }
}
