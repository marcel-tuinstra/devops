// Template: Health check endpoint for Nuxt SSR projects.
// Copy this file to your project at server/api/health.get.ts.

export default defineEventHandler(() => {
  return {
    status: 'ok',
    timestamp: new Date().toISOString(),
  }
})
