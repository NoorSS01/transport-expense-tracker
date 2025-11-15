class AppConstants {
  // Supabase Configuration
  // TODO: Replace with your actual Supabase URL and anon key
static const String supabaseUrl = 'https://xxxojrroukhmdkiuhglx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4eG9qcnJvdWtobWRraXVoZ2x4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyMjI3MjAsImV4cCI6MjA3ODc5ODcyMH0.7823kdSbvSkxTzVSMLPg-U1TRPE8KH5kSqlY_sZvBkw';

  // App Configuration
  static const String appName = 'ProfitTracker';
  static const String appVersion = '1.0.0';
  
  // Shared Preferences Keys
  static const String keyIsFirstTime = 'is_first_time';
  static const String keyUserSetupComplete = 'user_setup_complete';
  
  // Default Values
  static const double defaultFuelPrice = 100.0; // per liter
  static const double defaultMileage = 15.0; // km per liter
  static const double defaultEarningsPerKm = 25.0; // rupees per km
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
