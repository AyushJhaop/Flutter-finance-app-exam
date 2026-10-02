import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/constants.dart';

/// SecureStorageService — wraps FlutterSecureStorage.
/// Only sensitive values (auth tokens, keys) go here.
/// Non-sensitive preferences use StorageService instead.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  // ─── Auth Token ──────────────────────────────────────────────────────────

  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: AppConstants.secureKeyAuthToken, value: token);
    } catch (_) {}
  }

  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: AppConstants.secureKeyAuthToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: AppConstants.secureKeyAuthToken);
    } catch (_) {}
  }

  // ─── User Email (for biometric re-auth display) ───────────────────────────

  Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: AppConstants.secureKeyUserEmail, value: email);
    } catch (_) {}
  }

  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: AppConstants.secureKeyUserEmail);
    } catch (_) {
      return null;
    }
  }

  // ─── Generic helpers ─────────────────────────────────────────────────────

  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  /// Clear all secure storage — called on logout.
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }

  // ─── Convenience: store JSON objects ─────────────────────────────────────

  Future<void> writeJson(String key, Map<String, dynamic> data) async {
    await _storage.write(key: key, value: jsonEncode(data));
  }

  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
