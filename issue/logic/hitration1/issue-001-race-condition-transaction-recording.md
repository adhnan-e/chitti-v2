# Issue: Race Condition in Transaction Recording

## Severity
**CRITICAL**

## Location
`lib/services/transaction_service.dart:47-85`

## Description
The `recordPayment` method performs a non-atomic read-modify-write operation on the slot balance. This creates a race condition where concurrent payments can overwrite each other's balance updates, leading to financial data corruption.

The current flow:
1. Read current balance from database
2. Calculate new balance
3. Write transaction document
4. Update slot balance

Between steps 1 and 4, another concurrent payment could complete, and its balance update would be overwritten.

## Reproduction Conditions
- Two or more payments recorded for the same slot within milliseconds
- High-load scenarios (e.g., payment deadline day with multiple users paying simultaneously)
- Can be reproduced in tests using concurrent async operations

## Expected Behavior
All concurrent payments should be applied correctly. If slot has balance of AED 500 and two payments of AED 100 each are made concurrently, final balance should be AED 700.

## Actual Behavior
Due to the race condition, one payment's balance update overwrites the other. Final balance could be AED 600 instead of AED 700 (one payment "lost").

### Race Condition Timeline

```
Time    Transaction A              Transaction B              Database Balance
────    ─────────────              ─────────────              ────────────────
T1      Read balance (500)                                    500
T2                                   Read balance (500)       500
T3      Calculate new (600)                                   500
T4                                   Calculate new (600)      500
T5      Write transaction A                                   500
T6                                   Write transaction B      500
T7      Update balance (600)                                  600
T8                                   Update balance (600)     600  ← Should be 700!
```

## Suggested Fix

Use Firebase database transactions for atomic read-modify-write:

```dart
Future<Transaction> recordPayment({
  required String slotId,
  required String chittiId,
  required int amountInCents,
  required String monthKey,
  PaymentMethod paymentMethod = PaymentMethod.cash,
  TransactionStatus status = TransactionStatus.pending,
  String? referenceNumber,
  String? notes,
  String? userId,
  String? userName,
  int? slotNumber,
}) async {
  final txnRef = _db.child('transactions').push();
  final txnId = txnRef.key!;
  final receiptNumber = _generateReceiptNumber(chittiId);
  final now = DateTime.now();

  // Create transaction record first (no balance dependency)
  final createdTxn = Transaction(
    id: txnId,
    slotId: slotId,
    chittiId: chittiId,
    type: TransactionType.payment,
    amountInCents: amountInCents,
    balanceBeforeInCents: 0,  // Will be updated atomically
    balanceAfterInCents: 0,   // Will be updated atomically
    monthKey: monthKey,
    status: status,
    paymentMethod: paymentMethod,
    referenceNumber: referenceNumber,
    notes: notes,
    receiptNumber: receiptNumber,
    createdAt: now,
    userId: userId,
    userName: userName,
    slotNumber: slotNumber,
  );

  // ATOMIC OPERATION: Update balance and transaction together
  await _db.child('chittis/$chittiId/members/$slotId/balance').runTransaction((currentBalanceData) {
    if (currentBalanceData == null) {
      currentBalanceData = <String, dynamic>{
        'totalPaid': 0.0,
      };
    }

    final currentBalanceMap = Map<String, dynamic>.from(currentBalanceData as Map);
    final currentTotalPaid = (currentBalanceMap['totalPaid'] as num?)?.toDouble() ?? 0.0;
    final newTotalPaid = currentTotalPaid + (amountInCents / 100.0);

    // Update the balance data
    currentBalanceMap['totalPaid'] = newTotalPaid;
    currentBalanceMap['lastPaymentDate'] = now.toIso8601String().split('T')[0];
    currentBalanceMap['lastUpdated'] = ServerValue.timestamp;

    // Update transaction with correct balance values
    createdTxn.balanceBeforeInCents = (currentTotalPaid * 100).toInt();
    createdTxn.balanceAfterInCents = (newTotalPaid * 100).toInt();

    return currentBalanceMap;
  });

  // Write transaction document with updated balance values
  await txnRef.set(createdTxn.toFirebase());

  // Update transaction index
  await _db.child('chittis/$chittiId/transactionIndex/$slotId/$txnId').set(true);

  return createdTxn;
}
```

**Note**: The above fix shows the concept. The actual implementation needs to handle the fact that `Transaction` is immutable (freezed), so balance values may need to be set in a two-step process or the transaction document should be updated after the balance transaction completes.

## Alternative Fix (Two-Phase Commit)

```dart
Future<Transaction> recordPayment({...}) async {
  // Phase 1: Atomic balance update
  final balanceRef = _db.child('chittis/$chittiId/members/$slotId/balance');
  final result = await balanceRef.runTransaction((currentData) {
    if (currentData == null) {
      return <String, dynamic>{'totalPaid': 0.0};
    }
    final map = Map<String, dynamic>.from(currentData as Map);
    final currentPaid = (map['totalPaid'] as num?)?.toDouble() ?? 0.0;
    map['totalPaid'] = currentPaid + (amountInCents / 100.0);
    map['lastUpdated'] = ServerValue.timestamp;
    return map;
  });

  // Extract balance values from transaction result
  final snapshot = await balanceRef.get();
  final balanceData = Map<String, dynamic>.from(snapshot.value as Map);
  final newTotalPaid = (balanceData['totalPaid'] as num?)?.toDouble() ?? 0.0;

  // Calculate balance before (need to track this differently or store in transaction)
  final balanceBeforeCents = ((newTotalPaid * 100) - amountInCents).toInt();
  final balanceAfterCents = (newTotalPaid * 100).toInt();

  // Phase 2: Create transaction with known balance values
  final txnRef = _db.child('transactions').push();
  final txnId = txnRef.key!;

  final createdTxn = Transaction(
    id: txnId,
    slotId: slotId,
    chittiId: chittiId,
    type: TransactionType.payment,
    amountInCents: amountInCents,
    balanceBeforeInCents: balanceBeforeCents,
    balanceAfterInCents: balanceAfterCents,
    monthKey: monthKey,
    status: status,
    paymentMethod: paymentMethod,
    receiptNumber: _generateReceiptNumber(chittiId),
    createdAt: DateTime.now(),
    // ... other fields
  );

  await txnRef.set(createdTxn.toFirebase());
  await _db.child('chittis/$chittiId/transactionIndex/$slotId/$txnId').set(true);

  return createdTxn;
}
```

## Test Case

```dart
test('concurrent payments should all be applied correctly', () async {
  final service = TransactionService();
  final slotId = 'test_slot';
  final chittiId = 'test_chitti';

  // Setup: Initial balance of 50000 cents (AED 500)
  await _db.child('chittis/$chittiId/members/$slotId/balance').set({
    'totalPaid': 500.0,
  });

  // Execute: 10 concurrent payments of 10000 cents (AED 100) each
  final futures = List.generate(10, (i) => service.recordPayment(
    slotId: slotId,
    chittiId: chittiId,
    amountInCents: 10000,
    monthKey: '2025-01',
  ));

  await Future.wait(futures);

  // Verify: Final balance should be 500 + (10 * 100) = 1500 AED = 150000 cents
  final balanceSnap = await _db
      .child('chittis/$chittiId/members/$slotId/balance/totalPaid')
      .get();
  final finalBalance = (balanceSnap.value as num?)?.toDouble() ?? 0.0;

  expect(finalBalance, equals(1500.0)); // Should be 1500.0, not less

  // Also verify all 10 transactions were created
  final txnSnap = await _db
      .child('chittis/$chittiId/transactionIndex/$slotId')
      .get();
  final txnCount = (txnSnap.value as Map?)?.length ?? 0;
  expect(txnCount, equals(10));
});
```

## Related Issues

- **Issue #005**: Reversal transactions have similar race condition
- **Issue #006**: Lucky draw winner selection has similar atomicity issue


## References

- [Firebase Database Transactions](https://firebase.google.com/docs/database/android/read-and-write#save_data_as_transactions)
- [Handling Concurrent Access in Realtime Database](https://firebase.google.com/docs/database/web/read-and-write#basic_write)
