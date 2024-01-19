// nuxt.config.ts
//import { defineNuxtConfig } from 'nuxt'

// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
  //ssr: false,
  css: ['vuetify/lib/styles/main.sass', '@mdi/font/css/materialdesignicons.min.css'],
  build: {
    transpile: ['vuetify'],
  },
  vite: {
    define: {
      'process.env.DEBUG': true,
    },
  },
  modules: [
    '@pinia/nuxt',
  ],
  nitro: {
    preset: 'aws-lambda'
  },
  app: {
    cdnURL: 'https://d3dp6e36j91r3.cloudfront.net'
  },
  runtimeConfig: {
    public: {
      apiUrl: 'https://uvbigmveiag4moowfpbqix5z5i0ycxgs.lambda-url.eu-north-1.on.aws/api',
    },
  },
})
