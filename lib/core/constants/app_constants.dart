/// String constants — app name, version info, keys.
class AppConstants {
  AppConstants._();

  static const String appName = 'FinTrack';
  static const String appTagline = 'Your Financial Command Centre';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys (non-sensitive)
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLastSynced = 'last_synced';
  static const String keyOfflineCache = 'offline_cache';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyPremium = 'is_premium';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // Secure storage keys
  static const String secureKeyAuthToken = 'auth_token';
  static const String secureKeyUserEmail = 'user_email';

  // Budget alert thresholds
  static const double budgetWarningThreshold = 0.80;
  static const double budgetDangerThreshold = 0.90;
  static const double budgetExceededThreshold = 1.00;

  // Mock API simulated latency
  static const Duration mockDelay = Duration(milliseconds: 600);
}
