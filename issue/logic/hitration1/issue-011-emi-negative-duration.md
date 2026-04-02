# Issue: EMI Calculation Missing Validation for Invalid Duration

## Severity
**LOW**

## Location
`lib/utils/currency_utils.dart:55-70`

## Description
The `calculateEMI` function returns `(0, 0)` for zero duration but doesn't handle negative duration values, which could cause unexpected behavior if invalid data is passed.

## Reproduction Conditions
- Corrupted chitty data with negative duration
- Programming error passing negative value
- Integer overflow causing negative duration
- Malformed input from API or database

## Expected Behavior
- Duration should be validated as positive integer (> 0)
- Invalid duration should throw descriptive error
- EMI calculation should never return misleading values

## Actual Behavior
The current code:

```dart
// lib/utils/currency_utils.dart:55-70
static (int baseEMI, int firstMonthExtra) calculateEMI({
  required int totalAmountInCents,
  required int duration,
}) {
  if (duration <= 0) return (0, 0);  // ← Only checks <= 0, returns silently

  // Chitti logic usually prefers whole unit EMIs for easy collection.
  // Example: 1000 / 12 = 83 with remainder 4.
  // Month 1: 83+4, Months 2-12: 83.

  int totalUnits = totalAmountInCents ~/ 100;
  int decimalCents = totalAmountInCents % 100;

  int baseUnit = totalUnits ~/ duration;
  int unitRemainder = totalUnits % duration;

  int baseEMIcents = baseUnit * 100;
  int firstMonthExtraCents = (unitRemainder * 100) + decimalCents;

  return (baseEMIcents, firstMonthExtraCents);
}
```

### Issues

1. **Silent failure**: Returns `(0, 0)` without error
2. **No logging**: No warning about invalid input
3. **Downstream errors**: Calling code may not check for zero EMI
4. **Negative duration**: Not explicitly handled (though `<= 0` catches it)

### Downstream Impact

```dart
// Calling code that doesn't validate
final (baseEMI, firstMonthExtra) = calculateEMI(
  totalAmountInCents: 120000,
  duration: 0,  // Invalid!
);

// baseEMI = 0, firstMonthExtra = 0
// Member's monthly EMI = 0 (free money!)
// Total due = 0 (incorrect)
```

## Impact Analysis

### Data Corruption
- Chittis with invalid duration could be created
- Members assigned zero EMI
- Financial calculations produce nonsense results

### Silent Failures
- No error thrown, bug goes unnoticed
- Reports show zero values without explanation
- Debugging difficult due to lack of error context

### Edge Cases Not Handled

| Input | Current Behavior | Expected Behavior |
|-------|-----------------|-------------------|
| `duration = 0` | Returns `(0, 0)` | Throw error |
| `duration = -1` | Returns `(0, 0)` | Throw error |
| `duration = 1` | Works correctly | Works correctly |
| `totalAmount = 0` | Returns `(0, 0)` | Maybe OK, maybe error |
| `totalAmount = -100` | Calculates nonsense | Throw error |

## Suggested Fix

Add comprehensive validation with descriptive errors:

```dart
static (int baseEMI, int firstMonthExtra) calculateEMI({
  required int totalAmountInCents,
  required int duration,
}) {
  // Validate inputs
  if (duration <= 0) {
    throw ArgumentError(
      'Duration must be positive. Got: $duration',
      'duration',
    );
  }

  if (totalAmountInCents < 0) {
    throw ArgumentError(
      'Total amount cannot be negative. Got: $totalAmountInCents',
      'totalAmountInCents',
    );
  }

  if (totalAmountInCents == 0) {
    // Zero amount is valid (e.g., fully discounted chitty)
    return (0, 0);
  }

  // Chitti logic usually prefers whole unit EMIs for easy collection.
  // Example: 1000 / 12 = 83 with remainder 4.
  // Month 1: 83+4, Months 2-12: 83.

  int totalUnits = totalAmountInCents ~/ 100;
  int decimalCents = totalAmountInCents % 100;

  int baseUnit = totalUnits ~/ duration;
  int unitRemainder = totalUnits % duration;

  int baseEMIcents = baseUnit * 100;
  int firstMonthExtraCents = (unitRemainder * 100) + decimalCents;

  return (baseEMIcents, firstMonthExtraCents);
}
```

### Alternative: Return Result Type

For more robust error handling:

```dart
class EMIResult {
  final bool success;
  final int? baseEMI;
  final int? firstMonthExtra;
  final String? error;

  EMIResult.success(this.baseEMI, this.firstMonthExtra)
    : success = true, error = null;

  EMIResult.failure(this.error)
    : success = false, baseEMI = null, firstMonthExtra = null;
}

static EMIResult calculateEMI({
  required int totalAmountInCents,
  required int duration,
}) {
  if (duration <= 0) {
    return EMIResult.failure('Duration must be positive (got: $duration)');
  }

  if (totalAmountInCents < 0) {
    return EMIResult.failure('Amount cannot be negative (got: $totalAmountInCents)');
  }

  // ... calculation ...

  return EMIResult.success(baseEMIcents, firstMonthExtraCents);
}
```

## Test Case

```dart
test('calculateEMI should throw for zero duration', () {
  expect(
    () => CurrencyUtils.calculateEMI(
      totalAmountInCents: 120000,
      duration: 0,
    ),
    throwsA(isA<ArgumentError>().having(
      (e) => e.message,
      'message',
      contains('duration'),
    )),
  );
});

test('calculateEMI should throw for negative duration', () {
  expect(
    () => CurrencyUtils.calculateEMI(
      totalAmountInCents: 120000,
      duration: -5,
    ),
    throwsA(isA<ArgumentError>()),
  );
});

test('calculateEMI should throw for negative amount', () {
  expect(
    () => CurrencyUtils.calculateEMI(
      totalAmountInCents: -10000,
      duration: 12,
    ),
    throwsA(isA<ArgumentError>()),
  );
});

test('calculateEMI should handle zero amount', () {
  final (base, extra) = CurrencyUtils.calculateEMI(
    totalAmountInCents: 0,
    duration: 12,
  );

  expect(base, equals(0));
  expect(extra, equals(0));
});

test('calculateEMI should work for valid inputs', () {
  final (base, extra) = CurrencyUtils.calculateEMI(
    totalAmountInCents: 120000,  // AED 1200
    duration: 12,
  );

  // 120000 cents / 12 months = 10000 cents/month
  expect(base, equals(10000));  // AED 100
  expect(extra, equals(0));     // No remainder
});

test('calculateEMI should handle remainder correctly', () {
  final (base, extra) = CurrencyUtils.calculateEMI(
    totalAmountInCents: 100000,  // AED 1000
    duration: 12,
  );

  // 100000 cents / 12 = 8333 cents/month with 4 cents remainder
  // Month 1: 8333 + 4 = 8337 cents
  // Months 2-12: 8333 cents each
  // Total: 8337 + (8333 * 11) = 8337 + 91663 = 100000 ✓

  expect(base, equals(8333));
  expect(extra, equals(4));

  // Verify total
  final total = extra + (base * 12);
  expect(total, equals(100000));
});
```

## Verification Steps

1. Test with duration = 0 (should throw)
2. Test with duration < 0 (should throw)
3. Test with amount < 0 (should throw)
4. Test with amount = 0 (should return 0, 0)
5. Test with valid inputs (should calculate correctly)
6. Test remainder handling
7. Verify error messages are descriptive

## Related Issues

- **Issue #003**: Missing null checks (similar validation gap)
- **Issue #007**: Month calculation depends on valid duration

## References

- `lib/utils/currency_utils.dart` - Current implementation
- `lib/services/balance_calculator.dart` - Uses calculateEMI
- `lib/services/chitti_service.dart` - Creates chittis with duration
