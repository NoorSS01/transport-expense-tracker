import { createClient } from '@supabase/supabase-js';
import Constants from 'expo-constants';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Default Supabase configuration for development
const DEFAULT_SUPABASE_URL = 'https://xopqanwaxiusepbygjoh.supabase.co';
const DEFAULT_SUPABASE_KEY = 'sb_publishable_pgg8VZz6SYLpYoQn7OPg7Q_4995x2tW';

// Get the Supabase URL and anonymous key from app config or environment, fallback to defaults
const SUPABASE_URL = Constants.expoConfig?.extra?.supabaseUrl || 
                     process.env.SUPABASE_URL || 
                     DEFAULT_SUPABASE_URL;

const SUPABASE_ANON_KEY = Constants.expoConfig?.extra?.supabaseKey || 
                         process.env.SUPABASE_ANON_KEY || 
                         DEFAULT_SUPABASE_KEY;

if (SUPABASE_URL === DEFAULT_SUPABASE_URL || SUPABASE_ANON_KEY === DEFAULT_SUPABASE_KEY) {
  console.warn('Using default Supabase configuration. For production, set SUPABASE_URL and SUPABASE_ANON_KEY in your .env file.');
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
});

export default supabase;
