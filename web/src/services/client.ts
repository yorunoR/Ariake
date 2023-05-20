import { authExchange } from '@urql/exchange-auth'
import {
  createClient,
  dedupExchange,
  cacheExchange,
  fetchExchange,
  subscriptionExchange
} from '@urql/vue'
import type { Client } from '@urql/vue'

import { authConfig } from '@/services/authConfig'
// import { absintheConfig } from '@/services/absintheConfig'

const API_URL = import.meta.env.VITE_APP_API_URL as string

export function makeClient(): Client {
  return createClient({
    url: `${API_URL}/api`,
    exchanges: [
      dedupExchange,
      cacheExchange,
      authExchange(authConfig),
      fetchExchange
      // subscriptionExchange(absintheConfig)
    ]
  })
}
