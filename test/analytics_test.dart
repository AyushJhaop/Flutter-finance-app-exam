import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Analytics Calculations', () {
    test('computes savings rate and net savings matching case study', () {
      const double income = 75000.0;
      const double expense = 23680.0;

      final double savings = income - expense;
      final double savingsRate = (savings / income) * 100;

      expect(savings, equals(51320.0));
      expect(savingsRate, closeTo(68.43, 0.05));
    });
  });
}
