import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/core/utils/validators.dart';

void main() {
  group('Validators — email', () {
    test('valid email passes', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('empty email fails', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('invalid format fails', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('a@'), isNotNull);
      expect(Validators.email('@domain.com'), isNotNull);
    });
  });

  group('Validators — password', () {
    test('valid password passes', () {
      expect(Validators.password('SecurePass1'), isNull);
    });

    test('too short fails', () {
      expect(Validators.password('Ab1'), isNotNull);
    });

    test('no uppercase fails', () {
      expect(Validators.password('password1'), isNotNull);
    });

    test('no number fails', () {
      expect(Validators.password('Password'), isNotNull);
    });

    test('empty fails', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password(null), isNotNull);
    });
  });

  group('Validators — confirmPassword', () {
    test('matching passwords pass', () {
      expect(Validators.confirmPassword('SecurePass1', 'SecurePass1'), isNull);
    });

    test('mismatched passwords fail', () {
      expect(Validators.confirmPassword('SecurePass1', 'Different1'), isNotNull);
    });

    test('empty confirm fails', () {
      expect(Validators.confirmPassword('', 'SecurePass1'), isNotNull);
      expect(Validators.confirmPassword(null, 'SecurePass1'), isNotNull);
    });
  });

  group('Validators — fullName', () {
    test('valid name passes', () {
      expect(Validators.fullName('Arjun Sharma'), isNull);
    });

    test('empty fails', () {
      expect(Validators.fullName(''), isNotNull);
      expect(Validators.fullName(null), isNotNull);
    });

    test('single character fails', () {
      expect(Validators.fullName('A'), isNotNull);
    });

    test('very long name fails', () {
      expect(Validators.fullName('A' * 61), isNotNull);
    });
  });

  group('Validators — amount', () {
    test('valid amount passes', () {
      expect(Validators.amount('5000'), isNull);
      expect(Validators.amount('₹5,000'), isNull);
    });

    test('zero fails', () {
      expect(Validators.amount('0'), isNotNull);
    });

    test('negative fails', () {
      expect(Validators.amount('-500'), isNotNull);
    });

    test('empty fails', () {
      expect(Validators.amount(''), isNotNull);
      expect(Validators.amount(null), isNotNull);
    });
  });
}
