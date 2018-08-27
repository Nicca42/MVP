pragma solidity ^0.4.17;

contract SimpleStorage {
    uint myVariable;

    constructor(uint _startingValue) public{
        myVariable = _startingValue;
    }

    function set(uint _x) public {
        myVariable = _x;
    }

    function get() public view returns (uint) {
        return myVariable;
    }
}