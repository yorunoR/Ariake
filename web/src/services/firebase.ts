import { getApp, getApps, initializeApp } from 'firebase/app'
import type { FirebaseError } from 'firebase/app'
import {
  GoogleAuthProvider,
  getAuth,
  getIdToken,
  onAuthStateChanged,
  createUserWithEmailAndPassword,
  signInAnonymously,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut,
  sendPasswordResetEmail
} from 'firebase/auth'
// import 'firebase/messaging'
// import 'firebase/analytics'
import type { ActionCodeSettings, User } from 'firebase/auth'
import swal from 'sweetalert'

import i18n from '@/services/i18n'

interface ErrorMessages {
  [key: string]: string
}

getApps().length === 0
  ? initializeApp({
      apiKey: import.meta.env.VITE_APP_API_KEY,
      authDomain: import.meta.env.VITE_APP_AUTH_DOMAIN,
      databaseURL: import.meta.env.VITE_APP_DATABASE_URL,
      projectId: import.meta.env.VITE_APP_PROJECT_ID,
      storageBucket: import.meta.env.VITE_APP_STORAGE_BUCKET,
      messagingSenderId: import.meta.env.VITE_APP_MESSAGING_SENDER_ID,
      appId: import.meta.env.VITE_APP_APP_ID
    })
  : getApp()

const auth = getAuth()
const { t } = i18n.global

function alertMessage(err: FirebaseError, title: string): void {
  const messages: ErrorMessages = {
    'auth/argument-error': t('firebaseAuth.errors.argumentError'),
    'auth/invalid-email': t('firebaseAuth.errors.invalidEmail'),
    'auth/email-already-in-use': t('firebaseAuth.errors.emailAlreadyInUse'),
    'auth/network-request-failed': t('firebaseAuth.errors.networkFailed'),
    'auth/popup-closed-by-user': t('firebaseAuth.errors.invalidOperation')
  }
  const message = messages[err?.code] ?? err?.message
  swal({ title, text: message }).catch((err) => console.error(err))
}

export default {
  onAuthStateChanged(callback: (user: User | null) => void) {
    return onAuthStateChanged(auth, (user) => {
      callback(user)
    })
  },
  async signupWithEmailAndPassword(email: string, password: string) {
    try {
      await createUserWithEmailAndPassword(auth, email, password)
    } catch (err) {
      alertMessage(err, t('firebaseAuth.signup'))
      throw err
    }
  },
  async loginWithEmailAndPassword(email: string, password: string) {
    try {
      await signInWithEmailAndPassword(auth, email, password)
    } catch (err) {
      alertMessage(err, t('firebaseAuth.login'))
      throw err
    }
  },
  async signinWithGoogle() {
    try {
      const provider = new GoogleAuthProvider()
      await signInWithPopup(auth, provider)
    } catch (err) {
      alertMessage(err, t('firebaseAuth.signin'))
      throw err
    }
  },
  async signinWithGuest() {
    try {
      await signInAnonymously(auth)
    } catch (err) {
      alertMessage(err, t('firebaseAuth.signin'))
      throw err
    }
  },
  async signout() {
    try {
      await signOut(auth)
    } catch (err) {
      alertMessage(err, t('firebaseAuth.signout'))
      throw err
    }
  },
  async resetPassword(email: string, actionCodeSettings: ActionCodeSettings) {
    try {
      await sendPasswordResetEmail(auth, email, actionCodeSettings)
    } catch (err) {
      alertMessage(err, t('firebaseAuth.resetPassword'))
      throw err
    }
  },
  currentUser() {
    return auth.currentUser
  },
  async getIdToken() {
    const currentUser = this.currentUser()
    return currentUser != null ? await getIdToken(currentUser) : null
  }
}
