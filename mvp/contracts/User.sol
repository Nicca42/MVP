pragma solidity 0.4.24;

import "./UserFactory.sol";

contract User {
    UserFactory uf;
    address public owner;
    string public userName;
    uint public joinedDate;
    uint daoKey;
    
    constructor(address _user, uint _joinedDate, string _userName, address _userFactory) 
    public {
        owner = _user;
        joinedDate = _joinedDate;
        userName = _userName;
        uf = UserFactory(_userFactory);
    }
    
    modifier isUser {
        require(msg.sender == owner);
        _;
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
        // ContentCreatorFactory.createNewCC(this);
        return true;
    }
}