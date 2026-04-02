# Issue: Month Progression Calculation Doesn't Handle Year Boundary Correctly

## Severity
**MEDIUM**

## Location
`lib/services/chitti_service.dart:320-345`

## Description
The `advanceMonth` method calculates next month dates using `DateTime(now.year, now.month + 1)` which adds 1 to the current calendar month, not the chitti's logical month. This causes incorrect due dates for chittis that span year boundaries or started in a previous year.

## Reproduction Conditions
- A chitty starts in month X of year Y
- The chitty runs for more than (12 - X) months (spans into year Y+1)
- `advanceMonth` is called to move to the next month
- The calculated dates don't match the chitti's actual month progression

## Expected Behavior
When advancing a chitty from month N to N+1:
1. Calculate the actual month based on `startMonth + currentMonth`
2. Handle year boundary correctly (December → January)
3. Due dates should follow the chitti's logical calendar, not the current calendar

## Actual Behavior
The current code:

```dart
// lib/services/chitti_service.dart:320-345
Future<void> advanceMonth(String chittiId) async {
  try {
    final chitti = await getChitti(chittiId);
    if (chitti == null) return;

    final currentMonth = chitti['currentMonth'] as int? ?? 0;
    final duration = chitti['duration'] as int? ?? 20;
    final paymentDay = chitti['paymentDay'] as int? ?? 15;
    final luckyDrawDay = chitti['luckyDrawDay'] as int? ?? 20;

    if (currentMonth >= duration) {
      await _db.child('chittis/$chittiId').update({
        'status': 'completed',
        'completedAt': ServerValue.timestamp,
      });
      return;
    }

    // Calculate next dates
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);  // ← BUG: Uses current calendar!
    final nextPaymentDate = DateTime(
      nextMonth.year,
      nextMonth.month,
      paymentDay,
    );
    final nextWinnerDate = DateTime(
      nextMonth.year,
      nextMonth.month,
      luckyDrawDay,
    );

    await _db.child('chittis/$chittiId').update({
      'currentMonth': currentMonth + 1,
      'nextPaymentDate': nextPaymentDate.toIso8601String().split('T')[0],
      'nextWinnerDate': nextWinnerDate.toIso8601String().split('T')[0],
    });
  } catch (e) {
    print('Error advancing month: $e');
    rethrow;
  }
}
```

### Example Bug Scenario

**Chitty Details:**
- Start Month: September 2024
- Duration: 12 months
- Payment Day: 15th of each month

**Expected Month Progression:**
| Chitty Month | Calendar Month | Payment Due Date |
|--------------|----------------|------------------|
| 1 | September 2024 | Sep 15, 2024 |
| 2 | October 2024 | Oct 15, 2024 |
| ... | ... | ... |
| 5 | January 2025 | Jan 15, 2025 |
| 6 | February 2025 | Feb 15, 2025 |

**Bug Scenario (advance called in January 2025):**
- `now` = January 2025
- `currentMonth` = 5 (chitty is in month 5)
- `nextMonth` = `DateTime(2025, 1 + 1)` = February 2025
- This happens to be correct by coincidence!

**Bug Scenario (advance called in March 2025, but chitti is behind):**
- `now` = March 2025
- `currentMonth` = 5 (chitti is behind schedule)
- `nextMonth` = `DateTime(2025, 3 + 1)` = April 2025
- **Expected**: February 2025 (chitty month 6)
- **Actual**: April 2025 (wrong!)

## Impact Analysis

### Incorrect Due Dates

Members receive payment reminders for wrong months, causing:
- Confusion about which month they're paying for
- Payments applied to wrong month keys
- Ledger inconsistencies

### Year Boundary Issues

For chittis spanning year boundaries:
- December 2024 → Should become January 2025
- `DateTime(2024, 12 + 1)` = `DateTime(2024, 13)` = January 2025 ✓ (works by Dart magic)

Dart's DateTime constructor handles overflow, so `DateTime(2024, 13)` becomes January 2025. However, this is still wrong because it uses the current calendar, not the chitti's calendar.

### Long-Running Chittis

For chittis longer than 12 months:
- Month 15 should be March of year 2
- If current calendar is January year 2, calculation gives February (wrong)

## Suggested Fix

Calculate month based on chitti's start date and current month number:

```dart
Future<void> advanceMonth(String chittiId) async {
  try {
    final chitti = await getChitti(chittiId);
    if (chitti == null) return;

    final currentMonth = chitti['currentMonth'] as int? ?? 0;
    final duration = chitti['duration'] as int? ?? 20;
    final paymentDay = chitti['paymentDay'] as int? ?? 15;
    final luckyDrawDay = chitti['luckyDrawDay'] as int? ?? 20;
    final startMonth = chitti['startMonth'] as String? ?? '';

    if (currentMonth >= duration) {
      await _db.child('chittis/$chittiId').update({
        'status': 'completed',
        'completedAt': ServerValue.timestamp,
      });
      return;
    }

    // FIXED: Calculate next month from chitti's start date
    final nextMonthNumber = currentMonth + 1;  // 1-indexed month number
    final nextMonthDate = _getMonthDate(startMonth, nextMonthNumber);

    final nextPaymentDate = DateTime(
      nextMonthDate.year,
      nextMonthDate.month,
      paymentDay,
    );
    final nextWinnerDate = DateTime(
      nextMonthDate.year,
      nextMonthDate.month,
      luckyDrawDay,
    );

    await _db.child('chittis/$chittiId').update({
      'currentMonth': nextMonthNumber,
      'nextPaymentDate': nextPaymentDate.toIso8601String().split('T')[0],
      'nextWinnerDate': nextWinnerDate.toIso8601String().split('T')[0],
    });
  } catch (e) {
    print('Error advancing month: $e');
    rethrow;
  }
}

/// Helper: Get DateTime for a specific month number from start
DateTime _getMonthDate(String startMonth, int monthNumber) {
  // Parse startMonth (supports "YYYY-MM" or "Month YYYY")
  DateTime startDate;
  if (startMonth.contains('-')) {
    // YYYY-MM format
    final parts = startMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    startDate = DateTime(year, month, 1);
  } else {
    // "Month YYYY" format
    final parts = startMonth.split(' ');
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    final monthIndex = months.indexOf(parts[0]);
    final year = int.parse(parts[1]);
    startDate = DateTime(year, monthIndex + 1, 1);
  }

  // Add (monthNumber - 1) months to start
  return DateTime(startDate.year, startDate.month + monthNumber - 1, 1);
}
```

## Alternative: Use Existing Utility

The `BalanceCalculator` already has this logic:

```dart
// lib/services/balance_calculator.dart:230-235
static String getMonthKey(String startMonth, int monthNumber) {
  final start = _parseMonthKey(startMonth);
  final target = DateTime(start.year, start.month + monthNumber - 1, 1);
  return _formatMonthKey(target);
}
```

Reuse this utility in `chitti_service.dart`.

## Test Case

```dart
test('advanceMonth should calculate dates from chitti start month', () async {
  final service = ChittiService();

  // Setup: Create chitty starting September 2024
  final chittiId = await service.createChitti(
    name: 'Test Chitty',
    duration: 12,
    startMonth: '2024-09',  // September 2024
    goldOptions: [...],
    maxSlots: 10,
    paymentDay: 15,
    luckyDrawDay: 20,
    goldOptionRewards: {},
  );

  await service.startChitti(chittiId);

  // Advance to month 5 (should be January 2025)
  for (int i = 0; i < 4; i++) {
    await service.advanceMonth(chittiId);
  }

  final chitti = await service.getChitti(chittiId);
  expect(chitti!['currentMonth'], equals(5));

  // Parse nextPaymentDate
  final nextPaymentDate = DateTime.parse(chitti['nextPaymentDate']);
  expect(nextPaymentDate.year, equals(2025));
  expect(nextPaymentDate.month, equals(1));  // January
  expect(nextPaymentDate.day, equals(15));

  // Advance to month 13 (should be September 2025 - exactly 1 year from start)
  for (int i = 0; i < 8; i++) {
    await service.advanceMonth(chittiId);
  }

  final finalChitti = await service.getChitti(chittiId);
  final finalPaymentDate = DateTime.parse(finalChitti!['nextPaymentDate']);
  expect(finalPaymentDate.year, equals(2025));
  expect(finalPaymentDate.month, equals(9));  // September
});

test('advanceMonth should handle year boundary correctly', () async {
  final service = ChittiService();

  // Setup: Chitty starting November 2024
  final chittiId = await service.createChitti(
    name: 'Year Boundary Test',
    duration: 6,
    startMonth: '2024-11',  // November 2024
    goldOptions: [...],
    maxSlots: 5,
    paymentDay: 10,
    luckyDrawDay: 15,
    goldOptionRewards: {},
  );

  await service.startChitti(chittiId);

  // Month 1: November 2024
  // Month 2: December 2024
  // Month 3: January 2025 (year boundary!)
  await service.advanceMonth(chittiId);  // To month 1
  await service.advanceMonth(chittiId);  // To month 2
  await service.advanceMonth(chittiId);  // To month 3

  final chitti = await service.getChitti(chittiId);
  expect(chitti!['currentMonth'], equals(3));

  final nextPaymentDate = DateTime.parse(chitti['nextPaymentDate']);
  expect(nextPaymentDate.year, equals(2025));
  expect(nextPaymentDate.month, equals(1));  // January 2025
});
```

## Verification Steps

1. Create a chitty starting in different months
2. Advance through year boundary
3. Verify payment dates match expected calendar
4. Test with chittis longer than 12 months
5. Test with chittis that are behind schedule

## Related Issues

- **Issue #002**: Opening balance calculation depends on correct month progression
- **Issue #007**: This issue (same root cause in different location)

## References

- `lib/services/balance_calculator.dart` - Has correct month calculation logic
- `lib/utils/currency_utils.dart` - Month parsing utilities
