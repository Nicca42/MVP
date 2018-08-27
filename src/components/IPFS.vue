<template>
    <div class="OrbitDB">
        <h1>IPFS Implementation</h1>
        <p>Add Text</p>
        <input v-model="inputText" name="inputText" class="input" type="text">
        <br>
        <el-button @click="addText" class="button is-primary is-fullwidth subtitle">Add To IPFS</el-button>
        <br>
        {{createdAddress}}
        <p>Load Hash</p>
        <input v-model="loadAddress" name="loadAddress" class="input" type="text">
        <br>
        <el-button @click="loadHash" class="button is-primary is-fullwidth subtitle">Load Hash</el-button>
        <br>
        {{retreivedText}}
    
    </div>
</template>
<script>
    // import {createDB, loadDB, addValueToLog, getValuesFromLog} from "../../utils/OrbitDB.js";
    import {uploadFile, viewFile} from "../../utils/IPFSUploader"

    export default {
        name: "IPFS",
        data() {
            return {
                inputText: '',
                createdAddress: '',
                loadAddress: '',
                retreivedText: ''
            };
        },
        methods: {
            async addText() {
                let createdAddress = await uploadFile(this.$data.inputText)
                this.$data.createdAddress = createdAddress
            },
            async loadHash() {
               let returnedValue = await viewFile(this.$data.loadAddress)
               this.$data.retreivedText = returnedValue
            }
        }
    }
</script>