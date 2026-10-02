import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/constants.dart';

/// StorageService — wraps SharedPreferences for non-sensitive data.
/// Sensitive data (auth tokens) must use SecureStorageService instead.
class StorageService {
  StorageService._();

  static StorageService? _instance;
  static SharedPreferences? _prefs;

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  SharedPreferences get _p => _prefs!;

  // ─── Onboarding ──────────────────────────────────────────────────────────

  bool get onboardingDone => _p.getBool(AppConstants.keyOnboardingDone) ?? false;
  Future<void> setOnboardingDone() =>
      _p.setBool(AppConstants.keyOnboardingDone, true);

  // ─── User ID (non-sensitive identifier) ─────────────────────────────────

  String? get userId => _p.getString(AppConstants.keyUserId);
  Future<void> setUserId(String id) => _p.setString(AppConstants.keyUserId, id);

  // ─── Biometric preference ────────────────────────────────────────────────

  bool get biometricEnabled => _p.getBool(AppConstants.keyBiometricEnabled) ?? false;
  Future<void> setBiometricEnabled(bool value) =>
      _p.setBool(AppConstants.keyBiometricEnabled, value);

  // ─── Premium ─────────────────────────────────────────────────────────────

  bool get isPremium => _p.getBool(AppConstants.keyPremium) ?? false;
  Future<void> setPremium(bool value) => _p.setBool(AppConstants.keyPremium, value);

  // ─── Notifications ───────────────────────────────────────────────────────

  bool get notificationsEnabled =>
      _p.getBool(AppConstants.keyNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool value) =>
      _p.setBool(AppConstants.keyNotificationsEnabled, value);

  // ─── Last synced timestamp ───────────────────────────────────────────────

  DateTime? get lastSynced {
    final raw = _p.getString(AppConstants.keyLastSynced);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  Future<void> setLastSynced(DateTime dt) =>
      _p.setString(AppConstants.keyLastSynced, dt.toIso8601String());

  // ─── Offline cache (stores JSON strings) ────────────────────────────────

  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    await _p.setString(key, jsonEncode(data));
  }

  Map<String, dynamic>? getCachedData(String key) {
    final raw = _p.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ─── Generic helpers ─────────────────────────────────────────────────────

  Future<void> setString(String key, String value) => _p.setString(key, value);
  String? getString(String key) => _p.getString(key);

  Future<void> setBool(String key, bool value) => _p.setBool(key, value);
  bool? getBool(String key) => _p.getBool(key);

  /// Clear all non-sensitive preferences — called on logout.
  Future<void> clearUserData() async {
    await _p.remove(AppConstants.keyUserId);
    await _p.remove(AppConstants.keyBiometricEnabled);
    await _p.remove(AppConstants.keyPremium);
    await _p.remove(AppConstants.keyLastSynced);
    await _p.remove(AppConstants.keyOfflineCache);
    // Keep onboarding flag so the user doesn't see onboarding again.
  }
}
