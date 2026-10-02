/// User model for FinTrack.
/// Stores non-sensitive profile information only.
/// Authentication tokens are NEVER stored in this model — they live in SecureStorage.
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool biometricEnabled;
  final bool notificationsEnabled;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.isPremium = false,
    required this.createdAt,
    this.lastLogin,
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
  });

  /// Initials for avatar display
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.substring(0, fullName.length.clamp(0, 2)).toUpperCase();
  }

  /// First name only
  String get firstName {
    return fullName.trim().split(' ').first;
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? biometricEnabled,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'isPremium': isPremium,
        'createdAt': createdAt.toIso8601String(),
        'lastLogin': lastLogin?.toIso8601String(),
        'biometricEnabled': biometricEnabled,
        'notificationsEnabled': notificationsEnabled,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        isPremium: json['isPremium'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastLogin: json['lastLogin'] != null
            ? DateTime.parse(json['lastLogin'] as String)
            : null,
        biometricEnabled: json['biometricEnabled'] as bool? ?? false,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, email: $email, isPremium: $isPremium)';
}
