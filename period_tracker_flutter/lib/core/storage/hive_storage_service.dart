import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/storage_keys.dart';

class HiveStorageService {
  const HiveStorageService._();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> initialize() async {
    await Hive.initFlutter();
    final Uint8List key = await _getOrCreateEncryptionKey();
    final HiveCipher cipher = HiveAesCipher(key);

    await Hive.openBox<dynamic>(
      StorageKeys.cyclesBox,
      encryptionCipher: cipher,
    );

    await Hive.openBox<dynamic>(
      StorageKeys.settingsBox,
      encryptionCipher: cipher,
    );
  }

  static Future<Uint8List> _getOrCreateEncryptionKey() async {
    final String? encoded = await _secureStorage.read(
      key: StorageKeys.secureHiveKey,
    );
    if (encoded != null && encoded.isNotEmpty) {
      return base64Url.decode(encoded);
    }

    final List<int> key = Hive.generateSecureKey();
    await _secureStorage.write(
      key: StorageKeys.secureHiveKey,
      value: base64UrlEncode(key),
    );

    return Uint8List.fromList(key);
  }
}
