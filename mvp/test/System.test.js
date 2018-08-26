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
var ContentCreator = artifacts.require("./ContentCreator.sol");
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

    /**
      * @notice Becuse of how interlinked my contract system is, it is almost impossible
      *     to test one contract without testing another. 
      *     To make it easier to see where each contract is being test and what 
      *     other contracts are being tested, I have included an index: 
      *         
      *         Index   | Contract                  | Total Tests   
      *         (R)     : Register.sol              : 
      *         (DS)    : DataStorage.sol           : 6
      *         (M)     : LoveMachine.sol           : 4
      *         (UF)    : UserFactory.sol           : 7
      *         (CCF)   : ContentCreatorFactory.sol : 2
      *         (U)     : User.sol                  : 7
      *         (CC)    : ContentCreator.sol        : 2
      * 
      *     The order of test indexes will aways be in this order. 
      *         (DS)            (UF)    (U)
                                (UF)    (U)
                (DS)            (UF)    (U)
                                (UF)    (U)
                (DS)    (M)     (UF)    (U)
                (DS)    (M)     (UF)    (U)
                (DS)    (M)                     (CCF)   (CC)
                (DS)    (M)     (UF)    (U)     (CCF)   (CC)
      */

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

    /**
      * 
      */
    it("(DS)(M)(UF)(U)User buys views", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userBalance = await dataStorage.allUsers.call(userContractAddress, {from: user});
        assert.equal(userBalance["c"][0], 0, "User balance is empty before buying views");

        let userContract = await User.at(userContractAddress);
        await userContract.buyViews({from: user, value: ether(1)});

        let minterBalace = await minter.getBalance.call();
        assert.equal(minterBalace["c"][0], 10000, "Minter balance increases with purchase of views");

        let userBalanceAfter = await dataStorage.allUsers.call(userContractAddress, {from: user});
        assert.equal(userBalanceAfter["c"][0], 99995, "Users balance is 1Eth in views(99 995 views)(5 views flat fee)");
    });

    /**
      *
      */
    it("(DS)(M)(UF)(U)User sells views", async () => {
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

        await userContract.sellViews(1000, {from: user});
        let userBalanceAfterSelling = await dataStorage.allUsers.call(userContractAddress, {from: user});
        assert.equal(userBalanceAfterSelling["c"][0], 98995, "User balence is less by 1 000 (98 995 views)(No fee for selling)");
    });

    /**
      * The minter is not directly called here, but in order to successfully 
      * buy views, the transaction has to pass through the minter. 
      */
    it("(DS)(M)(UF)(U)(CCF)(CC)Create content creator", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userContract = await User.at(userContractAddress);
        //using minter
        await userContract.buyViews({from: user, value: ether(1)});
        
        await userContract.becomeContentCreator({from: user});
        await contentCreatorFactory.creatorAddresses.call(0);
        let isCreator = await dataStorage.isCreator.call(userContractAddress);
       
       assert.equal(isCreator, true, "Data storage recognises content creator address");
    });

    it("(DS)(M)(UF)(U)(CCF)(CC)Content creator set to user account", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userContract = await User.at(userContractAddress);
        //using minter
        await userContract.buyViews({from: user, value: ether(1)});
        
        await userContract.becomeContentCreator({from: user});
        let ccContractAddress = await contentCreatorFactory.creatorAddresses.call(0);
        let ccContract = await ContentCreator.at(ccContractAddress);
        let userOwnerContractAddress = await ccContract.userContract();
        let ownerAddress = await ccContract.owner();

        assert.equal(ownerAddress, userContractAddress, "ContentCreator is owned by user account");
        assert.equal(userOwnerContractAddress, userContractAddress, "ContentCreator's userAccount owner set to  owner");
    });

    it("(DS)(M)(UF)(U)(CCF)(CC)Content creator has correct content creator factory", async() => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userContract = await User.at(userContractAddress);
        //using minter
        await userContract.buyViews({from: user, value: ether(1)});
        
        await userContract.becomeContentCreator({from: user});
        let ccContractAddress = await contentCreatorFactory.creatorAddresses.call(0);
        let ccContract = await ContentCreator.at(ccContractAddress);
        let ccFactoryAddress = await ccContract.ccFactoryAddress.call();
        let ccFactoryAddressFromDataStorage = await dataStorage.ccFactoryAddress.call();
        let ccFacotryAddressDeplyed = await contentCreatorFactory.address;

        assert.equal(ccFactoryAddress, ccFacotryAddressDeplyed, "ContentCreatorFactory address is set");
        assert.equal(ccFactoryAddressFromDataStorage, ccFacotryAddressDeplyed, "Data Storage contains correct content creator factory address");
    });

    it("(DS)(M)(CCF)(UF)(U)(CC)Content Creator creating content", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userContract = await User.at(userContractAddress);
        await userContract.buyViews({from: user, value: ether(1)});

        await userContract.becomeContentCreator({from: user});
        let ccContractAddress = await contentCreatorFactory.creatorAddresses.call(0);
        let ccContract = await ContentCreator.at(ccContractAddress);

        await ccContract.createConent(
            "0x999af54356fq51727979591caaf5309mt00033ql", 
            "Test Content Title", 
            "Test Content Description test test",
            {from: userContractAddress}
        )

        let content = await dataStorage.getContent.call(ccContractAddress);
        assert.equal(content[0], userContractAddress, "The user contract for the content is correct");
        assert.equal(content[1], ccContractAddress, "The content creator address is correct");
        assert.equal(content[3], "0x999af54356fq51727979591caaf5309mt00033ql", "IPFS address is correct");
    });

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