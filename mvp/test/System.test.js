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

var DataStorage = artifacts.require("./DataStorage.sol");
var ContentCreatorFactory = artifacts.require("./ContentCreatorFactory.sol");
// var ContentCreator = artifacts.require("./ContentCreator.sol");
var LoveMachine = artifacts.require("./LoveMachine.sol");
var User = artifacts.require("./User.sol");
var UserFactory = artifacts.require("./UserFactory.sol");
var Register = artifacts.require("./Register.sol");

contract('System test', function(accounts) {
    const owner = accounts[0];
    const user = accounts[1];
    const contentCreator = accounts[2];
    const wallet = accounts[3];
    const userAccount3 = accounts[4];

    beforeEach(async function () {
        console.log("Owner address:\t\t" + owner);
        dataStorage = await DataStorage.new({from: owner});
        console.log("DataStorage address:\t" + dataStorage.address);
        contentCreatorFactory = await ContentCreatorFactory.new(dataStorage.address);
        console.log("CCFactory address:\t" + contentCreatorFactory.address);
        minter = await LoveMachine.new(dataStorage.address);
        console.log("Minter address:\t\t" + minter.address);
        userFactory = await UserFactory.new(
            dataStorage.address, 
            owner, 
            contentCreatorFactory.address
        );
        console.log("UserFactory address:\t" + userFactory.address);
        register = await Register.new(
            userFactory.address, 
            contentCreatorFactory.address,
            minter.address,
            owner,
            dataStorage.address
        );
        console.log("Register address:\t" + register.address);
        await dataStorage.setUpDataContracts(
            userFactory.address,
            contentCreatorFactory.address,
            minter.address,
            register.address,
            {from: owner}
        );
        let dataStoragePause = await dataStorage.pause();
        console.log("DataStorage pause:\t" + dataStoragePause + "\n");
    });

    /**
     * @notice Becuse of how interlinked my contract system is, it is almost impossible
      *     to test one contract without testing another. 
      *     To make it easier to see where each contract is being test and what 
      *     other contracts are being tested, I have included an index: 
      * 
      *         (R) : Register.sol is being tested
      *         (DS) : DataStorage.sol is being tested
      *         (M) : LoveMachine.sol is being tested
      *         (UF) : UserFactory.sol is being tested
      *         (CCF) : ContentCreatorFactory.sol is being tested
      *         (U) : User.sol is being tested
      *         (CC) : ContentCreator.sol is being tested
      * 
      *     The order of test indexes will aways be in this order. 
      */

    it("(DS)(UF)(U)Creator user", async () => {
        await userFactory.createUser("Test001", {from: user});
        
        let userContractAddress = await userFactory.userAddresses(0);

        let isUser = await dataStorage.isUser.call(userContractAddress);
        assert.equal(isUser, true, "The user is registed in the system");
    });

    it("(UF)(U)Get userName from user contract", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userContract = await User.at(userContractAddress);
        let userName = await userContract.userName.call();
        assert.equal(userName, "Test001", "userName is the userName entered");
    });

    it("(DS)(UF)(U)Get userName from dataStorage", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userNameInDataStorage = await dataStorage.getAUsersNameData.call(userContractAddress);
        assert.equal(userNameInDataStorage, "Test001", "userName is stored in dataStorage");
    });

    it("(UF)(U)Get user owner", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userContract = await User.at(userContractAddress);
        let userOwner = await userContract.owner.call();
        assert.equal(userOwner, user, "userName is stored in dataStorage");
    });

    it("(DS)(M)(UF)(U)User buys views", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userBalance = await dataStorage.allUsers.call(userContractAddress, {from: user});
        assert.equal(userBalance["c"][0], 0, "User balance is empty before buying views");

        let userContract = await User.at(userContractAddress);
        userContract.buyViews({from: user, value: ether(1)});

        let minterBalace = await minter.getBalance.call();
        assert.equal(minterBalace["c"][0], 10000, "Minter balance increases with purchase of views");

        let userBalanceAfter = await dataStorage.allUsers.call(userContractAddress, {from: user});
        assert.equal(userBalanceAfter["c"][0], 99995, "Users balance is 1Eth in views(99 995 views)(5 views flat fee)");
    });

    /**
      * @fails This functionality dose not work in the current version 
      */
    // it("(DS)(M)(UF)(U)User sells views", async () => {
    //     await userFactory.createUser("Test001", {from: user});
    //     let userContractAddress = await userFactory.userAddresses(0);

    //     let userBalance = await dataStorage.allUsers.call(userContractAddress, {from: user});
    //     assert.equal(userBalance["c"][0], 0, "User balance is empty before buying views");

    //     let userContract = await User.at(userContractAddress);
    //     userContract.buyViews({from: user, value: ether(1)});

    //     let minterBalace = await minter.getBalance.call();
    //     assert.equal(minterBalace["c"][0], 10000, "Minter balance increases with purchase of views");

    //     let userBalanceAfter = await dataStorage.allUsers.call(userContractAddress, {from: user});
    //     assert.equal(userBalanceAfter["c"][0], 99995, "Users balance is 1Eth in views(99 995 views)(5 views flat fee)");
    //     console.log("User balance after buying");
    //     console.log(userBalanceAfter["c"][0]);

    //     userContract.sellViews(1000, {from: user});
    //     let userBalanceAfterSelling = await dataStorage.allUsers.call(userContractAddress, {from: user});
    //     console.log("User balance after selling views");
    //     console.log(userBalanceAfterSelling["c"][0]);
    // });

    // it("(DS)(CCF)(CC)Create content creator", async () => {
    //     await userFactory.createUser("Test001", {from: user});
    //     let userContractAddress = await userFactory.userAddresses(0);

    //     let userContract = await User.at(userContractAddress);
    //     userContract.becomeContentCreator({from: user});

    // });

     // let balance = dataStorage.allUsers.call(userContractTransaction);
        // assert.equal(balance, 0, "Users balance is empty");
        // let user = await User(userContractTransaction);
        // let userOwner = await user.owner.call();
        // console.log("Usre owner: ");
        // console.log(userOwner);

        // let userName = await dataStorage.getAUsersName.call(userContractTransaction);
        // console.log("UserName: " + userName);
        // console.log(userName);
        //console.log("User contract userName: " + accountUserName);
        //assert.equal(userName, "Test001", 'User has been added to array of userNames');

        // let ownerOfUserContract = await 
        // assert.equal();
        //Test creating user, checking user in datastorage
        //assert.equal();

/**
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
    */
})