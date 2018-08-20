pragma solidity 0.4.24;

import "./ContentCreator.sol";

contract ContentCreatorFactory {
    address owner;
    DataStorage ds;
    
    constructor(address _dataStorage) 
        public 
    {
        owner = msg.sender;
        ds = DataStorage(_dataStorage);
    }
    
    function createContentCreator()
        public 
        payable
        returns(bool) 
    {
        address ccc = new ContentCreator(msg.sender);
        dataStorage.setNewCreatorData(msg.sender, ccc); 
        
    }
}