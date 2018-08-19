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

var UserFactory = artifacts.require("./UserFactory.sol");
var User = artifacts.require("./User.sol");

contract('UserFactory', function(accounts) {
    const owner = accounts[0]
    const userAccount1 = accounts[1];
    const userAccount2 = accounts[2];
    const userAccount3 = accounts[3];

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

    it("testing created user account", async () => {
        const factory = await UserFactory.new();
    
        //creates the new user, with the userName of "test2";
        await factory.createUser("test2", {from: userAccount2});
    
        //tests that user has been added to array of userNames
        let accountUserName = await factory.usersNames.call(0);
        assert.equal(accountUserName, "test2", 'user has been added to array of userNames');

        //gets the address of the new depolyed user
        let userAccountContractAddress = await factory.usersAddresses.call(0);

        const user = await User.at(userAccountContractAddress);

        //tests user name
        let userName = await user.userName();
        assert.equal(userName, "test2", "users name is test2");

        //tests user create date
        let dateCreated = await user.joinedDate();
        assert.notEqual(dateCreated, 0, "user joinDate is not empty");

        //tests who the owner of the contract is
        let owner = await user.owner();
        assert(owner, userAccount2, "user should be userAccount2");
    });

    it("testing delete user account", async () => {
        const factory = await UserFactory.new();
    
        //creates the new user, with the userName of "test2";
        await factory.createUser("test3", {from: userAccount2});
    
        //tests that user has been added to array of userNames
        let accountUserName = await factory.usersNames.call(0);
        assert.equal(accountUserName, "test3", 'user has been added to array of userNames');

        //gets the address of the new depolyed user
        let userAccountContractAddress = await factory.usersAddresses.call(0);

        const user = await User.at(userAccountContractAddress);

        //tests user name
        let userName = await user.userName();
        assert.equal(userName, "test3", "users name is test3");

        //test user can delete account
        let boolDelete = await user.deleteUser({from: userAccount2});
        assert.notEqual(boolDelete, false, "users account is deleted");

    });

    it("testing cannot delete user account from other account", async () => {
        const factory = await UserFactory.new();
    
        //creates the new user, with the userName of "test2";
        await factory.createUser("test3", {from: userAccount2});
    
        //tests that user has been added to array of userNames
        let accountUserName = await factory.usersNames.call(0);
        assert.equal(accountUserName, "test3", 'user has been added to array of userNames');

        //gets the address of the new depolyed user
        let userAccountContractAddress = await factory.usersAddresses.call(0);

        const user = await User.at(userAccountContractAddress);

        //tests user name
        let userName = await user.userName();
        assert.equal(userName, "test3", "users name is test3");

        //testing no one other than the user Contract can delete the user Contract
        await assertRevert(user.deleteUser({from: userAccount3}));
    });
})