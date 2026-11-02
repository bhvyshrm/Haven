import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthLockService {
  static final AuthLockService instance = AuthLockService._internal();
  AuthLockService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  static const _saltKey = 'haven_passcode_salt';
  static const _hashKey = 'haven_passcode_hash';

  Future<bool> isDeviceSupported() async {
    return isBiometricsSupported();
  }

  Future<bool> isBiometricsSupported() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (e) {
      debugPrint('Biometrics check error: $e');
      return false;
    }
  }

  Future<bool> authenticateBiometrics({
    String reason = 'Unlock Haven to access your private notes and journals',
  }) async {
    if (kIsWeb) return false;
    try {
      final canAuth = await isBiometricsSupported();
      if (!canAuth) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  Future<bool> authenticate({
    String reason = 'Unlock Haven to access your private notes',
  }) async {
    return authenticateBiometrics(reason: reason);
  }

  Future<bool> hasPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_hashKey) && prefs.containsKey(_saltKey);
  }

  Future<bool> setPasscode(String passcode) async {
    if (passcode.length < 4) return false;
    final prefs = await SharedPreferences.getInstance();
    final salt = const Uuid().v4();
    final hash = _hashPasscode(passcode, salt);
    await prefs.setString(_saltKey, salt);
    await prefs.setString(_hashKey, hash);
    return true;
  }

  Future<bool> verifyPasscode(String passcode) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_saltKey);
    final storedHash = prefs.getString(_hashKey);
    if (salt == null || storedHash == null) return false;
    final computedHash = _hashPasscode(passcode, salt);
    return computedHash == storedHash;
  }

  Future<void> removePasscode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saltKey);
    await prefs.remove(_hashKey);
  }

  String _hashPasscode(String passcode, String salt) {
    final bytes = utf8.encode('$salt:$passcode');
    return sha256.convert(bytes).toString();
  }
}
