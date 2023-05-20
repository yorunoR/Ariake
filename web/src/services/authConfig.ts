import swal from 'sweetalert'
import firebase from '@/services/firebase'

export const authConfig = async (utils: any) => {
  let token = await firebase.getIdToken()

  return {
    async refreshAuth() {
      token = await firebase.getIdToken()
    },
    willAuthError: () => {
      return true
    },
    addAuthToOperation(operation: any) {
      if (token == null) {
        return operation
      }

      return utils.appendHeaders(operation, {
        Authorization: `Bearer ${token}`
      })
    },
    didAuthError(error: any) {
      if (error.graphQLErrors.some((e: any) => e.message === 'You need to be logged in')) {
        swal({ title: 'Error', text: 'Sign in to get started.' }).catch((err) => console.error(err))
      }

      return false
    }
  }
}
