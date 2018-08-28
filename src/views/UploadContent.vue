<template>
  <div class="UploadContent">
    <img alt="Vue logo" src="../assets/logo.png">
    <UploadImage/>
  </div>
</template>

<script>
// @ is an alias to /src
import UploadImage from '@/components/UploadImage.vue'

export default {
  name: 'UploadContent',
  components: {
    UploadImage
  }
}
</script>
