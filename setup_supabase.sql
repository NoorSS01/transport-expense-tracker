-- ProfitTracker Database Setup Script
-- Run this in your Supabase SQL Editor

-- Create user profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  phone_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create vehicle configurations table
CREATE TABLE IF NOT EXISTS vehicle_configs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  vehicle_type TEXT NOT NULL,
  vehicle_number TEXT,
  mileage DECIMAL(10,2) NOT NULL,
  earnings_per_km DECIMAL(10,2) NOT NULL,
  monthly_emi DECIMAL(10,2) NOT NULL DEFAULT 0,
  monthly_expenses DECIMAL(10,2) NOT NULL DEFAULT 0,
  current_fuel_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create daily entries table
CREATE TABLE IF NOT EXISTS daily_entries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  kilometers_run DECIMAL(10,2) NOT NULL,
  total_revenue DECIMAL(10,2) NOT NULL,
  fuel_cost DECIMAL(10,2) NOT NULL,
  daily_emi_cost DECIMAL(10,2) NOT NULL,
  daily_expenses DECIMAL(10,2) NOT NULL,
  net_profit DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicle_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_entries ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can manage own vehicle config" ON vehicle_configs;
DROP POLICY IF EXISTS "Users can manage own daily entries" ON daily_entries;

-- Create policies for user_profiles
CREATE POLICY "Users can view own profile" ON user_profiles 
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles 
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles 
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create policies for vehicle_configs
CREATE POLICY "Users can manage own vehicle config" ON vehicle_configs 
  FOR ALL USING (auth.uid() = user_id);

-- Create policies for daily_entries
CREATE POLICY "Users can manage own daily entries" ON daily_entries 
  FOR ALL USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_vehicle_configs_user_id ON vehicle_configs(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_entries_user_id ON daily_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_entries_date ON daily_entries(date);
CREATE INDEX IF NOT EXISTS idx_daily_entries_user_date ON daily_entries(user_id, date);

-- Create a function to automatically create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create user profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.user_profiles TO anon, authenticated;
GRANT ALL ON public.vehicle_configs TO anon, authenticated;
GRANT ALL ON public.daily_entries TO anon, authenticated;
