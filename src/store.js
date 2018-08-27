import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    netIdString: '',
    walletBalance: '',
    defaultEthWallet: '',
    isWalletUnlocked: false,
    isInjected: false,
    ipfsNetworkState: false
  },
  getters: {},
  mutations: {
    setNetworkId(state, netIdString) {
      state.netIdString = netIdString
    },
    setDefaultEthWallet(state, walletAddress) {
      state.defaultEthWallet = walletAddress
    },
    setWalletBalance(state, walletBalance){
      state.walletBalance = walletBalance
    },
    setIPFSNetworkState(state, ipfsNetworkState){
      state.IPFSNetworkState = ipfsNetworkState
    },
    setisInjected(state,isInjected){
      state.isInjected = isInjected
    },
    setisWalletUnlocked(state, isWalletUnlocked){
      state.isWalletUnlocked = isWalletUnlocked
    }
  },
  actions: {}
})

export default store