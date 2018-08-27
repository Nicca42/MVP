<template>
  <div class="hello">
      Wallet Address: {{this.$store.state.defaultEthWallet}}
      <br>
      Network Name: {{this.$store.state.netIdString}} 
      <br>
      Wallet Balance: {{this.$store.state.walletBalance}} 
    <h1>Simple Storage Demo</h1>
    Starting Value
    <input v-model="contractCreation.startingValue" name="startingValue" required class="input" type="number" min=0, max=100>
    <br>    
    <el-button type="submit" @click="deployContract" class="button is-primary is-fullwidth subtitle">Store Value</el-button>
    <br>
    <br>
    Contract Address
    <input v-model="loadAddress" name="loadAddress" class="input" type="text">
    <br>
    <el-button @click="loadContract" class="button is-primary is-fullwidth subtitle">Load Contract</el-button>
  <br>
  <br>
  {{contract.address}}
  <p v-if="contract">Contract loaded!</p>
  <br>
  <el-button @click="getValue" :disabled="contract == ''" class="button is-primary is-fullwidth subtitle">Get Value</el-button>
  <br>
  {{retreviedValue}}
  <br>
  <br>
  Change Value 
  <input v-model="userSetValue" name="userSetValue" required class="input" type="number" min=0, max=100>
  <br>
  <el-button @click="setValue" :disabled="contract == ''" class="button is-primary is-fullwidth subtitle">Set Value</el-button>
  </div>
</template>

<script>
import {createSimpleStorageInstance, loadSimpleStorageContract, getSimpleStorageValue, setSimpleStorageValue} from "../../utils/simpleStorageInterface.js";

export default {
  name: "SimpleStorage",
  data() {
    return {
      loadAddress:0,
      contractCreation: {
          startingValue:0,
          from: ''
      },
      contract: '',
      retreviedValue: 0,
      userSetValue: 0
    };
  },
  methods: {
    async deployContract() {
        //set the from the current EthWallet
      this.$data.contractCreation.from = this.$store.state.defaultEthWallet
      const contract = await createSimpleStorageInstance(this.$data.contractCreation);
      this.$data.contract = contract
      console.log(contract);
    },

    async loadContract() {
        console.log(this.$data.loadAddress)
        const contract = await loadSimpleStorageContract(this.$data.loadAddress)
        console.log(contract)
        this.$data.contract = contract        
    },
    
    async getValue () {
        const value = await getSimpleStorageValue(this.$data.contract)
        console.log(value)
        this.$data.retreviedValue = value
    },
    async setValue () {
        const payload = {
            contract: this.$data.contract,
            value: this.$data.userSetValue,
            from: this.$store.state.defaultEthWallet
        }
        const responce = await setSimpleStorageValue(payload)
        console.log(responce)
    }
  }
};
</script>

<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
