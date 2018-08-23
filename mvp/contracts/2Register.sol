pragma solidity 0.4.24;

import "./1DataStorage.sol";
import "./UserFactory.sol";
import "./3ContentCreatorFactory.sol";
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
    event LogNewContract(
        address _newContentCreatorFactory, 
        address backendContentCreatorFactory
    );

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
        require(!dataStorage.pause());
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
        address _owner,
        address _dataStorage
        ) 
        public 
    {
        owner == _owner;
        dataStorage = DataStorage(_dataStorage);
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
            userFactory.kill(backendMinter);
            backendUserFactory = _newUserFactory;
            userFactory = UserFactory(backendUserFactory);
            dataStorage.registryUpdateUserFactory(backendUserFactory);
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
        if(_newContentCreatorFactory != backendContentCreatorFactory) {
            emit LogNewContract(
                _newContentCreatorFactory, 
                backendContentCreatorFactory
            );
            previousContentCreatorFactories.push(backendUserFactory);
            ccFactory.kill(backendMinter);
            backendContentCreatorFactory = _newContentCreatorFactory;
            ccFactory = ContentCreatorFactory(backendContentCreatorFactory);
            dataStorage.registryUpdateCCFactory(backendContentCreatorFactory);
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
            ccFactory.kill(_newMinter);
            backendMinter = _newMinter;
            minter = LoveMachine(backendMinter);
            dataStorage.registryUpdateMinter(backendMinter);
            return true;
        }
        return false;
    }
    //TODO: create function to disable this contract and to create 
            //a new one in the data storage
    function kill(address _newRegister) {
        dataStorage.updateRegister(_newRegister);
        selfdestruct(owner);
    }
}
