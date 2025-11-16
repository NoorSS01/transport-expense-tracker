@echo off
echo Setting up GitHub remote and pushing ProfitTracker...
echo.
echo INSTRUCTIONS:
echo 1. Go to github.com and create a new repository
echo 2. Copy the repository URL (e.g., https://github.com/yourusername/transport-profit-tracker.git)
echo 3. Enter it below when prompted
echo.

set /p repo_url="Enter your GitHub repository URL: "

if "%repo_url%"=="" (
    echo No URL provided. Exiting...
    pause
    exit /b 1
)

echo.
echo Adding remote origin...
git remote add origin %repo_url%

echo.
echo Pushing to GitHub...
git branch -M main
git push -u origin main

echo.
echo ✅ Successfully pushed to GitHub!
echo Your ProfitTracker app is now available at: %repo_url%
echo.
pause
