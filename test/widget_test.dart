import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/main.dart';
import 'package:fintrack/services/storage_service.dart';
import 'package:fintrack/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('App starts without crashing', (WidgetTester tester) async {
    final storage = await StorageService.getInstance();
    final secureStorage = SecureStorageService();

    await tester.pumpWidget(
      FinTrackApp(storage: storage, secureStorage: secureStorage),
    );
    await tester.pump(const Duration(milliseconds: 2500));
    // Verify the app renders MaterialApp without throwing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

