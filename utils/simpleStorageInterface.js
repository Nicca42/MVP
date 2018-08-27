import Web3 from 'web3'
import contract from 'truffle-contract'
import contractJSON from '../build/contracts/SimpleStorage.json'
const Contract = contract(contractJSON)

if (typeof web3 !== 'undefined') {
    web3 = new Web3(web3.currentProvider)
    Contract.setProvider(web3.currentProvider)
} else {
    web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))
    Contract.setProvider(new Web3.providers.HttpProvider('http://localhost:8545'))
}

const createSimpleStorageInstance = async (c) => {
    const newContract = await Contract.new(c.startingValue, {
        from: c.from,
        gasPrice: 2000000000,
        gas: '2000000'
    })
    return newContract
}

const loadSimpleStorageContract = async (c) => {
    const deployedContract = await Contract.at(c)
    return deployedContract
}

const getSimpleStorageValue = async (c) => {
    return c.get()
}

const setSimpleStorageValue = async (c) => {
    const transaction = c.contract.set(c.value, {
        from: c.from,
        gasPrice: 2000000000,
        gas: '2000000'
    })
    return transaction
}

export {
    createSimpleStorageInstance,
    loadSimpleStorageContract,
    getSimpleStorageValue,
    setSimpleStorageValue
}