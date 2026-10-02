enum AccountType { bank, creditCard, wallet, investment }

class AccountModel {
  final String id;
  final String name;
  final String institution;
  final AccountType type;
  final double balance;
  final String currency;
  final String accountNumberLast4;
  final DateTime lastSynced;
  final bool isActive;

  const AccountModel({
    required this.id,
    required this.name,
    required this.institution,
    required this.type,
    required this.balance,
    this.currency = 'INR',
    required this.accountNumberLast4,
    required this.lastSynced,
    this.isActive = true,
  });

  AccountModel copyWith({
    String? id,
    String? name,
    String? institution,
    AccountType? type,
    double? balance,
    String? currency,
    String? accountNumberLast4,
    DateTime? lastSynced,
    bool? isActive,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      institution: institution ?? this.institution,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      accountNumberLast4: accountNumberLast4 ?? this.accountNumberLast4,
      lastSynced: lastSynced ?? this.lastSynced,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'institution': institution,
        'type': type.name,
        'balance': balance,
        'currency': currency,
        'accountNumberLast4': accountNumberLast4,
        'lastSynced': lastSynced.toIso8601String(),
        'isActive': isActive,
      };

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        id: json['id'] as String,
        name: json['name'] as String,
        institution: json['institution'] as String,
        type: AccountType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => AccountType.bank,
        ),
        balance: (json['balance'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'INR',
        accountNumberLast4: json['accountNumberLast4'] as String? ?? '0000',
        lastSynced: DateTime.tryParse(json['lastSynced'] as String? ?? '') ??
            DateTime.now(),
        isActive: json['isActive'] as bool? ?? true,
      );
}
