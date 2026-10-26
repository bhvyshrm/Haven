import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class AuthLockService {
  static final AuthLockService instance = AuthLockService._internal();
  AuthLockService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    if (kIsWeb) return false;
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } catch (e) {
      debugPrint('Error checking biometric support: $e');
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Unlock Haven to access your private notes'}) async {
    if (kIsWeb) return true;
    try {
      final canAuth = await isDeviceSupported();
      if (!canAuth) return true;

      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    }
  }
}
