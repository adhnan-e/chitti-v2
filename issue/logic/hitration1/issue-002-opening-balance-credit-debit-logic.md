# Issue: Opening Balance Credit/Debit Logic Error

## Severity
**CRITICAL**

## Location
`lib/core/domain/enums.dart:79-84`

## Description
The `TransactionTypeX` extension incorrectly classifies `openingBalance` as a credit transaction when it should be a debit. This causes incorrect balance calculations for mid-cycle joiners.

An opening balance represents the amount a mid-cycle joiner owes for the months that have already passed before they joined. This is money the member **owes to the chitty** (a debit), not money they are **paying in** (a credit).

## Reproduction Conditions
- A member joins a chitty after it has started (mid-cycle joiner)
- An opening balance transaction is created to record their catch-up dues
- Balance calculations include this transaction

## Expected Behavior
When a mid-cycle joiner is added with an opening balance of AED 300 (for 3 missed months at AED 100/month):
- Their total dues should **increase** by AED 300
- The opening balance transaction should be treated as a **debit** (reduces their credit balance / increases what they owe)
- `TransactionType.openingBalance.isDebit` should return `true`
- `TransactionType.openingBalance.isCredit` should return `false`

## Actual Behavior
The current code classifies `openingBalance` as a credit:

```dart
// lib/core/domain/enums.dart:79-84
extension TransactionTypeX on TransactionType {
  // ...

  bool get isCredit =>
      this == TransactionType.payment ||
      this == TransactionType.openingBalance ||  // ← WRONG!
      this == TransactionType.discount;

  bool get isDebit => this == TransactionType.prizePayout;
  // openingBalance is NOT in isDebit!
}
```

This means:
- Opening balance transactions **increase** the member's balance instead of decreasing it
- A mid-cycle joiner with AED 300 opening balance would show AED 300 **extra credit** instead of AED 300 **owed**
- The balance calculation formula becomes: `balance = payments - dues + openingBalance` (wrong)
- Should be: `balance = payments - (dues + openingBalance)` (correct)

## Impact Analysis

### Example Scenario

**Chitty Details:**
- Duration: 12 months
- Monthly EMI: AED 100
- Total due: AED 1200

**Member joins in Month 4:**
- Catch-up amount (opening balance): AED 300 (for months 1-3)
- Remaining dues: AED 900 (for months 4-12)
- Total obligation: AED 1200

**Current (Buggy) Calculation:**
```dart
// Opening balance transaction: +30000 cents (treated as credit)
// Member pays first EMI: +10000 cents (credit)
// Balance = 30000 + 10000 = 40000 cents = AED 400 credit

// But they should owe: AED 400 (300 catch-up + 100 current month)
// System shows: AED 400 credit (completely wrong!)
```

**Correct Calculation:**
```dart
// Opening balance transaction: -30000 cents (debit)
// Member pays first EMI: +10000 cents (credit)
// Balance = -30000 + 10000 = -20000 cents = AED 200 debit (owed)

// They still owe: AED 300 (catch-up) - AED 100 (paid) = AED 200 ✓
```

## Suggested Fix

Move `openingBalance` from `isCredit` to `isDebit`:

```dart
// lib/core/domain/enums.dart
extension TransactionTypeX on TransactionType {
  String get value => name;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.payment,
    );
  }

  // FIXED: Removed openingBalance from credits
  bool get isCredit =>
      this == TransactionType.payment ||
      this == TransactionType.discount;

  // FIXED: Added openingBalance to debits
  bool get isDebit =>
      this == TransactionType.prizePayout ||
      this == TransactionType.openingBalance ||
      this == TransactionType.goldHandover ||
      this == TransactionType.settlementRefund;
}
```

## Additional Considerations

### Transaction Creation for Opening Balance

When creating an opening balance transaction, ensure the amount is stored as positive but treated as debit:

```dart
// In DatabaseService or TransactionService
Future<Transaction> recordOpeningBalance({
  required String slotId,
  required String chittiId,
  required int amountInCents,  // Positive amount representing what member owes
  required String userId,
  String? userName,
  int? slotNumber,
}) async {
  final txnRef = _db.child('transactions').push();
  final txnId = txnRef.key!;

  // Get current balance
  final balanceSnap = await _db
      .child('chittis/$chittiId/members/$slotId/balance')
      .get();

  final currentBalanceCents = // ... read current balance

  // Opening balance INCREASES what member owes (reduces their balance)
  final newBalanceCents = currentBalanceCents - amountInCents;  // ← MINUS, not plus

  final txn = Transaction(
    id: txnId,
    slotId: slotId,
    chittiId: chittiId,
    type: TransactionType.openingBalance,  // Type is debit
    amountInCents: amountInCents,          // Positive amount
    balanceBeforeInCents: currentBalanceCents,
    balanceAfterInCents: newBalanceCents,  // Reduced balance
    monthKey: _getCurrentMonthKey(),
    status: TransactionStatus.verified,
    notes: 'Opening balance for mid-cycle joiner',
    createdAt: DateTime.now(),
    userId: userId,
    userName: userName,
    slotNumber: slotNumber,
  );

  await txnRef.set(txn.toFirebase());
  // ... update balance and index

  return txn;
}
```

## Test Case

```dart
test('opening balance should reduce member balance (be a debit)', () async {
  final service = TransactionService();

  // Setup: Create a slot with zero balance
  await _setupSlot(slotId: 'test_slot', chittiId: 'test_chitti', initialPaid: 0);

  // Record opening balance of AED 300 (member owes for past months)
  final openingTxn = await service.recordOpeningBalance(
    slotId: 'test_slot',
    chittiId: 'test_chitti',
    amountInCents: 30000,  // AED 300
  );

  // Verify transaction type
  expect(openingTxn.type, equals(TransactionType.openingBalance));
  expect(openingTxn.isDebit, isTrue);
  expect(openingTxn.isCredit, isFalse);

  // Verify balance was REDUCED (member now owes money)
  final balanceSnap = await _db
      .child('chittis/test_chitti/members/test_slot/balance/totalPaid')
      .get();
  // Note: totalPaid might not change, but currentBalance should be negative
  final balanceData = await _db
      .child('chittis/test_chitti/members/test_slot/balance')
      .get();
  final currentBalance = (balanceData.value as Map)['currentBalance'] as num?;

  expect(currentBalance, equals(-30000));  // Should be -30000 cents (owes AED 300)

  // Member pays AED 100
  await service.recordPayment(
    slotId: 'test_slot',
    chittiId: 'test_chitti',
    amountInCents: 10000,
    monthKey: '2025-04',
  );

  // New balance should be -20000 cents (still owes AED 200)
  final newBalanceData = await _db
      .child('chittis/test_chitti/members/test_slot/balance')
      .get();
  final newBalance = (newBalanceData.value as Map)['currentBalance'] as num?;

  expect(newBalance, equals(-20000));  // -30000 + 10000 = -20000
});

test('TransactionType extension methods return correct values', () {
  // Credits
  expect(TransactionType.payment.isCredit, isTrue);
  expect(TransactionType.discount.isCredit, isTrue);

  // Debits
  expect(TransactionType.prizePayout.isDebit, isTrue);
  expect(TransactionType.openingBalance.isDebit, isTrue);  // FIXED
  expect(TransactionType.goldHandover.isDebit, isTrue);
  expect(TransactionType.settlementRefund.isDebit, isTrue);

  // Opening balance should NOT be credit
  expect(TransactionType.openingBalance.isCredit, isFalse);  // FIXED
});
```

## Verification Steps

After applying the fix:

1. Run existing tests to ensure no regressions
2. Create a test chitty and add a mid-cycle joiner
3. Verify opening balance transaction shows as debit
4. Verify member's balance reflects the amount owed
5. Make payments and verify balance reduces correctly

## Related Issues

- **Issue #007**: Month progression affects opening balance calculation
- **Issue #001**: Race condition could affect opening balance recording

## References

- `lib/core/models/transaction.dart` - Transaction model
- `lib/services/transaction_service.dart` - Transaction recording
- `lib/services/balance_calculator.dart` - Balance calculations
