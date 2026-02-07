# Keep Flutter entrypoints and plugin registrants
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Hive model maps and reflection-safe classes
-keep class com.example.period_tracker_flutter.** { *; }
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit

# Play Core (SplitCompat / deferred components)
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.**
