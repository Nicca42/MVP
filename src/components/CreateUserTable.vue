<template>
  <div class="hello">
   <p>Input Username</p>
   <input v-model="submittedUserName" name="submittedUserName" >
   <el-button type="submit" @click="createUser" class="button is-primary is-fullwidth subtitle">create User</el-button>
   <br>
   <el-button type="submit" @click="loadUser" class="button is-primary is-fullwidth subtitle">Load user functionality</el-button>
    <br>
   <el-button type="submit" @click="makeContentCreator" class="button is-primary is-fullwidth subtitle">Become Conent Creator</el-button>
  </div>
</template>
<script>
import {
    loadUserFactoryContract,
    createUser,
    loadUserContract,
    loadDataStorageContract, 
    becomeContentCreator
} from "../../utils/mvpInteractions.js"
export default {
  name: 'HelloWorld',
  data() {
    return {
      submittedUserName:""
    }
  },
  methods: {
    async createUser(){
      await createUser(this.submittedUserName);
      console.log("User contract created...>>>")
    },
    async loadUser(){
      await loadUserContract()
      console.log("Loaded user contract...>>>")
    },
    async makeContentCreator(){
      await becomeContentCreator()
      console.log("Make conent creator...>>>")
    }
  }, 
  async mounted() {
    await loadUserFactoryContract()
    await loadDataStorageContract()

  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
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
