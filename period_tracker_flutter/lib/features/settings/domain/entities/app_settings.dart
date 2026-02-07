class AppSettings {
  const AppSettings({
    required this.isDarkMode,
    required this.privacyLockEnabled,
    required this.biometricEnabled,
  });

  final bool isDarkMode;
  final bool privacyLockEnabled;
  final bool biometricEnabled;

  static const AppSettings defaults = AppSettings(
    isDarkMode: false,
    privacyLockEnabled: false,
    biometricEnabled: true,
  );

  AppSettings copyWith({
    bool? isDarkMode,
    bool? privacyLockEnabled,
    bool? biometricEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      privacyLockEnabled: privacyLockEnabled ?? this.privacyLockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
