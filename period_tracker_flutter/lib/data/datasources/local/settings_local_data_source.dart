import 'package:hive/hive.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../features/settings/domain/entities/app_settings.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._box);

  final Box<dynamic> _box;

  Future<AppSettings> getSettings() async {
    return AppSettings(
      isDarkMode:
          (_box.get(StorageKeys.darkMode) as bool?) ??
          AppSettings.defaults.isDarkMode,
      privacyLockEnabled:
          (_box.get(StorageKeys.privacyLockEnabled) as bool?) ??
          AppSettings.defaults.privacyLockEnabled,
      biometricEnabled:
          (_box.get(StorageKeys.biometricEnabled) as bool?) ??
          AppSettings.defaults.biometricEnabled,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put(StorageKeys.darkMode, settings.isDarkMode);
    await _box.put(StorageKeys.privacyLockEnabled, settings.privacyLockEnabled);
    await _box.put(StorageKeys.biometricEnabled, settings.biometricEnabled);
  }
}
