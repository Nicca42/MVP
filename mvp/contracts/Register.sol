pragma solidity 0.4.24;
contract Register {
    address backendContract;
    address[] previousBackends;
    address owner;
    
    constructor() public {
        owner == msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    event LogNewContract(address newContract, address oldContract);
    
    function changeBackend(address newBackend) public
    onlyOwner()
    returns(bool) {
        if(newBackend != backendContract) {
            emit LogNewContract(newBackend, backendContract);
            previousBackends.push(backendContract);
            backendContract = newBackend;
            return true;
        }
        return false;
    }
}
