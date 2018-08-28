<template>
  <div class="UploadImage">
    <input type="file" @change="previewImage" accept="image/*">
    <br>
    <br>
    <div class="image-preview" v-if="form.imageData.length > 0">
        <img class="preview" :src="form.imageData">
    </div>
  </div>
</template>

<script>
export default {
  name: 'UploadImage',
  data(){
      return {
          imageData: ""
      }
  },
    methods: {
        previewImage: function(event) {
            var input = event.target;
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = e => {
                this.imageData = e.target.result;
                };
                reader.readAsDataURL(input.files[0]);
            }
        },
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
