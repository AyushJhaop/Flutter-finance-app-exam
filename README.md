# FinTrack — AI-Powered Personal Finance Manager

[![Flutter](https://img.shields.io/badge/Flutter-3.47.0-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.0-blue.svg)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Provider-emerald.svg)](https://pub.dev/packages/provider)
[![Security](https://img.shields.io/badge/Security-Hardware%20Keystore%20%7C%20Biometric-green.svg)](https://pub.dev/packages/flutter_secure_storage)

> **FinTrack** is a modern, production-grade cross-platform personal financial command centre built with Flutter and Dart. It aggregates transactions across bank accounts, cards, UPI wallets, automates merchant categorization, calculates budget pacing with threshold alerts, detects recurring subscriptions, projects savings progress, and generates explainable, non-prescriptive AI spending observations.

---

## 1. Project Overview & Features

### 🏦 Multi-Account Aggregation
- **Account Types**: Salary Accounts (HDFC), Savings Accounts (SBI), Credit Cards (ICICI Coral), and UPI Wallets (Paytm/PhonePe).
- **Net Worth Calculation**: Real-time assets vs liabilities balance tally (`₹82,450` net balance).
- **Multi-Bank Sync Simulation**: Architected with decoupled repository interfaces ready for Account Aggregator (AA / ReBIT) API integration.

### 💳 Transaction Intelligence & Categorization
- **Rule-Based Engine**: Real-time keyword classifier for top merchants (`Swiggy`, `Zomato` → Food; `Amazon`, `Zara` → Shopping; `Uber`, `Shell` → Travel; `Jio`, `BESCOM` → Bills; `Netflix`, `Spotify` → Entertainment).
- **Extensible AI Hook**: Clean abstraction (`ICategorisationEngine`) allowing ML/LLM plug-in without modifying presentation layer.
- **Search & Filter**: Instant search by merchant name, category chips, income/expense toggle, and date grouping.
- **Transaction Logging**: Interactive bottom sheet with account selector and instant balance recalculation.

### 📊 Financial Analytics & Interactive Visualizations
- Powered by `fl_chart`:
  - **Income vs Expenses Bar Chart**: Multi-month comparative bar chart (`₹75,000` income vs `₹23,680` expense).
  - **Category Donut Chart**: Touch-interactive pie chart with category color tokens and percentage legend.
  - **30-Day Spending Trend**: Smooth spline curve displaying weekly run-rate.
  - **Savings Rate Gauge**: Real-time KPI gauge calculating retained income (`68.4%` savings rate).

### 🎯 Monthly Budget System & Threshold Alerts
- **Monthly Spending Ceiling**: Configurable overall ceiling (`₹30,000`).
- **Category Budgets**: Granular limits across Food (`₹6,000`), Shopping (`₹5,000`), Travel (`₹4,000`), Bills (`₹7,000`), Entertainment (`₹3,000`), and Other.
- **Visual Alert Thresholds**:
  - `< 80%`: Normal (`Emerald`)
  - `80% - 89%`: Warning (`Amber`)
  - `90% - 99%`: Strong Warning (`Orange`)
  - `≥ 100%`: Exceeded (`Red`)

### 🔁 Recurring Payment & Subscription Detector
- **Pattern Detection**: Analyzes historical transactions for matching merchants, amounts, and regular cadences (weekly, monthly, quarterly).
- **Scheduled Commitments**: Automated due-date countdown for Netflix (`₹649`), Jio Fiber (`₹999`), Rent (`₹15,000`), Spotify (`₹119`), and Gym (`₹1,800`).

### 🏆 Savings Goals
- **Target Tracking**: Dedicated trackers for MacBook Pro M3 (`₹120,000`), Emergency Reserve (`₹100,000`), and Tokyo Vacation (`₹200,000`).
- **Milestone Countdown**: Visual progress bars, days until target date, and one-tap contributions.

### 🤖 AI Financial Insights Engine
- **Deterministic Observations**: Generates explainable, conversational observations:
  - *Dining Surge*: Flags when food delivery spend exceeds historical averages (`+21%`).
  - *Budget Risk*: Predicts month-end budget breach based on daily pacing.
  - *Savings Milestone*: Celebrates reaching 60%+ completion of savings targets.
- **Safety & Disclaimers**: Clarifies observations are based on historical account data and do not constitute certified financial advice.
- **Resilient Fallback**: 100% offline-compatible local rule engine ensures the UI never crashes if external AI providers are unreachable.

### 🔐 Security Centre & Authentication
- **Biometric Integration**: Face ID / Touch ID / Android BiometricPrompt via `local_auth`.
- **Encrypted Local Storage**: Sensitive auth tokens stored in iOS Keychain / Android EncryptedSharedPreferences via `flutter_secure_storage` (AES-256 GCM).
- **Session Auto-Lock**: Configurable background app auto-lock.
- **Zero Hardcoded Secrets**: Client contains no embedded API keys or credentials.

### 📴 Offline Resilience
- **Dual-Storage Caching**: Essential summaries, budgets, and transactions cached in `shared_preferences` and synced upon connectivity restoration.
- **Graceful Degradation**: Offline indicators inform users of cached data with last-synced relative timestamps.

---

## 2. Architecture & Design

### Clean Layered Architecture

```text
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                   │
│   Screens: Dashboard, Transactions, Analytics, Savings,│
│            Budgets, Accounts, Reports, Security, Pro   │
│   Widgets: AppButton, AppTextField, AppCard, AppSnackbar│
└───────────────────────────▲────────────────────────────┘
                            │ listens via Provider
┌───────────────────────────┴────────────────────────────┐
│                  APPLICATION / STATE                   │
│   FinanceProvider   BudgetProvider   SavingsProvider   │
│   AiInsightProvider NotificationProvider  AuthProvider │
└───────────────────────────▲────────────────────────────┘
                            │ invokes
┌───────────────────────────┴────────────────────────────┐
│                     DOMAIN SERVICES                    │
│   FinanceService        CategorisationService          │
│   RecurringDetection    AiInsightService               │
│   NotificationService   BiometricService               │
└───────────────────────────▲────────────────────────────┘
                            │ reads / writes
┌───────────────────────────┴────────────────────────────┐
│                    DATA & STORAGE                      │
│   StorageService (Cache)   SecureStorage (Keychain)    │
│   Mock FinTech Repository  (Simulating AA & UPI)       │
└────────────────────────────────────────────────────────┘
```

### Folder Structure

```text
lib/
├── core/
│   ├── constants/       # AppColors, AppTypography, AppSpacing, AppRadius
│   ├── routing/         # GoRouter with redirect guards (AppRouter)
│   ├── theme/           # Dark FinTech Material 3 theme (AppTheme)
│   └── utils/           # CurrencyFormatter, DateFormatter, Validators
├── models/              # UserModel, AccountModel, TransactionModel, BudgetModel,
│                        # RecurringPaymentModel, SavingsGoalModel, AiInsightModel, NotificationModel
├── services/            # FinanceService, AuthService, CategorisationService,
│                        # RecurringDetectionService, AiInsightService, NotificationService,
│                        # StorageService, SecureStorageService, BiometricService
├── providers/           # FinanceProvider, BudgetProvider, SavingsProvider,
│                        # AiInsightProvider, NotificationProvider, AuthProvider
├── screens/
│   ├── splash/          # Animated branded splash with session check
│   ├── onboarding/      # 3-step value proposition onboarding flow
│   ├── auth/            # LoginScreen & SignupScreen with form validation
│   ├── main/            # MainShell with persistent NavigationBar
│   ├── dashboard/       # Primary financial command centre
│   ├── transactions/    # Filterable & searchable transaction log
│   ├── analytics/       # Charts (Line, Donut, Bar) & Savings KPI
│   ├── savings/         # Goals progress & contribution dialogs
│   ├── accounts/        # Aggregated bank accounts & credit card dues
│   ├── budgets/         # Category limits & threshold manager
│   ├── notifications/   # In-app budget and recurring bill alerts
│   ├── reports/         # Monthly statements & PDF/CSV export simulation
│   ├── security/        # Security centre & hardware encryption verification
│   ├── premium/         # Subscription tiers (₹99, ₹199, ₹299) & feature matrix
│   └── profile/         # Profile summary, quick links, and safe logout
└── widgets/
    └── common/          # AppCard, AppButton, AppTextField, EmptyState, AppSnackbar
```

---

## 3. Getting Started

### Prerequisites
- Flutter SDK `^3.47.0` (or compatible stable Flutter 3.x)
- Dart SDK `^3.13.0`

### Setup Instructions

1. Clone or navigate to the project directory:
   ```bash
   cd /Users/ayushjha/Desktop/flutter-exam
   ```

2. Fetch project dependencies:
   ```bash
   flutter pub get
   ```

3. Run static analysis:
   ```bash
   flutter analyze
   ```

4. Run the automated test suite:
   ```bash
   flutter test
   ```

5. Launch the application:
   ```bash
   flutter run
   ```

---

## 4. Verification & Testing

The project includes unit and widget tests covering critical business logic:

| Test File | Verified Functionality |
| :--- | :--- |
| `test/validators_test.dart` | Email regex, password length/entropy, full name, and positive amount validation. |
| `test/currency_formatter_test.dart` | Indian Rupee formatting (`₹82,450`), compact formats (`₹82.4K`), and string parsing. |
| `test/categorisation_service_test.dart` | Automated keyword mapping for Swiggy, Amazon, Uber, Netflix, Jio, and other merchants. |
| `test/budget_service_test.dart` | Total spent calculation (`₹23,680`), remaining (`₹6,320`), utilization (`78.93%`), and threshold triggers (`80%`, `90%`, `100%`). |
| `test/savings_test.dart` | Target vs saved calculations, progress percentages (`60%`), and goal completion states. |
| `test/recurring_detection_test.dart` | Multi-interval transaction detection for monthly recurring subscriptions. |
| `test/analytics_test.dart` | Inflow/outflow math, net retained capital (`₹51,320`), and savings rate (`68.4%`). |
| `test/widget_test.dart` | Smoke test ensuring app bootstrap, MultiProvider injection, and GoRouter lifecycle without crash. |

---

## 5. Security & Privacy Highlights

1. **No Plaintext Passwords**: Password hashes simulated; no sensitive credentials written to plaintext logs or standard preferences.
2. **Encrypted Storage**: Auth tokens and sensitive identifiers are stored via `FlutterSecureStorage` using hardware keystores.
3. **No Hardcoded API Keys**: All AI and external service interfaces are abstracted; client code does not commit private API secrets.
4. **Transparent AI**: All automated suggestions are presented as informational observations rather than binding financial advice.
