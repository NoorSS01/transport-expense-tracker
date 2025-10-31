import { createClient } from '@supabase/supabase-js';
import Constants from 'expo-constants';

// Get the Supabase URL and anonymous key from app config
const SUPABASE_URL = Constants.expoConfig?.extra?.supabaseUrl || '';
const SUPABASE_ANON_KEY = Constants.expoConfig?.extra?.supabaseKey || '';

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.warn('Supabase configuration is missing. Please check your app.config.js file.');
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export default supabase;
