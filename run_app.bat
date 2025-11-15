@echo off
echo Starting ProfitTracker App...
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Flutter is not installed or not in PATH
    echo Please install Flutter through Android Studio first
    echo.
    echo Steps:
    echo 1. Open Android Studio
    echo 2. Go to File ^> Settings ^> Plugins
    echo 3. Install Flutter plugin
    echo 4. Restart Android Studio
    echo 5. Open this project folder in Android Studio
    pause
    exit /b 1
)

echo Flutter found! Getting dependencies...
flutter pub get

echo.
echo Starting the app...
echo Choose your platform:
echo 1. Web (Chrome)
echo 2. Android Emulator
echo.
set /p choice="Enter your choice (1 or 2): "

if "%choice%"=="1" (
    echo Starting web version...
    flutter run -d chrome
) else if "%choice%"=="2" (
    echo Starting Android version...
    flutter run
) else (
    echo Invalid choice. Starting web version by default...
    flutter run -d chrome
)

pause
