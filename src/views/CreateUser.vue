<template>
  <div class="CreateUser">
    <h1>Create a New User</h1>
    <CreateUserTable/>
  </div>
</template>

<script>
// @ is an alias to /src
import CreateUserTable from '@/components/CreateUserTable.vue'

export default {
  name: 'CreateUser',
  components: {
    CreateUserTable
  }
}
</script>
