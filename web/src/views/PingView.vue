<template>
  <div>
    <h1>This is a ping page</h1>
    <Button>PrimeVue Valid</Button>
    <section>
      <div v-if="fetching">Loading...</div>
      <div v-else-if="error">Oh no... {{ error }}</div>
      <div v-else>
        <p v-if="data">
          {{ data.ping }}
        </p>
      </div>
    </section>
    <section>
      <h1>Subscription</h1>
      <div v-if="userData">
        {{ userData.newUser.name }}
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { useQuery, useSubscription } from '@urql/vue'
import { graphql } from '@/gql'
import Ping from '@/doc/query/Ping'
import NewUser from '@/doc/subscription/NewUser'

const query = graphql(Ping)
const subscription = graphql(NewUser)

const { fetching, error, data } = useQuery({ query })
const { data: userData } = useSubscription({ query: subscription })
</script>
