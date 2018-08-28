import Web3 from 'web3'
import contract from 'truffle-contract'
import userFactoryContractJSON from '../build/contracts/UserFactory.json'
import userContractJSON from '../build/contracts/UserFactory.json'
import store from '../src/store'
//import ccFac
const UserFactoryContract = contract(userFactoryContractJSON)
const UserContract = contract(userContractJSON)

if (typeof web3 !== 'undefined') {
    web3 = new Web3(web3.currentProvider)
    UserFactoryContract.setProvider(web3.currentProvider)
    UserContract.setProvider(web3.currentProvider)
} else {
    web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))
    UserFactoryContract.setProvider(new Web3.providers.HttpProvider('http://localhost:8545'))
    UserContract.setProvider(new Web3.providers.HttpProvider('http://localhost:8545'))
}

let userFactoryContractInstance 

const loadUserFactoryContract = async () => {
    userFactoryContractInstance = await UserFactoryContract.at("0x130b6b972e5877a75c9dc02005aa69c7e5fac535");
    console.log("Loaded user factory...>>>");
}

const createUser = async (_username) => {
    await userFactoryContractInstance.createUser(_username, {
        from: store.state.defaultEthWallet,
        gasPrice: 2000000000,
        gas: '2000000'
    });
}

let userContractInstance

const loadUserContract = async (_userContractAddress) => {
    userContractInstance = await UserFactoryContract.at(_userContractAddress);
}

const becomeContentCreator = async () => {
    //await userContractInstance 
}

const 

export {
    loadUserFactoryContract,
    createUser,
    loadUserContract,

}
