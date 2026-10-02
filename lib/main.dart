import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/providers.dart';
import 'services/auth_service.dart';
import 'services/biometric_service.dart';
import 'services/categorisation_service.dart';
import 'services/recurring_detection_service.dart';
import 'services/ai_insight_service.dart';
import 'services/finance_service.dart';
import 'services/notification_service.dart';
import 'services/secure_storage_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialise storage (requires async)
  final storage = await StorageService.getInstance();
  final secureStorage = SecureStorageService();
  final categorisationService = CategorisationService();
  final recurringDetectionService = RecurringDetectionService();
  final financeService = FinanceService(
    storage: storage,
    categorisationService: categorisationService,
    recurringDetectionService: recurringDetectionService,
  );
  await financeService.initialize();

  runApp(FinTrackApp(
    storage: storage,
    secureStorage: secureStorage,
    categorisationService: categorisationService,
    recurringDetectionService: recurringDetectionService,
    financeService: financeService,
  ));
}

class FinTrackApp extends StatelessWidget {
  final StorageService storage;
  final SecureStorageService secureStorage;
  final CategorisationService categorisationService;
  final RecurringDetectionService recurringDetectionService;
  final FinanceService financeService;

  FinTrackApp({
    super.key,
    required this.storage,
    required this.secureStorage,
    CategorisationService? categorisationService,
    RecurringDetectionService? recurringDetectionService,
    FinanceService? financeService,
  })  : categorisationService =
            categorisationService ?? CategorisationService(),
        recurringDetectionService =
            recurringDetectionService ?? RecurringDetectionService(),
        financeService = financeService ??
            FinanceService(
              storage: storage,
              categorisationService:
                  categorisationService ?? CategorisationService(),
              recurringDetectionService:
                  recurringDetectionService ?? RecurringDetectionService(),
            );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Storage (non-sensitive)
        Provider<StorageService>.value(value: storage),

        // Secure storage
        Provider<SecureStorageService>.value(value: secureStorage),

        // Core Domain Services
        Provider<BiometricService>(create: (_) => BiometricService()),
        Provider<CategorisationService>.value(value: categorisationService),
        Provider<RecurringDetectionService>.value(
            value: recurringDetectionService),
        Provider<AiInsightService>(create: (_) => AiInsightService()),
        Provider<NotificationService>(create: (_) => NotificationService()),

        Provider<AuthService>(
          create: (ctx) => AuthService(
            secureStorage: ctx.read<SecureStorageService>(),
            storage: ctx.read<StorageService>(),
          ),
        ),

        Provider<FinanceService>.value(value: financeService),

        // State Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(
            authService: ctx.read<AuthService>(),
            biometricService: ctx.read<BiometricService>(),
            storage: ctx.read<StorageService>(),
          ),
        ),

        ChangeNotifierProvider<NotificationProvider>(
          create: (ctx) => NotificationProvider(
            service: ctx.read<NotificationService>(),
          ),
        ),

        ChangeNotifierProvider<FinanceProvider>(
          create: (ctx) => FinanceProvider(
            financeService: ctx.read<FinanceService>(),
          ),
        ),

        ChangeNotifierProvider<BudgetProvider>(
          create: (ctx) => BudgetProvider(
            financeService: ctx.read<FinanceService>(),
            notificationService: ctx.read<NotificationService>(),
          ),
        ),

        ChangeNotifierProvider<SavingsProvider>(
          create: (ctx) => SavingsProvider(
            financeService: ctx.read<FinanceService>(),
            notificationService: ctx.read<NotificationService>(),
          ),
        ),

        ChangeNotifierProvider<AiInsightProvider>(
          create: (ctx) {
            final provider = AiInsightProvider(
              aiService: ctx.read<AiInsightService>(),
              financeService: ctx.read<FinanceService>(),
            );
            // Kick off initial insight generation
            provider.generateInsights();
            return provider;
          },
        ),
      ],
      child: _AppContent(storage: storage),
    );
  }
}

/// Separated so GoRouter can access AuthProvider via context.
class _AppContent extends StatefulWidget {
  final StorageService storage;

  const _AppContent({required this.storage});

  @override
  State<_AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<_AppContent> {
  late final _router = AppRouter.createRouter(context);

  @override
  Widget build(BuildContext context) {
    // Listen to auth changes to trigger GoRouter redirect
    context.watch<AuthProvider>();

    return MaterialApp.router(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
