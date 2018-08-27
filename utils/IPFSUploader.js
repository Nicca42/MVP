//using the infura.io node, otherwise ipfs requires you to run a //daemon on your own computer/server.
const IPFS = require('ipfs')
import store from '../src/store'

const ipfs = new IPFS({
    host: 'ipfs.infura.io',
    port: 5001,
    protocol: 'https'
});
//run with local daemon
// const ipfsApi = require(‘ipfs-api’);
// const ipfs = new ipfsApi(‘localhost’, ‘5001’, {protocol:‘http’});


ipfs.on('ready', async () => {
    const version = await ipfs.version()
    console.log('IPFS Connected! Version:', version.version)
    store.commit('setIPFSNetworkState', true)
})

const uploadFile = async (c) => {
    const filesAdded = await ipfs.files.add({
        content: Buffer.from(c)
    })
    /*eslint no-console: ["error", { allow: ["warn", "error"] }] */
    console.log('Added file:', filesAdded[0].hash)
    return filesAdded[0].hash
}

const viewFile = async (c) => {
    const fileBuffer = await ipfs.files.cat(c)
    return fileBuffer.toString()
}

export {
    uploadFile,
    viewFile
}