# PHASE 5: DEPLOYMENT & BUILD GUIDE

## Build Configuration Overview

This guide covers the complete build and deployment process for the Period Tracker Android App.

---

## 1. BUILD.GRADLE CONFIGURATION

### **Current Dependencies:**
```gradle
dependencies {
    // AndroidX Libraries
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.cardview:cardview:1.0.0'
    
    // Security (Encrypted SharedPreferences)
    implementation 'androidx.security:security-crypto:1.1.0-alpha06'
    
    // Testing
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
```

### **Compile & Target SDK Settings:**
```gradle
android {
    compileSdk 33
    
    defaultConfig {
        applicationId "com.example.periodtracker"
        minSdk 21              // Support Android 5.0 (API 21) and above
        targetSdk 33           // Target Android 13
        versionCode 1
        versionName "1.0"
        
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
}
```

### **Build Types:**
```gradle
buildTypes {
    release {
        minifyEnabled false                    // Code shrinking disabled for clarity
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

---

## 2. ANDROIDMANIFEST.XML KEY CONFIGURATIONS

### **Permissions:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### **Application Configuration:**
```xml
<application
    android:allowBackup="true"
    android:icon="@mipmap/ic_launcher"
    android:label="@string/app_name"
    android:theme="@style/Theme.AppCompat.Light.DarkActionBar"
    android:usesCleartextTraffic="false">
    
    <activity
        android:name=".MainActivity"
        android:exported="true"
        android:screenOrientation="portrait"
        android:label="@string/app_name">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
    </activity>
</application>
```

### **Key Points:**
- ✅ `android:exported="true"` - Required for API 31+ to declare app launcher
- ✅ `android:screenOrientation="portrait"` - Lock screen to portrait mode
- ✅ `android:usesCleartextTraffic="false"` - Enforce HTTPS for data privacy
- ✅ Permissions included for future extensibility

---

## 3. BUILDING THE APK

### **Step 1: Clean the Build**
```bash
./gradlew clean
```

### **Step 2: Assemble Debug APK**
```bash
./gradlew assembleDebug
```
**Output Location:** `app/build/outputs/apk/debug/app-debug.apk`

### **Step 3: Assemble Release APK (Without Signing)**
```bash
./gradlew assembleRelease
```

### **Step 4: Build and Run on Device/Emulator**
```bash
./gradlew installDebug
```

### **Step 5: Run Unit Tests**
```bash
./gradlew test
```

---

## 4. RELEASE APK SIGNING

### **Step A: Create a Keystore (One-time)**
```bash
keytool -genkey -v -keystore my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias
```

**You will be prompted for:**
- Keystore password
- Key password
- Your name, organization, etc.

### **Step B: Configure Gradle with Signing Credentials**

Create or update `app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            storeFile file('path/to/my-release-key.jks')
            storePassword 'your_keystore_password'
            keyAlias 'my-key-alias'
            keyPassword 'your_key_password'
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### **Step C: Build Signed Release APK**
```bash
./gradlew assembleRelease
```

**Output:** `app/build/outputs/apk/release/app-release.apk`

---

## 5. GRADLE BUILD COMMANDS SUMMARY

| Command | Purpose |
|---------|---------|
| `./gradlew clean` | Remove all build outputs |
| `./gradlew build` | Full build (debug + release) |
| `./gradlew assembleDebug` | Build debug APK |
| `./gradlew assembleRelease` | Build signed release APK |
| `./gradlew installDebug` | Install debug APK to device |
| `./gradlew uninstallDebug` | Uninstall debug app |
| `./gradlew test` | Run unit tests |
| `./gradlew connectedAndroidTest` | Run instrumentation tests on device |

---

## 6. VERSION MANAGEMENT

### **Update Version in build.gradle:**
```gradle
defaultConfig {
    versionCode 2          // Increment for Play Store
    versionName "1.1.0"    // Semantic versioning (major.minor.patch)
}
```

**Rules:**
- `versionCode`: Auto-incrementing integer (required for Play Store updates)
- `versionName`: User-visible version string

---

## 7. PROGUARD/R8 CODE SHRINKING (Advanced)

### **When to Enable:**
- For release builds to reduce APK size
- To obfuscate sensitive code

### **Configuration in build.gradle:**
```gradle
buildTypes {
    release {
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### **Custom ProGuard Rules (app/proguard-rules.pro):**
```proguard
# Keep Period Tracker classes
-keep class com.example.periodtracker.** { *; }

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
```

---

## 8. UPLOADING TO GOOGLE PLAY STORE

### **Prerequisites:**
1. ✅ Google Play Developer Account ($25 one-time fee)
2. ✅ Signed release APK or Android App Bundle (AAB)
3. ✅ App icon (512x512 px)
4. ✅ Screenshots (at least 2)
5. ✅ App description, privacy policy, etc.

### **Steps:**
1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app → Fill app details
3. Navigate to **Release** → **Production**
4. Click **Create release** → Upload signed APK/AAB
5. Review app details, pricing, content rating
6. Submit for review (typically takes 2-3 hours)

### **Building Android App Bundle (AAB):**
```bash
./gradlew bundleRelease
```
**Output:** `app/build/outputs/bundle/release/app-release.aab`

---

## 9. LOCAL TESTING & DEBUGGING

### **Test on Android Emulator:**
```bash
# Start emulator
emulator -avd Pixel_4_API_33

# Build and run
./gradlew installDebug
```

### **Test on Physical Device:**
1. Enable Developer Options: Settings → About Phone → Tap Build Number 7x
2. Enable USB Debugging
3. Connect via USB
4. Run: `./gradlew installDebug`

### **View Logs:**
```bash
adb logcat com.example.periodtracker:V
```

---

## 10. CRASH REPORTING & ANALYTICS

### **Recommended Tools:**
- **Firebase Crashlytics** - Crash reporting
- **Firebase Analytics** - User behavior tracking
- **Firebase Remote Config** - A/B testing

### **Add Firebase to build.gradle:**
```gradle
dependencies {
    implementation 'com.google.firebase:firebase-crashlytics:18.3.7'
    implementation 'com.google.firebase:firebase-analytics:21.2.2'
}

plugins {
    id 'com.google.gms.google-services'
    id 'com.google.firebase.crashlytics'
}
```

---

## 11. DATA PRIVACY & SECURITY COMPLIANCE

### **GDPR & Privacy Policy:**
✅ **Period Tracker uses:**
- Local-only data storage (no cloud sync)
- Encrypted SharedPreferences
- No user tracking or analytics
- No third-party data sharing

### **Manifest Security Settings:**
```xml
android:usesCleartextTraffic="false"    <!-- Enforce HTTPS only -->
```

### **Sensitive Data Protection:**
```java
// DataStorage uses encrypted SharedPreferences
EncryptedSharedPreferences.create(...)
```

---

## 12. TROUBLESHOOTING BUILD ERRORS

| Error | Solution |
|-------|----------|
| `SDK not installed` | Download SDK via Android Studio SDK Manager |
| `Gradle sync failed` | Run `./gradlew --refresh-dependencies` |
| `Signing key not found` | Check keystore path in build.gradle |
| `APK won't install` | Check minSdk compatibility with device |
| `Out of memory` | Increase Gradle heap: `org.gradle.jvmargs=-Xmx2048m` |

---

## 13. CONTINUOUS INTEGRATION/DEPLOYMENT (CI/CD)

### **GitHub Actions Example:**
```yaml
name: Build APK

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-java@v2
        with:
          java-version: '11'
      - run: chmod +x gradlew
      - run: ./gradlew assembleDebug
      - uses: actions/upload-artifact@v2
        with:
          name: app-debug.apk
          path: app/build/outputs/apk/debug/app-debug.apk
```

---

## 14. PERFORMANCE OPTIMIZATION

### **APK Size Reduction:**
- Enable ProGuard/R8 minification
- Use App Bundle instead of APK
- Compress resources

### **Runtime Performance:**
- Avoid main thread blocking
- Use WorkManager for background tasks
- Profile with Android Profiler

---

## 15. RELEASE CHECKLIST

- [ ] All unit tests pass: `./gradlew test`
- [ ] Instrumentation tests pass: `./gradlew connectedAndroidTest`
- [ ] Release notes prepared
- [ ] Version code incremented in build.gradle
- [ ] ProGuard rules reviewed
- [ ] Privacy policy reviewed
- [ ] All required resources (icon, screenshots) ready
- [ ] APK signed with release keystore
- [ ] APK tested on multiple devices/SDK versions
- [ ] Crash reporting integrated
- [ ] Analytics enabled (optional)

---

## SUMMARY

The Period Tracker app uses:
- **Gradle Build System** for automated compilation
- **Android SDK 21-33** for broad device compatibility
- **Encrypted Storage** for data privacy
- **Material Design** for modern UI
- **Comprehensive Testing** with JUnit

Following this guide ensures a professional, production-ready app release! 🚀
