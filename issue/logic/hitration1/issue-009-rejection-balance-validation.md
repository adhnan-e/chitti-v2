# Issue: Missing Validation in Payment Rejection Balance Update

## Severity
**MEDIUM**

## Location
`lib/services/transaction_service.dart:120-145`

## Description
The `rejectPayment` method updates the slot balance when rejecting a payment but doesn't verify the transaction's current status. This allows rejecting already-verified or already-rejected transactions, causing incorrect balance adjustments.

## Reproduction Conditions
- A payment is recorded with `pending` status
- Organizer verifies the payment (status → `verified`)
- Later, someone attempts to reject the same payment
- The rejection succeeds and incorrectly reduces the balance

## Expected Behavior
When rejecting a payment:
1. Verify the transaction exists
2. Verify the transaction is in `pending` status (not yet verified)
3. Only then update the balance and change status to `rejected`
4. If already verified, require a reversal instead of rejection
5. If already rejected, return an error (idempotent operation)

## Actual Behavior
The current code:

```dart
// lib/services/transaction_service.dart:120-145
Future<void> rejectPayment({
  required String transactionId,
  required String rejectedBy,
  String? reason,
}) async {
  // Get the transaction
  final txnSnap = await _db.child('transactions/$transactionId').get();
  if (!txnSnap.exists) {
    throw Exception('Transaction not found');
  }

  final txnData = Map<String, dynamic>.from(txnSnap.value as Map);
  final txn = Transaction.fromFirebase(transactionId, txnData);

  // Update transaction status
  await _db.child('transactions/$transactionId').update({
    'status': TransactionStatus.rejected.name,
    'notes': reason ?? 'Payment rejected',
  });

  // Reverse the balance change
  final balanceSnap = await _db
      .child('chittis/${txn.chittiId}/members/${txn.slotId}/balance')
      .get();

  if (balanceSnap.exists && balanceSnap.value != null) {
    final balance = Map<String, dynamic>.from(balanceSnap.value as Map);
    final totalPaid = (balance['totalPaid'] as num?)?.toDouble() ?? 0;
    final newTotalPaid = totalPaid - txn.amount;  // ← Always subtracts!

    await _db
        .child('chittis/${txn.chittiId}/members/${txn.slotId}/balance')
        .update({'totalPaid': newTotalPaid});
  }
}
```

### Missing Validations

1. **No status check**: Doesn't verify transaction is `pending`
2. **No idempotency**: Can reject same transaction multiple times
3. **No verified handling**: Verified transactions should require reversal, not rejection

### Attack/Abuse Scenario

```
1. Member pays AED 100 → Transaction created (pending)
2. Organizer verifies → Transaction status = verified, balance = +100
3. Malicious actor calls rejectPayment()
4. Balance reduced by 100 → balance = 0
5. Transaction status = rejected
6. Member's payment is "lost" - shows as rejected but money was verified!
```

### Double Rejection Scenario

```
1. Payment pending: AED 100, balance = 500
2. Reject called: balance = 400, status = rejected
3. Reject called again (bug/retry): balance = 300, status = rejected
4. Balance incorrectly reduced twice!
```

## Impact Analysis

### Financial Loss
- Members lose credit for verified payments
- Organizer may think payment wasn't made
- Disputes over payment status

### Audit Trail Corruption
- Transaction shows `rejected` but balance was affected
- Impossible to distinguish legitimate rejections from errors
- Reconciliation fails

### Security Risk
- No authorization check on `rejectedBy`
- Anyone who can call the method can reject payments
- Verified payments can be undone without proper reversal audit

## Suggested Fix

Add comprehensive validation:

```dart
Future<void> rejectPayment({
  required String transactionId,
  required String rejectedBy,
  String? reason,
}) async {
  final txnSnap = await _db.child('transactions/$transactionId').get();
  if (!txnSnap.exists) {
    throw Exception('Transaction not found');
  }

  final txnData = Map<String, dynamic>.from(txnSnap.value as Map);
  final txn = Transaction.fromFirebase(transactionId, txnData);

  // VALIDATION 1: Check transaction type is payment
  if (txn.type != TransactionType.payment) {
    throw Exception('Only payment transactions can be rejected');
  }

  // VALIDATION 2: Check current status
  if (txn.status == TransactionStatus.verified) {
    throw Exception(
      'Cannot reject a verified payment. Use reverseTransaction() instead.',
    );
  }

  if (txn.status == TransactionStatus.rejected) {
    // Idempotent: Already rejected, no further action needed
    print('Transaction $transactionId already rejected');
    return;
  }

  if (txn.status != TransactionStatus.pending) {
    throw Exception('Cannot reject transaction with status: ${txn.status}');
  }

  // Now safe to reject
  await _db.child('transactions/$transactionId').update({
    'status': TransactionStatus.rejected.name,
    'notes': reason ?? 'Payment rejected',
    'rejectedAt': DateTime.now().toIso8601String(),
    'rejectedBy': rejectedBy,
  });

  // Reverse the balance change
  final balanceSnap = await _db
      .child('chittis/${txn.chittiId}/members/${txn.slotId}/balance')
      .get();

  if (balanceSnap.exists && balanceSnap.value != null) {
    final balance = Map<String, dynamic>.from(balanceSnap.value as Map);
    final totalPaid = (balance['totalPaid'] as num?)?.toDouble() ?? 0;
    final newTotalPaid = totalPaid - txn.amount;

    // Ensure balance doesn't go negative due to rejection
    if (newTotalPaid < 0) {
      print('WARNING: Rejection would cause negative balance');
      // Optionally: throw Exception or clamp to 0
    }

    await _db
        .child('chittis/${txn.chittiId}/members/${txn.slotId}/balance')
        .update({
          'totalPaid': newTotalPaid.clamp(0, double.infinity),
          'lastUpdated': ServerValue.timestamp,
        });
  }
}
```

## Test Case

```dart
test('cannot reject already verified payment', () async {
  final service = TransactionService();

  // Setup: Record and verify a payment
  final paymentTxn = await service.recordPayment(
    slotId: 'slot1',
    chittiId: 'chitti1',
    amountInCents: 10000,
    monthKey: '2025-01',
  );

  await service.verifyPayment(
    transactionId: paymentTxn.id,
    verifiedBy: 'admin1',
  );

  // Attempt to reject verified payment
  expectLater(
    () => service.rejectPayment(
      transactionId: paymentTxn.id,
      rejectedBy: 'admin1',
      reason: 'Testing',
    ),
    throwsA(isA<Exception>().having(
      (e) => e.toString(),
      'message',
      contains('Cannot reject a verified payment'),
    )),
  );

  // Verify balance unchanged
  final balanceSnap = await _db
      .child('chittis/chitti1/members/slot1/balance/totalPaid')
      .get();
  final balance = (balanceSnap.value as num?)?.toDouble() ?? 0.0;
  expect(balance, equals(100.0));  // Should still be AED 100
});

test('rejecting already rejected transaction should be idempotent', () async {
  final service = TransactionService();

  // Setup: Record and reject a payment
  final paymentTxn = await service.recordPayment(
    slotId: 'slot1',
    chittiId: 'chitti1',
    amountInCents: 10000,
    monthKey: '2025-01',
  );

  await service.rejectPayment(
    transactionId: paymentTxn.id,
    rejectedBy: 'admin1',
    reason: 'Testing',
  );

  final balanceBeforeSnap = await _db
      .child('chittis/chitti1/members/slot1/balance/totalPaid')
      .get();
  final balanceBefore = (balanceBeforeSnap.value as num?)?.toDouble() ?? 0.0;

  // Reject again (should be no-op)
  await service.rejectPayment(
    transactionId: paymentTxn.id,
    rejectedBy: 'admin1',
    reason: 'Testing again',
  );

  // Balance should be unchanged
  final balanceAfterSnap = await _db
      .child('chittis/chitti1/members/slot1/balance/totalPaid')
      .get();
  final balanceAfter = (balanceAfterSnap.value as num?)?.toDouble() ?? 0.0;

  expect(balanceAfter, equals(balanceBefore));  // No change
});

test('reject pending payment should reduce balance', () async {
  final service = TransactionService();

  // Setup: Record pending payment
  final paymentTxn = await service.recordPayment(
    slotId: 'slot1',
    chittiId: 'chitti1',
    amountInCents: 10000,
    monthKey: '2025-01',
    status: TransactionStatus.pending,
  );

  // Reject the pending payment
  await service.rejectPayment(
    transactionId: paymentTxn.id,
    rejectedBy: 'admin1',
    reason: 'Insufficient funds',
  );

  // Verify transaction status
  final txn = await service.getTransaction(paymentTxn.id);
  expect(txn!.status, equals(TransactionStatus.rejected));

  // Verify balance reduced
  final balanceSnap = await _db
      .child('chittis/chitti1/members/slot1/balance/totalPaid')
      .get();
  final balance = (balanceSnap.value as num?)?.toDouble() ?? 0.0;
  expect(balance, equals(0.0));  // Should be back to 0
});
```

## Verification Steps

1. Test rejection of pending payment (should succeed)
2. Test rejection of verified payment (should fail)
3. Test rejection of already rejected payment (should be no-op)
4. Test rejection of non-payment transactions (discount, reversal, etc.)
5. Verify balance changes only for valid rejections
6. Check audit trail shows correct rejection info

## Related Issues

- **Issue #005**: Reversal creates wrong transaction type (related payment correction flow)
- **Issue #001**: Race condition in transaction recording (affects rejection balance update)

## References

- `lib/core/models/transaction.dart` - Transaction model with status
- `lib/core/domain/enums.dart` - `TransactionStatus` enum
- `lib/services/transaction_service.dart` - Current implementation
