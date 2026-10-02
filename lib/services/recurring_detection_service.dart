import '../models/transaction_model.dart';
import '../models/recurring_payment_model.dart';

class RecurringDetectionService {
  /// Scans transactions and detects recurring subscriptions/bills
  List<RecurringPaymentModel> detectRecurring(
    List<TransactionModel> transactions,
  ) {
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    // Group by normalized merchant
    final Map<String, List<TransactionModel>> merchantMap = {};
    for (final tx in expenses) {
      final key = tx.merchant.trim().toLowerCase();
      merchantMap.putIfAbsent(key, () => []).add(tx);
    }

    final List<RecurringPaymentModel> detected = [];

    merchantMap.forEach((merchantKey, txs) {
      if (txs.length < 2) return;

      // Sort by date ascending
      txs.sort((a, b) => a.date.compareTo(b.date));

      // Calculate intervals between consecutive transactions
      final intervals = <int>[];
      for (int i = 0; i < txs.length - 1; i++) {
        final diff = txs[i + 1].date.difference(txs[i].date).inDays;
        intervals.add(diff);
      }

      if (intervals.isEmpty) return;

      final avgInterval =
          intervals.reduce((a, b) => a + b) / intervals.length;

      RecurringFrequency? freq;
      if (avgInterval >= 25 && avgInterval <= 35) {
        freq = RecurringFrequency.monthly;
      } else if (avgInterval >= 6 && avgInterval <= 8) {
        freq = RecurringFrequency.weekly;
      } else if (avgInterval >= 80 && avgInterval <= 100) {
        freq = RecurringFrequency.quarterly;
      } else if (avgInterval >= 350 && avgInterval <= 380) {
        freq = RecurringFrequency.yearly;
      }

      if (freq != null) {
        final latest = txs.last;
        final nextDays = freq == RecurringFrequency.monthly
            ? 30
            : freq == RecurringFrequency.weekly
                ? 7
                : freq == RecurringFrequency.quarterly
                    ? 90
                    : 365;

        detected.add(
          RecurringPaymentModel(
            id: 'rec_${latest.id}',
            merchant: latest.merchant,
            amount: latest.amount,
            frequency: freq,
            lastPayment: latest.date,
            nextPayment: latest.date.add(Duration(days: nextDays)),
            category: latest.category,
            accountId: latest.accountId,
            accountName: latest.accountName,
            isActive: true,
          ),
        );
      }
    });

    return detected;
  }
}
