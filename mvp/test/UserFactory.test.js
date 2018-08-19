const {
    ether
} = require('./helpers/ether');
const {
    expectThrow
} = require('./helpers/expectThrow');
const {
    EVMRevert
} = require('./helpers/EVMRevert');
var UserFactory = artifacts.require("./UserFactory.sol");

contract('UserFactory', function(accounts) {
    const factory = accounts[0]
    const userAccount1 = accounts[1];
    const userAccount2 = accounts[2];

    it("create a user account", async () => {
        const factory = await UserFactory.deployed();
    
        //creates the new user, with the userName of "test1";
        await factory.createUser("test1", {from: userAccount1});
    
        //tests that user has been added to array of userNames
        let accountUserName = await factory.usersNames.call(0);
        assert.equal(accountUserName, "test1", 'user has been added to array of userNames');

        //gets the address of the new depolyed user
        let userAccountContractAddress = await factory.usersAddresses.call(0);

        //tests that the contract address has been added to the allUsers mapping
        let accountCreated = await factory.allUsers.call(userAccountContractAddress);
        assert.equal(accountCreated, "test1", 'contract address has been added to the allUsers mapping');

        //test that if you try add a new user with the same username will fail.
        await expectThrow(factory.createUser("test1", {from: userAccount1}), EVMRevert);
    });
})