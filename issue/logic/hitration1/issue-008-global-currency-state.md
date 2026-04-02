# Issue: Global Currency State Creates Hidden Dependencies

## Severity
**MEDIUM**

## Location
`lib/utils/currency_utils.dart:14-18`

## Description
The `CurrencyUtils` class uses a static mutable `_currencySymbol` variable for global state. This creates hidden dependencies where changing the currency in one part of the app affects all other parts, potentially causing incorrect currency display in multi-currency scenarios.

## Reproduction Conditions
- App supports multiple currencies (AED, INR, etc.)
- Different chittis use different currencies
- Currency is changed via `CurrencyUtils.setCurrencySymbol()`
- Multiple screens display amounts simultaneously

## Expected Behavior
- Each chitty should display amounts in its configured currency
- Currency should be passed explicitly or retrieved from chitty settings
- Changing currency for one operation shouldn't affect unrelated operations

## Actual Behavior
The current implementation:

```dart
// lib/utils/currency_utils.dart:14-18
class CurrencyUtils {
  CurrencyUtils._(); // Private constructor

  /// Default currency symbol
  static String _currencySymbol = 'AED';  // ← Global mutable state!

  /// Set the currency symbol
  static void setCurrencySymbol(String symbol) {
    _currencySymbol = symbol;  // Changes global state!
  }

  /// Get the current currency symbol
  static String get currencySymbol => _currencySymbol;

  // All formatting uses the global symbol
  static String formatCents(int cents, {String? symbol}) {
    final formatter = NumberFormat('#,##0.00');
    return '${symbol ?? _currencySymbol} ${formatter.format(fromCents(cents))}';
    //       ↑ Falls back to global state!
  }
}
```

### Problem Scenarios

**Scenario 1: Organizer manages multi-currency chittis**
```dart
// Organizer views AED chitty
CurrencyUtils.setCurrencySymbol('AED');
displayAmount(10000);  // Shows "AED 100.00" ✓

// Organizer switches to INR chitty
CurrencyUtils.setCurrencySymbol('INR');
displayAmount(10000);  // Shows "INR 100.00" ✓

// Meanwhile, AED chitty screen refreshes
displayAmount(10000);  // Shows "INR 100.00" ✗ WRONG!
```

**Scenario 2: Concurrent currency changes**
```dart
// Thread 1: Formatting AED amount
CurrencyUtils.setCurrencySymbol('AED');
// Context switch before format

// Thread 2: Formatting INR amount
CurrencyUtils.setCurrencySymbol('INR');
final inrAmount = CurrencyUtils.formatCents(10000);  // "INR 100.00"

// Thread 1 resumes
final aedAmount = CurrencyUtils.formatCents(10000);  // "INR 100.00" ✗ WRONG!
```

**Scenario 3: Database settings change**
```dart
// App loads settings from database
final settings = await getAppSettings();  // currency: 'INR'
CurrencyUtils.setCurrencySymbol(settings['currency']);

// All existing UI now shows INR instead of their original currency
```

## Impact Analysis

### User Confusion
- Members see wrong currency symbols
- Amounts appear correct but currency is wrong
- Financial reports mix currencies

### Data Integrity
- Exported reports may have wrong currency
- Receipts generated with incorrect currency
- Audit trail currency information unreliable

### Testing Difficulty
- Tests that set currency affect other tests
- Hard to test multi-currency scenarios
- Flaky tests due to global state

## Suggested Fix

### Option 1: Remove Global State (Recommended)

Make currency an explicit parameter:

```dart
// lib/utils/currency_utils.dart
class CurrencyUtils {
  CurrencyUtils._();

  // Removed: static _currencySymbol

  /// Format cents with explicit currency
  static String formatCents(int cents, {required String currency}) {
    final symbol = CurrencyData.getSymbol(currency);
    final formatter = NumberFormat('#,##0.00', currency);
    return '$symbol ${formatter.format(fromCents(cents))}';
  }

  /// Format with currency from chitty settings
  static String formatCentsForChitty(int cents, Map<String, dynamic> chitty) {
    final currency = chitty['currency'] as String? ?? 'AED';
    return formatCents(cents, currency: currency);
  }

  /// Format decimal amount
  static String format(double amount, {required String currency}) {
    final symbol = CurrencyData.getSymbol(currency);
    final formatter = NumberFormat('#,##0.00', currency);
    return '$symbol ${formatter.format(amount)}';
  }
}
```

Usage:
```dart
// Before (buggy)
CurrencyUtils.setCurrencySymbol('AED');
final text = CurrencyUtils.formatCents(10000);

// After (safe)
final text = CurrencyUtils.formatCents(10000, currency: 'AED');
```

### Option 2: Immutable Configuration

Use a configuration object passed through the widget tree:

```dart
// lib/core/config/app_config.dart
class AppConfig {
  final String currency;

  const AppConfig({required this.currency});

  static AppConfig? _current;

  static void initialize(AppConfig config) {
    _current = config;
  }

  static String get currency => _current?.currency ?? 'AED';
}

// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final settings = await getAppSettings();
  AppConfig.initialize(AppConfig(currency: settings['currency'] ?? 'AED'));

  runApp(MyApp());
}

// In widgets
final amount = CurrencyUtils.formatCents(10000, currency: AppConfig.currency);
```

### Option 3: Per-Chitty Currency

Store and retrieve currency per chitty:

```dart
// lib/services/chitti_service.dart
class ChittiService {
  Future<String> getChittyCurrency(String chittiId) async {
    final chitti = await getChitti(chittiId);
    return chitti?['currency'] as String? ?? 'AED';
  }
}

// Usage in UI
final currency = await chittiService.getChittyCurrency(chittiId);
final text = CurrencyUtils.formatCents(amount, currency: currency);
```

## Test Case

```dart
test('currency formatting should not affect global state', () async {
  // Setup: No global currency set

  // Format AED amount
  final aedText = CurrencyUtils.formatCents(10000, currency: 'AED');
  expect(aedText, contains('AED'));

  // Format INR amount
  final inrText = CurrencyUtils.formatCents(10000, currency: 'INR');
  expect(inrText, contains('INR'));

  // AED formatting should still work
  final aedText2 = CurrencyUtils.formatCents(10000, currency: 'AED');
  expect(aedText2, contains('AED'));

  // Verify no global state was modified
  // (This test would fail with current implementation)
});

test('concurrency: different currencies should not interfere', () async {
  // Simulate concurrent formatting
  final futures = [
    compute((_) => CurrencyUtils.formatCents(10000, currency: 'AED'), null),
    compute((_) => CurrencyUtils.formatCents(10000, currency: 'INR'), null),
    compute((_) => CurrencyUtils.formatCents(10000, currency: 'USD'), null),
  ];

  final results = await Future.wait(futures);

  expect(results[0], contains('AED'));
  expect(results[1], contains('INR'));
  expect(results[2], contains('USD'));
});
```

## Verification Steps

1. Audit all usages of `CurrencyUtils.setCurrencySymbol()`
2. Audit all usages of `CurrencyUtils.formatCents()` without explicit currency
3. Replace global state with explicit parameters
4. Test multi-currency chitty scenarios
5. Verify reports show correct currency per chitty

## Related Issues

- **Issue #003**: Missing null checks (currency could be null in some scenarios)

## References

- `lib/utils/currency_data.dart` - Currency definitions
- `lib/services/database_service.dart` - App settings with currency
- `lib/utils/currency_utils.dart` - Current implementation
