import '../../core/security/crypto_utils.dart';
import '../../features/security/domain/repositories/lock_repository.dart';
import '../datasources/local/lock_local_data_source.dart';

class LockRepositoryImpl implements LockRepository {
  const LockRepositoryImpl(this._localDataSource);

  final LockLocalDataSource _localDataSource;

  @override
  Future<bool> hasPin() {
    return _localDataSource.hasPinHash();
  }

  @override
  Future<void> setPin(String pin) async {
    if (!CryptoUtils.isValidPin(pin)) {
      throw ArgumentError.value(pin, 'pin', 'PIN must be exactly 4 digits');
    }

    final String hash = CryptoUtils.hashPin(pin);
    await _localDataSource.savePinHash(hash);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    if (!CryptoUtils.isValidPin(pin)) {
      return false;
    }

    final String? storedHash = await _localDataSource.readPinHash();
    if (storedHash == null || storedHash.isEmpty) {
      return false;
    }

    final String incomingHash = CryptoUtils.hashPin(pin);
    return storedHash == incomingHash;
  }

  @override
  Future<void> clearPin() {
    return _localDataSource.clearPinHash();
  }

  @override
  Future<bool> canUseBiometrics() {
    return _localDataSource.canUseBiometrics();
  }

  @override
  Future<bool> authenticateWithBiometrics() {
    return _localDataSource.authenticateWithBiometrics();
  }
}
