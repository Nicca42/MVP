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
      *     to test one contract without testing another. Each test tests multiple things
      *     from multiple contracts. 
      *     For example, testing the creation of a user also test the DataStorage, 
      *     the UserFactory and User contracts. Any functions that include the transference
      *     of funds will test the LoveMachine (minter) directly or indirectly, as all value 
      *     transfers must be called by the loveMachine. 
      * 
      *     To make it easier to see where each contract is being test and what 
      *     other contracts are being tested, I have included an index: 
      *         
      *         Index   | Contract                  | Total Tests   
      *         --------+---------------------------+------------
      *         (R)     | Register.sol              | 
      *         (DS)    | DataStorage.sol           | 8
      *         (M)     | LoveMachine.sol           | 6
      *         (UF)    | UserFactory.sol           | 10
      *         (CCF)   | ContentCreatorFactory.sol | 4
      *         (U)     | User.sol                  | 10
      *         (CC)    | ContentCreator.sol        | 4
      * 
      *     The order of test indexes will aways be in this order. These are all the tests in 
      *     the order they apear. 
      * 
      *     (R)     (DS)    (M)     (UF)    (U)     (CCF)   (CC)    | Name of test
      *     --------------------------------------------------------+--------------------------------
      *             (DS)            (UF)    (U)                     | Creator user
      *                             (UF)    (U)                     | Get userName from user contract
      *             (DS)            (UF)    (U)                     | Get userName from dataStorage
      *                             (UF)    (U)                     | Get user owner
      *             (DS)    (M)     (UF)    (U)                     | User buys views
      *             (DS)    (M)     (UF)    (U)                     | User sells views
      *             (DS)    (M)     (UF)    (U)     (CCF)   (CC)    | Create content creator
      *             (DS)    (M)     (UF)    (U)     (CCF)   (CC)    | Content creator's set to user contract
      *             (DS)    (M)     (UF)    (U)     (CCF)   (CC)    | Content creator has correct content creator factory
      *             (DS)    (M)     (UF)    (U)     (CCF)   (CC)    | Content Creator creating content
      *             (DS)    (M)     (UF)    (U)     (CCF)   (CC)    | User likes content created
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
        console.log("User is registered in the system...>>>");
    });

    it("(UF)(U)Get userName from user contract", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userContract = await User.at(userContractAddress);
        let userName = await userContract.userName.call();
        assert.equal(userName, "Test001", "userName is the userName entered");
        console.log("UserName is correct...>>>");
    });

    it("(DS)(UF)(U)Get userName from dataStorage", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userNameInDataStorage = await dataStorage.getAUsersNameData.call(userContractAddress);
        assert.equal(userNameInDataStorage, "Test001", "userName is stored in dataStorage");
        console.log("User name is correct in dataStorage...>>>");
    });

    it("(UF)(U)Get user owner", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userContract = await User.at(userContractAddress);
        let userOwner = await userContract.owner.call();
        assert.equal(userOwner, user, "user owner is stored in dataStorage");
        console.log("Correct user owner is stored in dataStorage...>>>");
    });

    /**
      * 
      */
    it("(DS)(M)(UF)(U)User buys views", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userBalance = await dataStorage.allUsers.call(userContractAddress, {from: user});
        assert.equal(userBalance["c"][0], 0, "User balance is empty before buying views");
        console.log("User balance is empty before buying views...>>>");

        let userContract = await User.at(userContractAddress);
        await userContract.buyViews({from: user, value: ether(1)});

        let minterBalace = await minter.getBalance.call();
        assert.equal(minterBalace["c"][0], 10000, "Minter balance increases with purchase of views");
        console.log("Minters balance increased with the purchase of views...>>>");

        let userBalanceAfter = await dataStorage.allUsers.call(userContractAddress, {from: user});
        assert.equal(userBalanceAfter["c"][0], 99995, "Users balance is 1Eth in views(99 995 views)(5 views flat fee)");
        console.log("Users balance is 99 995 after purchase of views...>>>");
    });

    // it("Content creator transfers views to user account", async () => {
    //     //test transfer function
    //     //test change in dataStorage
    //     //test balances of both contacts.
    //     //test withdrawing more views than balance
    // });

    // it("test user transfering views to creator account", async () => {
    //     //test transfer function
    //     //test change in dataStorage
    //     //test balances of both contacts.
    // });

    /**
      *
      */
    it("(DS)(M)(UF)(U)User sells views", async () => {
        await userFactory.createUser("Test001", {from: user});
        let userContractAddress = await userFactory.userAddresses(0);

        let userBalance = await dataStorage.allUsers.call(userContractAddress, {from: user});
        assert.equal(userBalance["c"][0], 0, "User balance is empty before buying views");
        console.log("Users balance is empty before buying views...>>>");

        let userContract = await User.at(userContractAddress);
        userContract.buyViews({from: user, value: ether(1)});

        let minterBalace = await minter.getBalance.call();
        assert.equal(minterBalace["c"][0], 10000, "Minter balance increases with purchase of views");
        console.log("Minters balance increases with user purchase...>>>");

        let userBalanceAfter = await dataStorage.allUsers.call(userContractAddress, {from: user});
        assert.equal(userBalanceAfter["c"][0], 99995, "Users balance is 1Eth in views(99 995 views)(5 views flat fee)");
        console.log("Users balance is 99 995 after purchase...>>>");

        await userContract.sellViews(1000, {from: user});
        let userBalanceAfterSelling = await dataStorage.allUsers.call(userContractAddress, {from: user});
        assert.equal(userBalanceAfterSelling["c"][0], 98995, "User balence is less by 1 000 (98 995 views)(No fee for selling)");
        console.log("Users balance is 98 995 after selling 1 000 views...>>>");
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
       console.log("Content Creator contract registered on system...>>>");
    });

    it("(DS)(M)(UF)(U)(CCF)(CC)Content creator's set to user contract", async () => {
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
        console.log("Content creator is owned by correct user contract...>>>");

        assert.equal(userOwnerContractAddress, userContractAddress, "ContentCreator's userAccount owner set to  owner");
        console.log("user contracts owner is correct...>>>");
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
        console.log("Content Creator has the correct content creator address...>>>");
        assert.equal(
            ccFactoryAddressFromDataStorage, 
            ccFacotryAddressDeplyed, 
            "Data Storage contains correct content creator factory address"
        );
        console.log("Data storage contains the correct content creator factory address...>>>");
    });

    it("(DS)(UF)(U)Deleting user acount", async () => {
        await userFactory.createUser("Test001", {from: user});
        
        let userContractAddress = await userFactory.userAddresses(0);
        let userContract = await User.at(userContractAddress);

        let isUser = await dataStorage.isUser.call(userContractAddress);
        assert.equal(isUser, true, "The user is registed in the system");
        console.log("User is registered in system...>>>");
        
        await userContract.deleteUser({from: user});
        let isUserAfterDelete = await dataStorage.isUser.call(userContractAddress);
        console.log("isUser after delete");
        console.log(isUserAfterDelete);

        assert.equal(isUserAfterDelete, false, "User is deleted and will no longer be a user in the system");
        console.log("The contract and all data is deleted...>>>");
    });

    // it("(DS)(UF)(U)(CCF)(CC)Deleting creator", async () => {
    //     await userFactory.createUser("Test001", {from: user});
        
    //     let userContractAddress = await userFactory.userAddresses(0);
    //     let userContract = await User.at(userContractAddress);

    //     let isUser = await dataStorage.isUser.call(userContractAddress);
    //     assert.equal(isUser, true, "The user is registed in the system");

    //     await userContract.becomeContentCreator({from: user});
    //     let isCreator = await dataStorage.isCreator.call(userContractAddress);
    //     let ccContractAddress = await contentCreatorFactory.creatorAddresses.call(0);
    //     let ccContract = await ContentCreator.at(ccContractAddress);
       
    //     assert.equal(isCreator, true, "Data storage recognises content creator address");

    //     let ownerBeforeDelete = await ccContract.owner.call();
    //     await userContract.deleteUser({from: userContractAddress});
    //     //let ownerAfterDelete = await ccContract.owner.call();
    //     //test the contract moves balance
    //     //test the contract deletes all instances of the creator
    //     //test the content is no longer findable. IPFS
    // });

    it("(R)(DS)(UF)Updating UserFactory", async () => {
        let userFactoryAddress = await userFactory.address;

        userFactory2 = await UserFactory.new(
            dataStorage.address, 
            owner, 
            contentCreatorFactory.address
        );

        let userFactory2Address = await userFactory2.address;

        assert.notEqual(userFactoryAddress, userFactory2Address, "Address of new userFactory contract is different");
        console.log("New userFactory is different from old one...>>>");
        console.log(userFactory2Address)

        let userFactoryAddressInDSBefore = await dataStorage.getUserFactory.call();
        assert.equal(userFactoryAddress, userFactoryAddressInDSBefore, "Current User factory is in dataStorage correctly");
        console.log("Current user factory is in dataStorage...>>>");

        await register.changeUserFactory(userFactory2Address, {from: owner});
        console.log("Register sent new address");
        let userFactoryAddressInDSAfter = await dataStorage.getUserFactory.call();
        console.log("Old userFactory ");
        console.log(userFactoryAddressInDSBefore);
        console.log(userFactoryAddress);
        console.log("New User factory address");
        console.log(userFactoryAddressInDSAfter);
        console.log(userFactory2Address);

        assert.equal(userFactory2Address, userFactoryAddressInDSAfter, "UserFactory is changed to new userFactory in dataStorage");
        console.log("New user factory address is in dataStorage...>>>");

        // await userFactory2.createUser("Test001", {from: user});
        // console.log("user created off new userFactory...");
        // let userContractAddress = await userFactory2.userAddresses(0);
        // console.log("user contract address recived from new user factory...");
        // let userContract = await User.at(userContractAddress);
        // console.log("user contract set to new instance of user...");
        
        // let userContractAddress = await userFactory2.userAddresses(0);
        // let userContract = await User.at(userContractAddress);

        // let userOwner = await userContract.owner.call();
        // assert.equal(userOwner, user, "Functionality works on newly deployed UserFactory contract");
        // console.log("New UserFactories functionality works...>>>");

        // let userFactoryAddressInDSAfter = await dataStorage.getUserFactory.call();

        // assert.notEqual(userFactoryAddressInDSBefore, userFactoryAddressInDSAfter, "UserFactory changed in dataStorage");
    });

    // it("(R)(DS)(CCF)Updating ContentCreatorFactory", async () => {

    // });

/** 
    //DO NOT DO UNNESSASARY FUNCTIONS STICK TO THE IMPORTANT ONES
    //and the majority of the small ones will be tested indirectly by 
    //other tests that they effect the results of.

    //test the register
    //repeat this step for all contracts being tracked by the register
    */

    // it("(DS)(M)(UF)(U)(CCF)(CC)Content Creator creating content", async () => {
    //     await userFactory.createUser("Test001", {from: user});
    //     let userContractAddress = await userFactory.userAddresses(0);

    //     let userContract = await User.at(userContractAddress);
    //     await userContract.buyViews({from: user, value: ether(1)});

    //     await userContract.becomeContentCreator({from: user});
    //     let ccContractAddress = await contentCreatorFactory.creatorAddresses.call(0);
    //     let ccContract = await ContentCreator.at(ccContractAddress);

    //     await ccContract.createConent(
    //         "0x999af54356fq51727979591caaf5309mt00033ql", 
    //         "Test Content Title", 
    //         "Test Content Description test test",
    //         {from: userContractAddress}
    //     )

    //     let content = await dataStorage.getContent.call(ccContractAddress);
    //     assert.equal(content[0], userContractAddress, "The user contract for the content is correct");
    //     assert.equal(content[1], ccContractAddress, "The content creator address is correct");
    //     assert.equal(content[3], "0x999af54356fq51727979591caaf5309mt00033ql", "IPFS address is correct");
    // });

    // it("(DS)(M)(UF)(U)(CCF)(CC)User likes content created", async () => {
    //     await userFactory.createUser("Test001", {from: user});
    //     let userContractAddress = await userFactory.userAddresses(0);
    //     let userContract = await User.at(userContractAddress);

    //     await userContract.buyViews({from: user, value: ether(1)});
    //     let minterBalace = await minter.getBalance.call();

    //     await userContract.becomeContentCreator({from: user});
    //     let ccContractAddress = await contentCreatorFactory.creatorAddresses.call(0);
    //     let ccContract = await ContentCreator.at(ccContractAddress);
    //     //TODO: fix content creaton bugs...

    //     let ccContractBalanceBefore = await dataStorage.allCreators.call(userContractAddress);
    //     let userContractBalanceBefore = await dataStorage.allUsers.call(userContractAddress);

    //     await minter.liked(ccContractAddress, userContractAddress, {from: userContractAddress});

    //     let ccContractBalanceAfter = await dataStorage.allCreators.call(userContractAddress);
    //     let userContractBalanceAfter = await dataStorage.allUsers.call(userContractAddress);

    //     assert.notEqual(ccContractBalanceBefore["c"][0], ccContractBalanceAfter["c"][0], "Content Creator Contract was paid");
    //     assert.notEqual(userContractBalanceBefore["c"][0], userContractBalanceAfter["c"][0], "User Contract had funds removed");

    //     let ccContractDifference = await ccContractBalanceBefore - ccContractBalanceAfter;
    //     let userContractDifference = await userContractBalanceAfter - userContractBalanceBefore;
    //     assert.equal(ccContractDifference, userContractDifference, "Differenct between change is the same");
    // });

    // it("(DS)(M)(UF)(U)(CCF)(CC)User loves content created", async () => {
    //     await userFactory.createUser("Test001", {from: user});
    //     let userContractAddress = await userFactory.userAddresses(0);
    //     let userContract = await User.at(userContractAddress);

    //     await userContract.buyViews({from: user, value: ether(1)});
    //     let minterBalace = await minter.getBalance.call();
    //     assert.equal(minterBalace["c"][0], 10000, "Minter balance increases with purchase of views");

    //     await userContract.becomeContentCreator({from: user});
    //     let ccContractAddress = await contentCreatorFactory.creatorAddresses.call(0);
    //     let ccContract = await ContentCreator.at(ccContractAddress);
    //     //TODO: fix content creaton bugs...

    //     let ccContractBalanceBefore = await dataStorage.allCreators.call(userContractAddress);
    //     let userContractBalanceBefore = await dataStorage.allUsers.call(userContractAddress);

    //     await minter.loved(ccContractAddress, userContractAddress, {from: userContractAddress});

    //     let ccContractBalanceAfter = await dataStorage.allCreators.call(userContractAddress);
    //     let userContractBalanceAfter = await dataStorage.allUsers.call(userContractAddress);

    //     assert.notEqual(ccContractBalanceBefore["c"][0], ccContractBalanceAfter["c"][0], "Content Creator Contract was paid");
    //     assert.notEqual(userContractBalanceBefore["c"][0], userContractBalanceAfter["c"][0], "User Contract had funds removed");

    //     let ccContractDifference = await ccContractBalanceBefore - ccContractBalanceAfter;
    //     let userContractDifference = await userContractBalanceAfter - userContractBalanceBefore;
    //     assert.equal(ccContractDifference, userContractDifference, "Differenct between change is the same");
    // });

    // it("(DS)(M)(UF)(U)(CCF)(CC)User fan loved content created", async () => {
    //     await userFactory.createUser("Test001", {from: user});
    //     let userContractAddress = await userFactory.userAddresses(0);
    //     let userContract = await User.at(userContractAddress);

    //     await userContract.buyViews({from: user, value: ether(1)});
    //     let minterBalace = await minter.getBalance.call();
    //     assert.equal(minterBalace["c"][0], 10000, "Minter balance increases with purchase of views");

    //     await userContract.becomeContentCreator({from: user});
    //     let ccContractAddress = await contentCreatorFactory.creatorAddresses.call(0);
    //     let ccContract = await ContentCreator.at(ccContractAddress);
    //     //TODO: fix content creaton bugs...

    //     let ccContractBalanceBefore = await dataStorage.allCreators.call(userContractAddress);
    //     let userContractBalanceBefore = await dataStorage.allUsers.call(userContractAddress);

    //     await minter.fanLoved(ccContractAddress, userContractAddress, {from: userContractAddress});

    //     let ccContractBalanceAfter = await dataStorage.allCreators.call(userContractAddress);
    //     let userContractBalanceAfter = await dataStorage.allUsers.call(userContractAddress);

    //     assert.notEqual(ccContractBalanceBefore["c"][0], ccContractBalanceAfter["c"][0], "Content Creator Contract was paid");
    //     assert.notEqual(userContractBalanceBefore["c"][0], userContractBalanceAfter["c"][0], "User Contract had funds removed");

    //     let ccContractDifference = await ccContractBalanceBefore - ccContractBalanceAfter;
    //     let userContractDifference = await userContractBalanceAfter - userContractBalanceBefore;
    //     assert.equal(ccContractDifference, userContractDifference, "Differenct between change is the same");
    // });
})