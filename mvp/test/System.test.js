const {
    ether
} = require('./helpers/ether');
const {
    expectThrow
} = require('./helpers/expectThrow');
const {
    EVMRevert
} = require('./helpers/EVMRevert');
const { 
    assertRevert 
} = require('./helpers/assertRevert');

// var UserFactory = artifacts.require("./UserFactory.sol");
var DataStorage = artifacts.require("./DataStorage.sol");
var ContentCreatorFactory = artifacts.require("./ContentCreatorFactory.sol");
// var ContentCreator = artifacts.require("./ContentCreator.sol");
var LoveMachine = artifacts.require("./LoveMachine.sol");
// var User = artifacts.require("./User.sol");
var UserFactory = artifacts.require("./UserFactory.sol");
var Register = artifacts.require("./Register.sol");

contract('UserFactory', function(accounts) {
    const owner = accounts[0]
    const user = accounts[1];
    const contentCreator = accounts[2];
    const wallet = accounts[3];
    const userAccount3 = accounts[4];

    it("Freash set up of contract system", async () => {
        const dataStorage = await DataStorage.new({from: owner});
        console.log("DataStorage address: " + dataStorage.address);
        const contentCreatorFactory = await ContentCreatorFactory.new(dataStorage.address);
        const minter = await LoveMachine.new(dataStorage.address);
        const userFactory = await UserFactory.new(
            dataStorage.address, 
            owner, 
            contentCreatorFactory.address
        );
        const register = await Register(
            userFactory.address, 
            contentCreatorFactory.address,
            minter.address,
            owner.address,
            dataStorage.address
        );
        
        await dataStorage.setUpDataContracts(
            userFactory.address,
            contentCreatorFactory.address,
            minter.address,
            {from: owner}
        );
    
    });
})