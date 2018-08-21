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

    address backendUserFactory;
    address[] previousUserFactories;
    address backendContentCreatorFactory;
    address[] previousContentCreatorFactories;
    address backendMinter;
    address[] previousMinters;
    address owner;

    bool public emergencyStop = false;
    bool public pause = false;

    event LogNewUserFactory(address newContract, address oldContract);

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
        require(!dataStorage.getPause());
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor(
        address _backendUserFactory, 
        address _backendContentCreatorFactory, 
        address _backendMinter, 
        address _owner
        address _dataStorage
        ) 
        public 
    {
        owner == _owner;
        ds = DataStorage(_dataStorage);
        backendUserFactory = _backendUserFactory;
        userFactory = UserFactory(_backendUserFactory);
        backendContentCreatorFactory = _backendContentCreatorFactory;
        ccFactory = ContentCreatorFactory(_backendContentCreatorFactory);
        backendMinter = _backendMinter;
        minter = LoveMachine(_backendMinter);
    }
    
    function changeUserFactory(address _newUserFactory) 
        public
        onlyOwner()
        stopInEmergency
        pauseFunction
        returns(bool) 
    {
        if(_newUserFactory != backendUserFactory) {
            emit LogNewContract(_newUserFactory, backendUserFactory);
            previousUserFactories.push(backendUserFactory);
            userFactory.kill(_backendMinter);
            backendUserFactory = _newUserFactory;
            userFactory = UserFactory(backendUserFactory);
            return true;
        }
        return false;
    }

    function changeContentCreatorFactory(address _newContentCreatorFactory) 
        public
        onlyOwner()
        stopInEmergency
        pauseFunction
        returns(bool) 
    {
        if(_newContentCreatorFactory != _backendContentCreatorFactory) {
            emit LogNewContract(_newContentCreatorFactory, backendContentCreatorFactory);
            previousContentCreatorFactories.push(backendUserFactory);
            contentCreatorFactory.kill(_backendMinter);
            backendContentCreatorFactory = _newContentCreatorFactory;
            contentCreatorFactory = ContentCreatorFactory(backendContentCreatorFactory);
            return true;
        }
        return false;
    }

    function changeMinter(address _newMinter) 
        public
        onlyOwner()
        stopInEmergency
        pauseFunction
        returns(bool) 
    {
        if(_newMinter != backendMinter) {
            emit LogNewContract(_newMinter, backendMinter);
            previousMinters.push(backendMinter);
            contentCreatorFactory.kill(_backendMinter);
            backendMinter = _newMinter;
            minter = LoveMachine(backendMinter);
            return true;
        }
        return false;
    }
    //TODO: create function to disable this contract and to create 
            //a new one in the data storage
}
