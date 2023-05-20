import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import i18n from './services/i18n'

import PrimeVue from 'primevue/config'
import ToastService from 'primevue/toastservice'
import 'primeflex/primeflex.css'
import 'primeicons/primeicons.css'
import 'primevue/resources/primevue.css'
import 'primevue/resources/themes/saga-blue/theme.css'
import Button from 'primevue/button'
import Chip from 'primevue/chip'
import Dialog from 'primevue/dialog'
import Dropdown from 'primevue/dropdown'
import InputText from 'primevue/inputtext'
import RadioButton from 'primevue/radiobutton'
import Sidebar from 'primevue/sidebar'
import Textarea from 'primevue/textarea'
import Toast from 'primevue/toast'

const app = createApp(App)

app
  .use(createPinia())
  .use(i18n)
  .use(router)
  .use(PrimeVue)
  .use(ToastService)
  .component('Button', Button)
  .component('Chip', Chip)
  .component('Dialog', Dialog)
  .component('Dropdown', Dropdown)
  .component('InputText', InputText)
  .component('RadioButton', RadioButton)
  .component('Sidebar', Sidebar)
  .component('Textarea', Textarea)
  .component('Toast', Toast)
  .mount('#app')
