<template>
  <div class="hello">
   <p>Input Username</p>
   <input v-model="submittedUserName" name="submittedUserName" >
   <el-button type="submit" @click="createUser" class="button is-primary is-fullwidth subtitle">create User</el-button>
  </div>
</template>

<script>
import {
    loadUserFactoryContract,
    createUser
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
    }
  }, 
  async mounted() {
    await loadUserFactoryContract()
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
