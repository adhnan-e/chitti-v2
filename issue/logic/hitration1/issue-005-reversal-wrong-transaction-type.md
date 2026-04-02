# Issue: Reversal Creates Wrong Transaction Type

## Severity
**HIGH**

## Location
`lib/services/transaction_service.dart:155-175`

## Description
The `reverseTransaction` method creates a new transaction with `TransactionType.payment` instead of `TransactionType.reversal`. This breaks the audit trail and makes it impossible to distinguish between regular payments and reversals in financial reports.

## Reproduction Conditions
- A payment transaction is recorded
- The payment needs to be reversed (e.g., bounced cheque, wrong amount)
- `reverseTransaction` is called

## Expected Behavior
When reversing a transaction:
1. A new transaction should be created with `type: TransactionType.reversal`
2. The reversal should reference the original transaction via `linkedTransactionId`
3. The reversal amount should negate the original (positive becomes negative effect)
4. Financial reports should show reversals as a separate category
5. Audit trail should clearly show: Original Payment → Reversal

## Actual Behavior
The current implementation:

```dart
// lib/services/transaction_service.dart:155-175
Future<Transaction> reverseTransaction({
  required String transactionId,
  required String reversedBy,
  String? reason,
}) async {
  // Get original transaction
  final txnSnap = await _db.child('transactions/$transactionId').get();
  if (!txnSnap.exists) {
    throw Exception('Transaction not found');
  }

  final originalData = Map<String, dynamic>.from(txnSnap.value as Map);
  final original = Transaction.fromFirebase(transactionId, originalData);

  // Create reversal transaction
  return await recordPayment(  // ← WRONG! This creates a PAYMENT type
    slotId: original.slotId,
    chittiId: original.chittiId,
    amountInCents: -original.amountInCents, // Negative to reverse
    monthKey: original.monthKey,
    paymentMethod: original.paymentMethod,
    notes: reason ?? 'Reversal of ${original.id}',
    userId: original.userId,
    userName: original.userName,
    slotNumber: original.slotNumber,
  );
}
```

Problems:
1. Calls `recordPayment` which creates `type: TransactionType.payment`
2. Uses negative amount which may cause issues with balance calculations
3. Doesn't set `linkedTransactionId` to reference original transaction
4. Doesn't set `type: TransactionType.reversal`

### Transaction Type Confusion

| Original Transaction | Current (Buggy) Reversal | Correct Reversal |
|---------------------|-------------------------|------------------|
| `type: payment` | `type: payment` (negative) | `type: reversal` |
| `amount: +10000` | `amount: -10000` | `amount: 10000` (positive) |
| `linkedTransactionId: null` | `linkedTransactionId: null` | `linkedTransactionId: <original_id>` |

## Impact Analysis

### Audit Trail Issues

**Scenario**: Member pays AED 100, then payment bounces and is reversed.

**Current Behavior (Buggy)**:
```
Transaction 1: {type: payment, amount: 10000, notes: "EMI Payment"}
Transaction 2: {type: payment, amount: -10000, notes: "Reversal of txn1"}

Report shows:
- Total Payments: 2 transactions
- Payment Amount: 0 (10000 + -10000)
- Can't filter reversals separately!
```

**Correct Behavior**:
```
Transaction 1: {type: payment, amount: 10000, notes: "EMI Payment"}
Transaction 2: {type: reversal, amount: 10000, linkedTransactionId: txn1, notes: "Bounced cheque"}

Report shows:
- Total Payments: 1 transaction, AED 100
- Total Reversals: 1 transaction, AED 100
- Net Balance: 0
- Clear audit trail!
```

### Balance Calculation Issues

The `effectiveAmountInCents` getter in Transaction model:

```dart
// lib/core/models/transaction.dart
int get effectiveAmountInCents {
  if (isReversal) return -amountInCents; // Reversals negate
  return isCredit ? amountInCents : -amountInCents;
}
```

With the buggy implementation:
- Reversal has `type: payment`, so `isReversal` is false
- Reversal has negative `amountInCents`
- `isCredit` for payment is true
- Effective amount = `-10000` (correct by accident, but wrong logic)

If someone fixes the amount to be positive, the calculation breaks:
- Reversal with `type: payment` and `amount: 10000`
- Effective amount = `+10000` (WRONG! Should be `-10000`)

### Reporting Issues

Financial reports that filter by transaction type:

```dart
// Get all payments for the month
final payments = transactions
    .where((t) => t.type == TransactionType.payment)
    .toList();

// With buggy reversals:
// - Includes reversal transactions (wrong!)
// - Some have negative amounts (confusing!)
// - Can't distinguish actual payments from reversals
```

## Suggested Fix

Create a dedicated method for reversals:

```dart
// lib/services/transaction_service.dart
Future<Transaction> reverseTransaction({
  required String transactionId,
  required String reversedBy,
  String? reason,
}) async {
  // Get original transaction
  final txnSnap = await _db.child('transactions/$transactionId').get();
  if (!txnSnap.exists) {
    throw Exception('Transaction not found');
  }

  final originalData = Map<String, dynamic>.from(txnSnap.value as Map);
  final original = Transaction.fromFirebase(transactionId, originalData);

  final txnRef = _db.child('transactions').push();
  final txnId = txnRef.key!;
  final now = DateTime.now();

  // Read current balance
  final slotSnap = await _db
      .child('chittis/${original.chittiId}/members/${original.slotId}/balance')
      .get();

  int currentBalanceCents = 0;
  if (slotSnap.exists && slotSnap.value != null) {
    final balance = Map<String, dynamic>.from(slotSnap.value as Map);
    currentBalanceCents = CurrencyUtils.toCents(
      (balance['totalPaid'] as num?)?.toDouble() ?? 0,
    );
  }

  // Reversal negates the original effect
  // If original was credit (+10000), reversal is debit (-10000)
  final reversalAmountCents = -original.amountInCents;
  final newBalanceCents = currentBalanceCents + reversalAmountCents;

  // Create proper REVERSAL transaction
  final reversalTxn = Transaction(
    id: txnId,
    slotId: original.slotId,
    chittiId: original.chittiId,
    type: TransactionType.reversal,  // ← Correct type!
    amountInCents: original.amountInCents,  // Positive amount (same as original)
    balanceBeforeInCents: currentBalanceCents,
    balanceAfterInCents: newBalanceCents,
    monthKey: original.monthKey,
    status: TransactionStatus.verified,  // Reversals are immediately verified
    paymentMethod: original.paymentMethod,
    linkedTransactionId: original.id,  // ← Link to original!
    notes: reason ?? 'Reversal of ${original.id}: ${original.notes ?? ""}',
    receiptNumber: null,  // Reversals don't generate receipts
    createdAt: now,
    verifiedAt: now,
    verifiedBy: reversedBy,
    userId: original.userId,
    userName: original.userName,
    slotNumber: original.slotNumber,
  );

  // Write reversal transaction
  await txnRef.set(reversalTxn.toFirebase());

  // Update slot balance
  await _db
      .child('chittis/${original.chittiId}/members/${original.slotId}/balance')
      .update({
        'totalPaid': CurrencyUtils.fromCents(newBalanceCents),
        'lastUpdated': ServerValue.timestamp,
      });

  // Update transaction index
  await _db
      .child('chittis/${original.chittiId}/transactionIndex/${original.slotId}/$txnId')
      .set(true);

  return reversalTxn;
}
```

## Test Case

```dart
test('reversal should create transaction with correct type and link', () async {
  final service = TransactionService();

  // Setup: Record a payment
  final paymentTxn = await service.recordPayment(
    slotId: 'slot1',
    chittiId: 'chitti1',
    amountInCents: 10000,  // AED 100
    monthKey: '2025-01',
    paymentMethod: PaymentMethod.cheque,
  );

  // Verify payment was recorded correctly
  expect(paymentTxn.type, equals(TransactionType.payment));
  expect(paymentTxn.amountInCents, equals(10000));
  expect(paymentTxn.isCredit, isTrue);

  // Reverse the payment
  final reversalTxn = await service.reverseTransaction(
    transactionId: paymentTxn.id,
    reversedBy: 'admin1',
    reason: 'Cheque bounced',
  );

  // Verify reversal transaction
  expect(reversalTxn.type, equals(TransactionType.reversal));  // Should be reversal!
  expect(reversalTxn.amountInCents, equals(10000));  // Positive, same as original
  expect(reversalTxn.linkedTransactionId, equals(paymentTxn.id));  // Linked!
  expect(reversalTxn.isReversal, isTrue);
  expect(reversalTxn.isDebit, isTrue);  // Reversals are debits
  expect(reversalTxn.notes, contains('Reversal of ${paymentTxn.id}'));
  expect(reversalTxn.notes, contains('Cheque bounced'));

  // Verify effective amount negates original
  expect(paymentTxn.effectiveAmountInCents, equals(10000));   // +10000
  expect(reversalTxn.effectiveAmountInCents, equals(-10000)); // -10000

  // Verify balance was reduced
  final balanceSnap = await _db
      .child('chittis/chitti1/members/slot1/balance/totalPaid')
      .get();
  final balance = (balanceSnap.value as num?)?.toDouble() ?? 0.0;
  expect(balance, equals(0.0));  // Should be back to 0 after reversal
});

test('reversals should be filterable in reports', () async {
  final service = TransactionService();

  // Create some transactions
  await service.recordPayment(slotId: 'slot1', chittiId: 'chitti1', amountInCents: 10000, monthKey: '2025-01');
  await service.recordPayment(slotId: 'slot1', chittiId: 'chitti1', amountInCents: 10000, monthKey: '2025-02');
  final paymentToReverse = await service.recordPayment(slotId: 'slot1', chittiId: 'chitti1', amountInCents: 10000, monthKey: '2025-03');
  await service.reverseTransaction(transactionId: paymentToReverse.id, reversedBy: 'admin1');

  // Get all transactions
  final allTransactions = await service.getChittiTransactions('chitti1');

  // Filter by type
  final payments = allTransactions.where((t) => t.type == TransactionType.payment).toList();
  final reversals = allTransactions.where((t) => t.type == TransactionType.reversal).toList();

  expect(payments.length, equals(3));  // All 3 payments
  expect(reversals.length, equals(1));  // Only the reversal

  // Calculate totals
  final totalPayments = payments.fold(0, (sum, t) => sum + t.amountInCents);
  final totalReversals = reversals.fold(0, (sum, t) => sum + t.amountInCents);

  expect(totalPayments, equals(30000));  // AED 300
  expect(totalReversals, equals(10000)); // AED 100
  expect(totalPayments - totalReversals, equals(20000));  // Net AED 200
});
```

## Verification Steps

1. Create a payment transaction
2. Reverse the payment
3. Verify reversal has `type: reversal`
4. Verify reversal has `linkedTransactionId` set
5. Verify balance is correctly adjusted
6. Run reports filtering by transaction type
7. Verify audit trail shows clear payment → reversal relationship

## Related Issues

- **Issue #001**: Race condition in transaction recording (affects reversal balance update)
- **Issue #002**: Credit/debit logic for transaction types (related to reversal classification)

## References

- `lib/core/models/transaction.dart` - Transaction model with `isReversal` getter
- `lib/core/domain/enums.dart` - `TransactionType.reversal` enum
- `lib/services/transaction_service.dart` - Transaction recording
