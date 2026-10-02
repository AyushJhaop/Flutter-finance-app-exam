import 'package:local_auth/local_auth.dart';

/// BiometricService — abstracts local_auth for biometric authentication.
/// Designed to fail gracefully: returns false instead of throwing.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the device supports biometric authentication.
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Whether biometric hardware (fingerprint/face) is enrolled.
  Future<bool> isEnrolled() async {
    try {
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Supported biometric types on this device.
  Future<List<BiometricType>> supportedTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Prompt biometric authentication.
  /// Returns true if authenticated, false if cancelled or failed.
  /// [reason] is the localised reason shown to the user.
  Future<bool> authenticate({
    String reason = 'Authenticate to access FinTrack',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN as fallback
          stickyAuth: true,     // keep prompt alive on backgrounding
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Cancel any pending authentication.
  Future<void> cancelAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (_) {
      // Ignore
    }
  }
}
