pragma solidity 0.4.24;

import "./DataStorage.sol";

contract LoveMachine {
    DataStorage dataStorage;
    address owner;

    bool emergencyStop = false;
    bool pause = true;

    /**
    Deployed dc;
    
    function Existing(address _t) public {
        dc = Deployed(_t);
    }
     */

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier neverInEmergency() {
        require(!emergencyStop);
        _;
    }

    modifier pause {
        require(!pause);
        _;
    }

    constructor(address _dataStorage) 
        public
        neverInEmergency
    {
        dataStorage = DataStorage(_dataStorage);
        owner = msg.sender;
    }

    function buyViews(address _userContract, uint _amount) 
        public 
        payable
        neverInEmergency
    {
        uint amountPossible = msg.value / 10**13;
        dataStorage.boughtViews(_userContract, amountPossible);
        dataStorage.setTotalViewsDispenced(_amount);
    }
}