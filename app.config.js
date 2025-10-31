import 'dotenv/config';

export default {
  name: 'Transport Profit Tracker',
  slug: 'transport-profit-tracker',
  version: '1.0.0',
  orientation: 'portrait',
  platforms: ['android'],
  icon: './assets/icon.png',
  userInterfaceStyle: 'light',
  updates: {
    fallbackToCacheTimeout: 0
  },
  assetBundlePatterns: ['**/*'],
  extra: {
    supabaseUrl: process.env.SUPABASE_URL,
    supabaseKey: process.env.SUPABASE_ANON_KEY,
  },
};