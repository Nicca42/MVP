<template>
  <div id="app">
    <div id="walletStatus">
      <el-row>
        <el-col :span="24">
          Wallet Address: {{this.$store.state.defaultEthWallet}}  | Network Name: {{this.$store.state.netIdString}} | Wallet Balance: {{this.$store.state.walletBalance}}
          <hr>
        </el-col>
      </el-row>
    </div>
    <div id="nav">
      <el-row>
        <el-col :span="24">
          <router-link to="/">Home</router-link> |
          <router-link to="/EthereumContracts">Ethereum Contracts </router-link> |
          <router-link to="/UploadContent">Upload Content</router-link> |
          <router-link to="/CreateUser">Become User</router-link>
        </el-col>
      </el-row>
    </div>
    <router-view/>
  </div>
</template>

<style lang="scss">
#app {
  font-family: "Avenir", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
#nav {
  padding: 10px;
  a {
    font-weight: bold;
    color: #2c3e50;
    &.router-link-exact-active {
      color: #42b983;
    }
  }
}
#walletStatus {
  padding: 10px;
  a {
    color: #2c3e50;
    &.router-link-exact-active {
      color: #42b983;
    }
  }
}
</style>
