import { defineConfig } from 'vite'
import elm from 'vite-plugin-elm-watch'

export default defineConfig({
  server: {
    port : 8000
  },
  plugins: [elm()]
})