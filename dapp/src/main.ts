import { createApp } from 'vue'
import App from './App.vue'
import { createPinia } from 'pinia'
import router from "./router";
import 'element-plus/dist/index.css'
import piniaPersist from 'pinia-plugin-persist'
const pinia = createPinia();
pinia.use(piniaPersist);
const app = createApp(App);

app.use(pinia)

app.use(router);

app.mount('#app');

