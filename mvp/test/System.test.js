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

    it("Creator user", async () => {
        //Test creating user, checking user in datastorage
    });

    it("Create Content creator", async () => {
        //Create content creator
        //test change in dataStorage
        //test change in ccFacotry?
    });

    it("Create content", async () => {
        //test creator can create content
        //test data change in balance (like)
        //test data change of storage 
    });

    it("User buys views", async () => {
        //test depositing eth. 
        //test user ballence changed in datastorage
    });

    it("User likes content", async () => {
        //Test user liking content 
        //test balance changes 
    });

    it("User loves content", async () => {
        //test user loving item 
        //test balance changes
    });

    it("User fan loves content", async () => {
        //test user fan loving content
        //test balance changes
    });

    it("User sells views", async () => {
        //User sells some views for Ether
    });

    it("Content creator transfers views to user account", async () => {
        //test transfer function
        //test change in dataStorage
        //test balances of both contacts.
        //test withdrawing more views than balance
    });

    it("test user transfering views to creator account", async () => {
        //test transfer function
        //test change in dataStorage
        //test balances of both contacts.
    });

    it("test dataStorage returns correct user - Content creator linking", async () => {
        //test user contract linked with correct content creator account
    });

    it("Test content creator kill method", async () => {
        //test the contract moves balance
        //test the contract deletes all instances of the creator
        //test the content is no longer findable. IPFS
    });

    it("Test user kills account", async () => {
        //test the users account is emptied first 
        //test all the user data has been deleted
    });

    //reset the contract system 

    //testing the indervidual calls of each contracts, 
    //testing their views and their indervidual getters and setters 

    //DO NOT DO UNNESSASARY FUNCTIONS STICK TO THE IMPORTANT ONES
    //and the majority of the small ones will be tested indirectly by 
    //other tests that they effect the results of.
    it("Test UserFactory create user getters and setters", async () => {
        //test userfactory creator user all getters and setters. 
    });

    it("Test UserFactory ", async () => {
        //
    });
    //etc. . .

    //reset the system variables 

    //test the register
    //repeat this step for all contracts being tracked by the register
    it("Test updating UserFactory", async () => {
        //test data storage getting from current UserFactory
        //test kill
        //test old user factory is deleted 
        //test data storage having the new one
        //test data storage being able to use new one. 
    });

    it("", async () => {
        //
    });
})