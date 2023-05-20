import { createRouter, createWebHistory } from 'vue-router'

import DefaultLayout from '@/layouts/DefaultLayout.vue'
// import BoardLayout from '@/layouts/BoardLayout.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      redirect: '/ping'
    },
    {
      path: '/',
      component: DefaultLayout,
      children: [
        {
          path: 'ping',
          name: 'ping',
          meta: {
            title: 'ping'
          },
          component: async () => await import(/* webpackChunkName: "ping" */ '@/views/PingView.vue')
        },
        {
          path: 'sign_in',
          name: 'sign_in',
          meta: {
            title: 'sign_in'
          },
          component: async () =>
            await import(/* webpackChunkName: "sign_in" */ '@/views/SignInView.vue')
        }
      ]
    },
    {
      path: '/:catchAll(.*)',
      redirect: '/ping'
    }
  ]
})

router.afterEach((to) => {
  const title = to.meta.title as string
  document.title = title
})

export default router
