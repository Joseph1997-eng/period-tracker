import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._repository) : super(AppSettings.defaults) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    final AppSettings settings = await _repository.getSettings();
    state = settings;
  }

  Future<void> setDarkMode(bool enabled) async {
    final AppSettings updated = state.copyWith(isDarkMode: enabled);
    state = updated;
    await _repository.saveSettings(updated);
  }

  Future<void> setPrivacyLockEnabled(bool enabled) async {
    final AppSettings updated = state.copyWith(privacyLockEnabled: enabled);
    state = updated;
    await _repository.saveSettings(updated);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final AppSettings updated = state.copyWith(biometricEnabled: enabled);
    state = updated;
    await _repository.saveSettings(updated);
  }
}

final StateNotifierProvider<SettingsController, AppSettings>
settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>(
      (Ref ref) => SettingsController(ref.watch(settingsRepositoryProvider)),
    );
