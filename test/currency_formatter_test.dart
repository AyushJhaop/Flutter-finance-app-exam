import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats whole number as INR', () {
      final result = CurrencyFormatter.format(82450);
      expect(result, contains('82,450'));
      expect(result, contains('₹'));
    });

    test('formats zero', () {
      final result = CurrencyFormatter.format(0);
      expect(result, contains('₹'));
    });

    test('formats with sign — positive', () {
      final result = CurrencyFormatter.formatWithSign(5000);
      expect(result.startsWith('+'), isTrue);
    });

    test('formats with sign — negative', () {
      final result = CurrencyFormatter.formatWithSign(-5000);
      expect(result.startsWith('-'), isTrue);
    });

    test('parses formatted string back to double', () {
      expect(CurrencyFormatter.parse('₹82,450'), closeTo(82450, 1));
      expect(CurrencyFormatter.parse('5000'), closeTo(5000, 1));
    });
  });
}
