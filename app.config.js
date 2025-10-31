import 'dotenv/config';

export default {
  name: 'Transport Profit Tracker',
  slug: 'transport-profit-tracker',
  version: '1.0.0',
  orientation: 'portrait',
  platforms: ['android'],
  sdkVersion: '54.0.0',
  userInterfaceStyle: 'light',
  updates: {
    enabled: false // Disable updates until properly configured
  },
  android: {
    package: 'com.transport.profittracker',
    adaptiveIcon: {
      // keep adaptiveIcon config but avoid pointing to a missing local file
      // You can add a valid image to ./assets/icon.png or update this path.
      backgroundColor: '#ffffff'
    }
  },
  assetBundlePatterns: ['**/*'],
  scheme: 'transportprofit',
  extra: {
    supabaseUrl: process.env.SUPABASE_URL,
    supabaseKey: process.env.SUPABASE_ANON_KEY,
  },
};