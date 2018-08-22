pragma solidity 0.4.24;

import "./UserFactory.sol";
import "./ContentCreatorFactory.sol";

contract User {
    UserFactory uf;
    ContentCreatorFactory ccFactory;
    address public owner;
    string public userName;
    uint public joinedDate;
    uint daoKey;
    
    modifier isUser {
        require(msg.sender == owner);
        _;
    }
    
    constructor(address _user, uint _joinedDate, string _userName, address _userFactory, address _ccFactory) 
    public {
        owner = _user;
        joinedDate = _joinedDate;
        userName = _userName;
        uf = UserFactory(_userFactory);
        ccFactory = ContentCreatorFactory(_ccFactory);
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
        
        return true;
    }
}