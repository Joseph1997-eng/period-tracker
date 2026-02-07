import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/constants/storage_keys.dart';

class LockLocalDataSource {
  const LockLocalDataSource({
    required FlutterSecureStorage secureStorage,
    required LocalAuthentication localAuthentication,
  }) : _secureStorage = secureStorage,
       _localAuthentication = localAuthentication;

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuthentication;

  Future<bool> hasPinHash() async {
    final String? hash = await _secureStorage.read(
      key: StorageKeys.securePinHash,
    );
    return hash != null && hash.isNotEmpty;
  }

  Future<String?> readPinHash() {
    return _secureStorage.read(key: StorageKeys.securePinHash);
  }

  Future<void> savePinHash(String hash) {
    return _secureStorage.write(key: StorageKeys.securePinHash, value: hash);
  }

  Future<void> clearPinHash() {
    return _secureStorage.delete(key: StorageKeys.securePinHash);
  }

  Future<bool> canUseBiometrics() async {
    try {
      final bool canCheck = await _localAuthentication.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuthentication
          .isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return _localAuthentication.authenticate(
        localizedReason: 'Unlock your period tracker',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
