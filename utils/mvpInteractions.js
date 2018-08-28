import Web3 from 'web3'
import contract from 'truffle-contract'
import userFactoryContractJSON from '../build/contracts/UserFactory.json'
import userContractJSON from '../build/contracts/UserFactory.json'
import dataStorageContractJSON from '../build/contracts/DataStorage.json'
import store from '../src/store'
//import ccFac
const UserFactoryContract = contract(userFactoryContractJSON)
const UserContract = contract(userContractJSON)
const DataStorageContract = contract(dataStorageContractJSON)
 
if (typeof web3 !== 'undefined') {
    web3 = new Web3(web3.currentProvider)
    UserFactoryContract.setProvider(web3.currentProvider)
    UserContract.setProvider(web3.currentProvider)
    DataStorageContract.setProvider(web3.currentProvider)
} else {
    web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))
    UserFactoryContract.setProvider(new Web3.providers.HttpProvider('http://localhost:8545'))
    UserContract.setProvider(new Web3.providers.HttpProvider('http://localhost:8545'))
    DataStorageContract.setProvider(new Web3.providers.HttpProvider('http://localhost:8545'))
}

let dataStorageContractInstance

const loadDataStorageContract = async () => {
    dataStorageContractInstance = await DataStorageContract.at("0x03d12a91bc8af40d6dab7686651a807e69055893");
    console.log("Loaded dataStorage...>>>");
}

const getUserContractAddressFromDataStorage = async () => {
    return await dataStorageContractInstance.getUserContractAddress(store.state.defaultEthWallet)
}

let userFactoryContractInstance 

const loadUserFactoryContract = async () => {
    userFactoryContractInstance = await UserFactoryContract.at("0xb831cb1152d1656e40365811647fd33f3f836fa5");
    console.log("Loaded user factory...>>>");
}

const createUser = async (_username) => {
    await userFactoryContractInstance.createUser(_username, {
        from: store.state.defaultEthWallet,
        gasPrice: 2000000000,
        gas: '2000000'
    });
    console.log("Create user...>>>")
}

let userContractInstance

const loadUserContract = async () => {
    let userContractAddress = await getUserContractAddressFromDataStorage()
    userContractInstance = await UserContract.at(userContractAddress);
    console.log("Loaded user contract...>>>")
}

const becomeContentCreator = async () => {
    await userContractInstance.becomeContentCreator({
        from: store.state.defaultEthWallet,
        gasPrice: 2000000000,
        gas: '2000000'
    })
    console.log("Beocome content creator...>>>")
}

export {
    loadUserFactoryContract,
    createUser,
    loadUserContract,
    loadDataStorageContract, 
    becomeContentCreator
}
