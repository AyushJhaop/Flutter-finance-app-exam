import 'dart:async';
import 'dart:convert';
import '../models/user_model.dart';
import '../core/constants/constants.dart';
import 'secure_storage_service.dart';
import 'storage_service.dart';

/// Result wrapper for auth operations.
sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  final UserModel user;
  const AuthSuccess(this.user);
}

class AuthFailure extends AuthResult {
  final String message;
  const AuthFailure(this.message);
}

/// AuthService — mock implementation.
///
/// Provides a clean interface so a real backend (Firebase Auth, Supabase, etc.)
/// can be swapped in by replacing this class without touching the Provider or UI layers.
///
/// Security:
/// - Passwords are NEVER stored anywhere in this mock.
/// - Auth tokens are stored only in SecureStorage.
/// - Session state is derived from the presence of a valid token.
class AuthService {
  final SecureStorageService _secureStorage;
  final StorageService _storage;

  /// Mock "database" of registered users for the semester demo.
  /// In production, this is replaced by a real API call.
  final Map<String, _MockUserRecord> _mockDatabase = {
    'demo@fintrack.in': _MockUserRecord(
      id: 'usr_001',
      fullName: 'Arjun Sharma',
      email: 'demo@fintrack.in',
      hashedPassword: 'Demo@1234', // mock — no real hashing needed here
      isPremium: true,
      createdAt: DateTime(2026, 1, 15),
    ),
  };

  AuthService({
    required SecureStorageService secureStorage,
    required StorageService storage,
  })  : _secureStorage = secureStorage, // ignore: prefer_initializing_formals
        _storage = storage; // ignore: prefer_initializing_formals

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Simulate network latency
    await Future.delayed(AppConstants.mockDelay);

    final normalized = email.trim().toLowerCase();
    final record = _mockDatabase[normalized];

    if (record == null) {
      return const AuthFailure('No account found with this email.');
    }

    if (record.hashedPassword != password) {
      return const AuthFailure('Incorrect password. Please try again.');
    }

    final user = UserModel(
      id: record.id,
      fullName: record.fullName,
      email: record.email,
      isPremium: record.isPremium,
      createdAt: record.createdAt,
      lastLogin: DateTime.now(),
      biometricEnabled: _storage.biometricEnabled,
      notificationsEnabled: _storage.notificationsEnabled,
    );

    await _persistSession(user);
    return AuthSuccess(user);
  }

  // ─── Signup ───────────────────────────────────────────────────────────────

  Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future.delayed(AppConstants.mockDelay);

    final normalized = email.trim().toLowerCase();

    if (_mockDatabase.containsKey(normalized)) {
      return const AuthFailure('An account with this email already exists.');
    }

    final newId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final record = _MockUserRecord(
      id: newId,
      fullName: fullName.trim(),
      email: normalized,
      hashedPassword: password,
      isPremium: false,
      createdAt: DateTime.now(),
    );

    _mockDatabase[normalized] = record;

    final user = UserModel(
      id: record.id,
      fullName: record.fullName,
      email: record.email,
      isPremium: false,
      createdAt: record.createdAt,
      lastLogin: DateTime.now(),
    );

    await _persistSession(user);
    return AuthSuccess(user);
  }

  // ─── Session restore ──────────────────────────────────────────────────────

  Future<UserModel?> restoreSession() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) return null;

      // Decode the mock token (base64 encoded JSON)
      final payload = jsonDecode(
        utf8.decode(base64Decode(token)),
      ) as Map<String, dynamic>;

      return UserModel.fromJson(payload);
    } catch (_) {
      await _clearSession();
      return null;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _clearSession();
  }

  // ─── Internal helpers ─────────────────────────────────────────────────────

  Future<void> _persistSession(UserModel user) async {
    // Mock token = base64(userJson) — NOT a real JWT.
    final token = base64Encode(utf8.encode(jsonEncode(user.toJson())));
    await _secureStorage.saveAuthToken(token);
    await _secureStorage.saveUserEmail(user.email);
    await _storage.setUserId(user.id);
    if (user.isPremium) await _storage.setPremium(true);
  }

  Future<void> _clearSession() async {
    await _secureStorage.clearAll();
    await _storage.clearUserData();
  }
}

// Internal mock record — not exposed outside this file.
class _MockUserRecord {
  final String id;
  final String fullName;
  final String email;
  final String hashedPassword;
  final bool isPremium;
  final DateTime createdAt;

  const _MockUserRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.hashedPassword,
    required this.isPremium,
    required this.createdAt,
  });
}
