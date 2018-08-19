pragma solidity 0.4.24;

import "./UserFactory.sol";

contract User {
    UserFactory uf;
    address public owner;
    string public userName;
    uint public joinedDate;
    uint daoKey;
    
    constructor(address _user, uint _joinedDate, string _userName, UserFactory _uf) 
    public {
        owner = _user;
        joinedDate = _joinedDate;
        userName = _userName;
        uf = _uf;
    }
    
    modifier isUser {
        require(msg.sender == owner);
        _;
    }
    
    function deleteUser() 
    isUser
    returns(bool) {
        require(uf.deleteUserFinal(this));
        selfdestruct(owner);
        return true;
    }
}