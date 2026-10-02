import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/storage_service.dart';

/// Auth state enum — drives navigation decisions.
enum AuthStatus {
  initial,      // App starting — unknown session state
  authenticated,
  unauthenticated,
  loading,
}

/// AuthProvider — single source of truth for authentication state.
///
/// Responsibilities:
/// - Login / Signup / Logout
/// - Session restoration on app launch
/// - Biometric authentication
/// - Exposes auth state to the entire widget tree
///
/// The UI reads state from this provider; it never calls AuthService directly.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final BiometricService _biometricService;
  final StorageService _storage;

  AuthProvider({
    required AuthService authService,
    required BiometricService biometricService,
    required StorageService storage,
  })  : _authService = authService, // ignore: prefer_initializing_formals
        _biometricService = biometricService, // ignore: prefer_initializing_formals
        _storage = storage; // ignore: prefer_initializing_formals

  // ─── State ────────────────────────────────────────────────────────────────

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;
  bool _biometricAvailable = false;

  // ─── Getters ──────────────────────────────────────────────────────────────

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get biometricAvailable => _biometricAvailable;
  bool get biometricEnabled => _storage.biometricEnabled;

  // ─── Initialization ───────────────────────────────────────────────────────

  /// Called once at app launch to restore any existing session.
  Future<void> initialize() async {
    try {
      _biometricAvailable = await _biometricService.isAvailable() &&
          await _biometricService.isEnrolled();
    } catch (_) {
      _biometricAvailable = false;
    }

    try {
      final restoredUser = await _authService.restoreSession();
      if (restoredUser != null) {
        _user = restoredUser.copyWith(lastLogin: DateTime.now());
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    final result = await _authService.login(email: email, password: password);

    switch (result) {
      case AuthSuccess(:final user):
        _user = user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        _setLoading(false);
        return true;

      case AuthFailure(:final message):
        _errorMessage = message;
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
    }
  }

  // ─── Signup ───────────────────────────────────────────────────────────────

  Future<bool> signup(String fullName, String email, String password) async {
    _setLoading(true);

    final result = await _authService.signup(
      fullName: fullName,
      email: email,
      password: password,
    );

    switch (result) {
      case AuthSuccess(:final user):
        _user = user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        _setLoading(false);
        return true;

      case AuthFailure(:final message):
        _errorMessage = message;
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
    }
  }

  // ─── Biometric login ──────────────────────────────────────────────────────

  Future<bool> loginWithBiometric() async {
    if (!_biometricAvailable || !biometricEnabled) return false;

    _setLoading(true);
    final authenticated = await _biometricService.authenticate(
      reason: 'Authenticate to access FinTrack',
    );

    if (authenticated) {
      // Attempt to restore session after biometric confirmation
      final restoredUser = await _authService.restoreSession();
      if (restoredUser != null) {
        _user = restoredUser.copyWith(lastLogin: DateTime.now());
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        _setLoading(false);
        return true;
      }
    }

    _errorMessage = 'Biometric authentication failed.';
    _setLoading(false);
    return false;
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    _setLoading(false);
  }

  // ─── Biometric toggle ─────────────────────────────────────────────────────

  Future<void> toggleBiometric(bool enable) async {
    if (enable && !_biometricAvailable) return;
    await _storage.setBiometricEnabled(enable);
    if (_user != null) {
      _user = _user!.copyWith(biometricEnabled: enable);
    }
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enable) => toggleBiometric(enable);

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
