import Vue from 'vue'
import Router from 'vue-router'
import Home from './views/Home.vue'
import EthereumContracts from './views/EthereumContracts.vue'
import UploadContent from './views/UploadContent.vue'
import CreateUser from './views/CreateUser.vue'

Vue.use(Router)

export default new Router({
    routes: [
        {
            path: '/',
            name: 'home',
            component: Home
        },
        {
            path: '/EthereumContracts',
            name: 'EthereumContracts',
            component: EthereumContracts
        },
        {
            path: '/UploadContent',
            name: 'UploadContent',
            component: UploadContent
        },
        {
            path: '/CreateUser',
            name: 'CreateUser',
            component: CreateUser
        },
    ]
})
