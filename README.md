# ProfitTracker

A simple yet powerful mobile app designed specifically for transport owners, drivers, and small fleet operators to track their daily profits and expenses effortlessly.

## Features

### 🚛 **Effortless Daily Tracking**
- Enter kilometers traveled - the app handles all calculations
- Instant profit/loss calculation for each day
- Real-time revenue, fuel cost, and expense breakdown

### 📊 **Smart Financial Insights**
- Daily profit/loss overview with visual indicators
- Monthly performance tracking and trends
- Automatic EMI and expense distribution across days
- Profit margin analysis and performance metrics

### 📱 **Modern User Experience**
- Beautiful, intuitive interface with premium design
- Secure authentication with email and Google sign-in
- Responsive design optimized for mobile devices
- Smooth animations and modern UI components

### ⚙️ **Flexible Configuration**
- Support for multiple vehicle types (truck, taxi, auto, bus, etc.)
- Customizable earnings per kilometer
- Adjustable fuel prices and mileage settings
- Monthly EMI and expense management

### 📈 **Visual Analytics**
- Interactive charts showing profit trends
- Revenue vs expenses comparison graphs
- Daily distance tracking visualization
- Monthly performance summaries

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Supabase account for backend services

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd transport-profit-tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a new project on [Supabase](https://supabase.com)
   - Update `lib/utils/constants.dart` with your Supabase URL and anon key:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. **Set up database tables**
   Run the following SQL commands in your Supabase SQL editor:

   ```sql
   -- User profiles table
   CREATE TABLE user_profiles (
     id UUID REFERENCES auth.users PRIMARY KEY,
     email TEXT NOT NULL,
     full_name TEXT,
     phone_number TEXT,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- Vehicle configurations table
   CREATE TABLE vehicle_configs (
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

   -- Daily entries table
   CREATE TABLE daily_entries (
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

   -- Create policies
   CREATE POLICY "Users can view own profile" ON user_profiles FOR SELECT USING (auth.uid() = id);
   CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (auth.uid() = id);
   CREATE POLICY "Users can insert own profile" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = id);

   CREATE POLICY "Users can manage own vehicle config" ON vehicle_configs FOR ALL USING (auth.uid() = user_id);
   CREATE POLICY "Users can manage own daily entries" ON daily_entries FOR ALL USING (auth.uid() = user_id);
   ```

5. **Add Google Sign-In (Optional)**
   - Configure Google Sign-In in your Supabase project
   - Add your Google OAuth credentials
   - Add the Google logo asset: `assets/images/google_logo.png`

6. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_profile.dart
│   ├── vehicle_config.dart
│   └── daily_entry.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── user_data_provider.dart
│   └── daily_entry_provider.dart
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   ├── onboarding/          # Setup and onboarding
│   ├── home/                # Main dashboard
│   ├── daily_entry/         # Entry management
│   ├── monthly_stats/       # Analytics and charts
│   └── settings/            # App settings
├── services/                # Backend services
│   └── database_service.dart
├── utils/                   # Utilities and constants
│   ├── constants.dart
│   └── theme.dart
└── widgets/                 # Reusable UI components
    ├── custom_button.dart
    └── custom_text_field.dart
```

## Key Features Explained

### Daily Entry Flow
1. User opens the app and sees today's status
2. Enters kilometers traveled for the day
3. App automatically calculates:
   - Revenue (kilometers × earnings per km)
   - Fuel cost (kilometers × fuel cost per km)
   - Daily EMI portion (monthly EMI ÷ 30)
   - Daily expenses portion (monthly expenses ÷ 30)
   - Net profit/loss

### Monthly Analytics
- Comprehensive monthly performance overview
- Interactive charts showing trends over time
- Comparison of revenue vs expenses
- Daily breakdown with detailed metrics

### Smart Configuration
- One-time setup of vehicle details
- Easy updates to fuel prices and rates
- Support for different vehicle types
- Flexible expense management

## Technologies Used

- **Flutter** - Cross-platform mobile development
- **Supabase** - Backend as a Service (Authentication, Database)
- **Provider** - State management
- **FL Chart** - Data visualization
- **Google Fonts** - Typography
- **Lucide Icons** - Modern icon set

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@profittracker.app or create an issue in this repository.

## Roadmap

- [ ] Expense categories and detailed tracking
- [ ] Multi-vehicle support for fleet owners
- [ ] Export data to PDF/Excel
- [ ] Fuel price alerts and recommendations
- [ ] Route optimization suggestions
- [ ] Driver management for fleet owners
- [ ] Integration with fuel station APIs
- [ ] Offline mode support
