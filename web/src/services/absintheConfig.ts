// NOTE: https://dev.to/joehua87/simple-way-to-use-abinsthe-subscription-in-urql-1j59
import { Socket } from 'phoenix'
import { make, pipe, toObservable } from 'wonka'
import type { SubscriptionOperation } from '@urql/core'
import type { Channel } from 'phoenix'

const WS_URL = import.meta.env.VITE_APP_WS_URL as string

const socket = new Socket(`${WS_URL}/socket`, {})
socket.connect()
const absintheChannel = socket.channel('__absinthe__:control')
absintheChannel.join()

export const absintheConfig = {
  forwardSubscription(operation: SubscriptionOperation) {
    let subscriptionChannel: Channel

    const source = make((observer) => {
      const { next } = observer

      absintheChannel.push('doc', operation).receive('ok', (v) => {
        const subscriptionId = v.subscriptionId

        if (subscriptionId != null) {
          subscriptionChannel = socket.channel(subscriptionId)
          subscriptionChannel.on('subscription:data', (value) => {
            next(value.result)
          })
        }
      })

      return () => {
        subscriptionChannel?.leave()
      }
    })

    return pipe(source, toObservable)
  }
}
