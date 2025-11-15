# ProfitTracker Setup Guide

## Quick Start

### 1. Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Supabase account (free tier available)

### 2. Clone and Install Dependencies
```bash
git clone <your-repo-url>
cd transport-profit-tracker
flutter pub get
```

### 3. Supabase Setup

#### Create Supabase Project
1. Go to [supabase.com](https://supabase.com) and create a new project
2. Wait for the project to be fully initialized
3. Go to Settings > API to find your project URL and anon key

#### Configure Database
1. In your Supabase dashboard, go to the SQL Editor
2. Copy and paste the contents of `setup_supabase.sql`
3. Click "Run" to execute the script
4. Verify tables are created in the Table Editor

#### Update App Configuration
1. Open `lib/utils/constants.dart`
2. Replace the placeholder values:
```dart
static const String supabaseUrl = 'https://your-project-id.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

### 4. Google Sign-In Setup (Optional)

#### Configure in Supabase
1. Go to Authentication > Providers in your Supabase dashboard
2. Enable Google provider
3. Add your Google OAuth credentials

#### Get Google OAuth Credentials
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing one
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add your app's package name and SHA-1 fingerprint

#### Add Google Logo
1. Download Google logo PNG (20x20px recommended)
2. Place it at `assets/images/google_logo.png`

### 5. Run the App
```bash
flutter run
```

## Project Structure Overview

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (User, Vehicle, DailyEntry)
├── providers/                # State management (Auth, UserData, DailyEntry)
├── screens/                  # All UI screens organized by feature
├── services/                 # Backend services (Database operations)
├── utils/                    # Constants and theme configuration
└── widgets/                  # Reusable UI components
```

## Key Features

### Authentication Flow
- Email/password registration and login
- Google OAuth integration
- Secure session management with Supabase

### Vehicle Configuration
- One-time setup during onboarding
- Support for multiple vehicle types
- Configurable earnings, mileage, and expenses

### Daily Entry System
- Simple kilometer input
- Automatic profit/loss calculation
- Real-time financial breakdown

### Analytics Dashboard
- Monthly performance overview
- Interactive charts and graphs
- Detailed daily breakdowns

## Customization Options

### Theme Colors
Edit `lib/utils/theme.dart` to customize:
- Primary and secondary colors
- Gradient schemes
- Text colors and typography

### Vehicle Types
Add new vehicle types in:
- `lib/screens/onboarding/vehicle_setup_screen.dart`
- `lib/screens/settings/settings_screen.dart`

### Default Values
Modify default values in `lib/utils/constants.dart`:
- Default fuel price
- Default mileage
- Default earnings per km

## Troubleshooting

### Common Issues

#### Supabase Connection Error
- Verify URL and anon key are correct
- Check if RLS policies are properly set up
- Ensure tables exist in database

#### Google Sign-In Not Working
- Verify OAuth credentials are correct
- Check package name matches in Google Console
- Ensure SHA-1 fingerprint is added

#### Build Errors
- Run `flutter clean && flutter pub get`
- Check Flutter and Dart SDK versions
- Verify all dependencies are compatible

### Debug Mode
Enable debug logging by setting:
```dart
// In main.dart
debugPrint('Debug message here');
```

## Deployment

### Android
1. Generate signed APK:
```bash
flutter build apk --release
```

2. For Play Store:
```bash
flutter build appbundle --release
```

### iOS
1. Build for iOS:
```bash
flutter build ios --release
```

2. Open `ios/Runner.xcworkspace` in Xcode for App Store submission

## Support

For issues and questions:
1. Check this setup guide
2. Review the main README.md
3. Create an issue in the repository
4. Contact support at support@profittracker.app

## Next Steps

After successful setup:
1. Test the complete user flow
2. Customize branding and colors
3. Add your own vehicle types if needed
4. Configure analytics and monitoring
5. Prepare for deployment

Happy coding! 🚛📊
