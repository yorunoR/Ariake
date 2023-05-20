<template>
  <main class="h-full">
    <h1 style="margin: 100px">Ariake Artificial General Intelligence</h1>
    <Button class="top-50" @click="signIn"> Google Sign in </Button>
  </main>
</template>

<script setup lang="ts">
import { useMutation } from '@urql/vue'
import { useToast } from 'primevue/usetoast'
import router from '@/router'
import firebase from '@/services/firebase'
import { graphql } from '@/gql'
// import SigninUser from '@/doc/mutation/SigninUser'

const toast = useToast()

// const mutation = graphql(SigninUser)
// const { executeMutation: signinUser } = useMutation(mutation)

const signIn = async () => {
  await firebase.signinWithGoogle()
  // const result = await signinUser({})
  // if (result.error) {
  //   toast.add({
  //     severity: 'error',
  //     summary: 'Sign in',
  //     detail: result.error.message
  //   })
  // } else {
  //   router.push({ name: 'question' })
  // }
}
</script>
