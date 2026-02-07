import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../domain/repositories/lock_repository.dart';

class LockState {
  const LockState({
    required this.isInitializing,
    required this.isUnlocked,
    required this.hasPinConfigured,
    required this.biometricsAvailable,
    required this.failedAttempts,
    required this.errorMessage,
  });

  final bool isInitializing;
  final bool isUnlocked;
  final bool hasPinConfigured;
  final bool biometricsAvailable;
  final int failedAttempts;
  final String? errorMessage;

  static const LockState initial = LockState(
    isInitializing: true,
    isUnlocked: false,
    hasPinConfigured: false,
    biometricsAvailable: false,
    failedAttempts: 0,
    errorMessage: null,
  );

  LockState copyWith({
    bool? isInitializing,
    bool? isUnlocked,
    bool? hasPinConfigured,
    bool? biometricsAvailable,
    int? failedAttempts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LockState(
      isInitializing: isInitializing ?? this.isInitializing,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      hasPinConfigured: hasPinConfigured ?? this.hasPinConfigured,
      biometricsAvailable: biometricsAvailable ?? this.biometricsAvailable,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LockController extends StateNotifier<LockState> {
  LockController(this._repository) : super(LockState.initial);

  final LockRepository _repository;

  Future<void> initialize({
    required bool lockEnabled,
    required bool biometricEnabled,
  }) async {
    state = state.copyWith(isInitializing: true, clearError: true);

    final bool hasPin = await _repository.hasPin();
    final bool biometricsAvailable = await _repository.canUseBiometrics();

    if (!lockEnabled || !hasPin) {
      state = state.copyWith(
        isInitializing: false,
        isUnlocked: true,
        hasPinConfigured: hasPin,
        biometricsAvailable: biometricsAvailable,
        failedAttempts: 0,
        clearError: true,
      );
      return;
    }

    if (biometricEnabled && biometricsAvailable) {
      final bool authenticated = await _repository.authenticateWithBiometrics();
      state = state.copyWith(
        isInitializing: false,
        isUnlocked: authenticated,
        hasPinConfigured: hasPin,
        biometricsAvailable: biometricsAvailable,
        failedAttempts: authenticated ? 0 : state.failedAttempts,
        errorMessage: authenticated
            ? null
            : 'Biometric unlock was cancelled or failed.',
      );
      return;
    }

    state = state.copyWith(
      isInitializing: false,
      isUnlocked: false,
      hasPinConfigured: hasPin,
      biometricsAvailable: biometricsAvailable,
      failedAttempts: 0,
      clearError: true,
    );
  }

  Future<void> lockIfNeeded({required bool lockEnabled}) async {
    if (!lockEnabled) {
      return;
    }

    final bool hasPin = await _repository.hasPin();
    if (!hasPin) {
      return;
    }

    state = state.copyWith(
      isUnlocked: false,
      hasPinConfigured: true,
      failedAttempts: 0,
      clearError: true,
    );
  }

  Future<bool> authenticateWithBiometrics() async {
    final bool success = await _repository.authenticateWithBiometrics();
    if (success) {
      state = state.copyWith(
        isUnlocked: true,
        failedAttempts: 0,
        clearError: true,
      );
      return true;
    }

    state = state.copyWith(errorMessage: 'Biometric authentication failed.');
    return false;
  }

  Future<bool> unlockWithPin(String pin) async {
    final bool success = await _repository.verifyPin(pin);
    if (success) {
      state = state.copyWith(
        isUnlocked: true,
        failedAttempts: 0,
        clearError: true,
      );
      return true;
    }

    final int attempts = state.failedAttempts + 1;
    state = state.copyWith(
      failedAttempts: attempts,
      errorMessage: 'Invalid PIN. Attempt $attempts.',
    );
    return false;
  }

  Future<void> setPin(String pin) async {
    await _repository.setPin(pin);
    state = state.copyWith(
      hasPinConfigured: true,
      isUnlocked: true,
      failedAttempts: 0,
      clearError: true,
    );
  }

  Future<void> clearPin() async {
    await _repository.clearPin();
    state = state.copyWith(
      hasPinConfigured: false,
      isUnlocked: true,
      failedAttempts: 0,
      clearError: true,
    );
  }
}

final StateNotifierProvider<LockController, LockState> lockControllerProvider =
    StateNotifierProvider<LockController, LockState>(
      (Ref ref) => LockController(ref.watch(lockRepositoryProvider)),
    );
