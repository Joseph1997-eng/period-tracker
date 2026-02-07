import 'dart:convert';

import 'package:crypto/crypto.dart';

class CryptoUtils {
  const CryptoUtils._();

  static String hashPin(String pin) {
    final Digest digest = sha256.convert(utf8.encode(pin));
    return digest.toString();
  }

  static bool isValidPin(String pin) {
    final RegExp pinRegex = RegExp(r'^\d{4}$');
    return pinRegex.hasMatch(pin);
  }
}
