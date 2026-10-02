import 'package:intl/intl.dart';

/// Centralised currency formatting for INR.
/// Use this instead of manual string formatting.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _compact = NumberFormat.compact(locale: 'en_IN');
  static final NumberFormat _full = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  static final NumberFormat _decimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format as ₹82,450 (no decimals)
  static String format(double amount) => _full.format(amount);

  /// Alias for format
  static String formatINR(double amount) => format(amount);

  /// Format as ₹82,450.00 (with decimals)
  static String formatDecimal(double amount) => _decimal.format(amount);

  /// Format as ₹82.4K or ₹1.2L (compact)
  static String formatCompact(double amount) =>
      '₹${_compact.format(amount)}';

  /// Format as +₹5,000 or -₹5,000
  static String formatWithSign(double amount) {
    final formatted = _full.format(amount.abs());
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }

  /// Parse a formatted string back to double
  static double parse(String text) {
    final cleaned = text.replaceAll(RegExp(r'[₹,\s]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
