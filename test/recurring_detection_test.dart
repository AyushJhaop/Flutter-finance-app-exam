import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/models/transaction_model.dart';
import 'package:fintrack/models/recurring_payment_model.dart';
import 'package:fintrack/services/recurring_detection_service.dart';

void main() {
  late RecurringDetectionService service;

  setUp(() {
    service = RecurringDetectionService();
  });

  group('RecurringDetectionService', () {
    test('detects monthly recurring subscription from repeated transactions', () {
      final now = DateTime.now();

      final transactions = [
        TransactionModel(
          id: 'tx_sub_1',
          merchant: 'Netflix Subscription',
          amount: 649.0,
          category: TransactionCategory.entertainment,
          accountId: 'acc_1',
          date: now.subtract(const Duration(days: 60)),
          type: TransactionType.expense,
        ),
        TransactionModel(
          id: 'tx_sub_2',
          merchant: 'Netflix Subscription',
          amount: 649.0,
          category: TransactionCategory.entertainment,
          accountId: 'acc_1',
          date: now.subtract(const Duration(days: 30)),
          type: TransactionType.expense,
        ),
        TransactionModel(
          id: 'tx_sub_3',
          merchant: 'Netflix Subscription',
          amount: 649.0,
          category: TransactionCategory.entertainment,
          accountId: 'acc_1',
          date: now,
          type: TransactionType.expense,
        ),
      ];

      final detected = service.detectRecurring(transactions);

      expect(detected.isNotEmpty, isTrue);
      final netflix = detected.first;
      expect(netflix.merchant, equals('Netflix Subscription'));
      expect(netflix.amount, equals(649.0));
      expect(netflix.frequency, equals(RecurringFrequency.monthly));
    });

    test('does not flag single non-repeated transactions as recurring', () {
      final transactions = [
        TransactionModel(
          id: 'tx_one_time',
          merchant: 'Zara Clothing',
          amount: 2500.0,
          category: TransactionCategory.shopping,
          accountId: 'acc_1',
          date: DateTime.now(),
          type: TransactionType.expense,
        ),
      ];

      final detected = service.detectRecurring(transactions);
      expect(detected.isEmpty, isTrue);
    });
  });
}
