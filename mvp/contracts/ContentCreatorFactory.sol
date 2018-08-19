pragma solidity 0.4.24;

import "./ContentCreator.sol";

contract ContentCreatorFactory {
    address owner;
    mapping (address => address) contentCreators; //ccc address to user address
    
    constructor() public {
        owner = msg.sender;
    }
    
    function createContentCreator()
    public 
    payable
    returns(bool) {
        ContentCreator ccc = new ContentCreator(msg.sender);
        contentCreators[ccc] = msg.sender;
        
    }
}