pragma solidity 0.4.24;

import "./UserFactory.sol";
import "./3ContentCreatorFactory.sol";
import "./LoveMachine.sol";

contract User {
    UserFactory uf;
    address public owner;
    string public userName;
    uint public joinedDate;

    bool lock;
    
    modifier isUser {
        require(msg.sender == owner);
        _;
    }
    
    modifier checkLock {
        require(!lock);
        _;
    }
    
    modifier onlyMinter {
        require(msg.sender == uf.getMinter());
        _;
    }
    
    constructor(
        address _userWallet,
        string _userName, 
        address _userFactory
        ) 
        public 
    {
        owner = _userWallet;
        joinedDate = now;
        userName = _userName;
        uf = UserFactory(_userFactory);
    }
    
    function getLock()
        public
        view
        returns(bool)
    {
        return(lock);
    }
    
    function deleteUser() public
    isUser
    returns(bool) {
        require(uf.deleteUserFinal(this));
        selfdestruct(owner);
        return true;
    }

    function becomeContentCreator() public
    payable
    isUser
    returns(bool) {
        ContentCreatorFactory ccFactory = ContentCreatorFactory(uf.getContentCreatorFactory());
        return ccFactory.createContentCreator();
    }
}