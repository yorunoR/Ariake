import { createI18n } from 'vue-i18n'
import Ja from '@/locales/ja.json'

type MessageSchema = typeof Ja

export const config = {
  locale: 'Ja',
  fallbackLocale: 'Ja',
  silentFallbackWarn: true,
  messages: {
    Ja
  }
}

const i18n = createI18n<[MessageSchema], 'Ja'>(config)

export default i18n
