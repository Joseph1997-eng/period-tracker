# Android SDK Setup Script for VS Code
# Run this script to configure Android SDK

Write-Host "🚀 Android SDK Setup for VS Code" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Create SDK directories
Write-Host "📁 Creating Android SDK directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\Android\cmdline-tools\latest" -Force | Out-Null
New-Item -ItemType Directory -Path "C:\Android\platforms" -Force | Out-Null
New-Item -ItemType Directory -Path "C:\Android\build-tools" -Force | Out-Null
New-Item -ItemType Directory -Path "C:\Android\platform-tools" -Force | Out-Null
Write-Host "✅ Directories created" -ForegroundColor Green

# Set environment variables
Write-Host "🔧 Setting environment variables..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "C:\Android", "User")
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Android", "User")

$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if (-not $currentPath.Contains("C:\Android")) {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;C:\Android\cmdline-tools\latest\bin;C:\Android\platform-tools", "User")
}

# Refresh environment for current session
$env:ANDROID_SDK_ROOT = "C:\Android"
$env:ANDROID_HOME = "C:\Android"
$env:PATH = "$env:PATH;C:\Android\cmdline-tools\latest\bin;C:\Android\platform-tools"

Write-Host "✅ Environment variables set" -ForegroundColor Green
Write-Host ""

# Display instructions
Write-Host "📝 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Download Command-Line Tools (Windows) from:"
Write-Host "   https://developer.android.com/studio/command-line-tools"
Write-Host ""
Write-Host "2. Extract to: C:\Android\cmdline-tools\latest"
Write-Host ""
Write-Host "3. Run these commands in PowerShell:"
Write-Host "   echo 'y' | & 'C:\Android\cmdline-tools\latest\bin\sdkmanager.bat' --licenses"
Write-Host "   & 'C:\Android\cmdline-tools\latest\bin\sdkmanager.bat' 'platforms;android-33'"
Write-Host "   & 'C:\Android\cmdline-tools\latest\bin\sdkmanager.bat' 'build-tools;33.0.2'"
Write-Host ""
Write-Host "4. Restart VS Code"
Write-Host ""
Write-Host "✅ Setup script complete!" -ForegroundColor Green
