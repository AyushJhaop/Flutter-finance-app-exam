class SavingsGoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String? notes;
  final DateTime createdAt;
  final int colorValue;

  const SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.notes,
    required this.createdAt,
    this.colorValue = 0xFF00D4AA,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get progressPercentage => (progress * 100).clamp(0.0, 100.0);

  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  bool get isCompleted => currentAmount >= targetAmount;

  int get daysRemaining =>
      deadline.difference(DateTime.now()).inDays.clamp(0, 9999);

  SavingsGoalModel copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? notes,
    DateTime? createdAt,
    int? colorValue,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'deadline': deadline.toIso8601String(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'colorValue': colorValue,
      };

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) =>
      SavingsGoalModel(
        id: json['id'] as String,
        title: json['title'] as String,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        currentAmount: (json['currentAmount'] as num).toDouble(),
        deadline: DateTime.tryParse(json['deadline'] as String? ?? '') ??
            DateTime.now().add(const Duration(days: 90)),
        notes: json['notes'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        colorValue: json['colorValue'] as int? ?? 0xFF00D4AA,
      );
}
