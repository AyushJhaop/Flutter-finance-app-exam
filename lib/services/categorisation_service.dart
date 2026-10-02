import '../models/transaction_model.dart';

abstract class ICategorisationEngine {
  TransactionCategory categorise(String merchant, {String? description});
}

/// Rule-based categorisation engine.
/// Fast, deterministic, and works 100% offline.
class RuleBasedCategorisationEngine implements ICategorisationEngine {
  static const Map<TransactionCategory, List<String>> _keywords = {
    TransactionCategory.food: [
      'swiggy',
      'zomato',
      'starbucks',
      'mcdonald',
      'burger',
      'pizza',
      'blinkit',
      'zepto',
      'dominos',
      'kfc',
      'cafe',
      'restaurant',
      'diner',
      'bakery',
      'subway',
      'food',
    ],
    TransactionCategory.shopping: [
      'amazon',
      'flipkart',
      'myntra',
      'zara',
      'h&m',
      'nike',
      'adidas',
      'apple store',
      'electronics',
      'retail',
      'clothing',
      'mall',
      'supermarket',
      'ikea',
    ],
    TransactionCategory.travel: [
      'uber',
      'ola',
      'rapido',
      'indigo',
      'air india',
      'metro',
      'fuel',
      'petrol',
      'shell',
      'hpcl',
      'bpcl',
      'flight',
      'train',
      'irctc',
      'bus',
      'taxi',
    ],
    TransactionCategory.bills: [
      'airtel',
      'jio',
      'vi',
      'vodafone',
      'bescom',
      'electricity',
      'broadband',
      'water bill',
      'gas',
      'tata power',
      'maintenance',
      'wifi',
      'bill',
      'utility',
    ],
    TransactionCategory.entertainment: [
      'netflix',
      'spotify',
      'prime video',
      'hotstar',
      'disney',
      'pvr',
      'inox',
      'bookmyshow',
      'steam',
      'playstation',
      'youtube',
      'cinema',
      'movie',
    ],
    TransactionCategory.health: [
      'apollo',
      'netmeds',
      '1mg',
      'pharmeasy',
      'hospital',
      'clinic',
      'pharmacy',
      'doctor',
      'cult.fit',
      'gym',
      'fitness',
      'medplus',
      'dental',
    ],
    TransactionCategory.investment: [
      'zerodha',
      'groww',
      'angelone',
      'mutual fund',
      'sip',
      'stocks',
      'etf',
      'crypto',
      'binance',
      'coinbase',
      'gold',
      'fixed deposit',
    ],
    TransactionCategory.salary: [
      'salary',
      'payroll',
      'wages',
      'infosys',
      'tcs',
      'wipro',
      'google',
      'microsoft',
      'accenture',
      'stipend',
    ],
    TransactionCategory.freelance: [
      'upwork',
      'fiverr',
      'consulting',
      'freelance',
      'contract',
      'client payment',
    ],
  };

  @override
  TransactionCategory categorise(String merchant, {String? description}) {
    final query = '${merchant.toLowerCase()} ${(description ?? '').toLowerCase()}';

    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        if (query.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return TransactionCategory.other;
  }
}

/// CategorisationService orchestrates rule-based engine and potential AI classifiers.
class CategorisationService {
  final ICategorisationEngine _engine;

  CategorisationService({ICategorisationEngine? engine})
      : _engine = engine ?? RuleBasedCategorisationEngine();

  TransactionCategory categorise(String merchant, {String? description}) {
    return _engine.categorise(merchant, description: description);
  }
}
