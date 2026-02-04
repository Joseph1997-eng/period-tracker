# Period Tracker Android App

A simple and elegant Android application to track menstrual cycles and predict fertile windows.

## Features

- **Date Selection**: Choose your last period start date using an intuitive DatePicker
- **Period Prediction**: Automatically calculates the next period date based on a 28-day cycle
- **Fertile Window Calculation**: Determines the ovulation window (14 days before next period) and fertile days (5 days before to 1 day after ovulation)
- **Clean UI**: Modern Material Design interface with CardView components

## Technical Details

### Files Included

1. **MainActivity.java** - Main application logic
   - Date manipulation using `java.util.Calendar`
   - Period cycle calculations (28-day cycle)
   - Ovulation and fertile window predictions
   
2. **activity_main.xml** - UI layout
   - DatePicker for date selection
   - Predict button
   - CardView for displaying results
   - Color-coded sections for different information
   
3. **button_background.xml** - Custom button drawable
   - Rounded corners
   - Pink theme color (#D81B60)
   
4. **AndroidManifest.xml** - App configuration
5. **build.gradle** - Dependencies and build configuration

### Calculation Logic

- **Cycle Length**: 28 days (average)
- **Next Period**: Last period date + 28 days
- **Ovulation**: 14 days before next period
- **Fertile Window**: 5 days before ovulation to 1 day after ovulation

### Requirements

- **Minimum SDK**: API 21 (Android 5.0 Lollipop)
- **Target SDK**: API 33 (Android 13)
- **Compile SDK**: API 33

### Dependencies

- AndroidX AppCompat
- Material Design Components
- CardView
- ConstraintLayout

## Setup Instructions

1. Create a new Android project in Android Studio or Antigravity IDE
2. Replace/add the provided files to your project:
   - `MainActivity.java` → `app/src/main/java/com/example/periodtracker/`
   - `activity_main.xml` → `app/src/main/res/layout/`
   - `button_background.xml` → `app/src/main/res/drawable/`
   - `AndroidManifest.xml` → `app/src/main/`
   - `build.gradle` → `app/`
3. Sync Gradle files
4. Run the application on an emulator or physical device

## Usage

1. Launch the app
2. Select your last period start date using the DatePicker
3. Tap the "Predict Next Period" button
4. View your predictions:
   - Next period date
   - Fertile window dates

## Notes

- This app uses a standard 28-day cycle for calculations
- For more accurate predictions, consider tracking multiple cycles
- Consult healthcare professionals for medical advice

## License

This is a sample educational project.
