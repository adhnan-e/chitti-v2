# Issue: Duplicate Winner Check Incomplete (Race Condition)

## Severity
**HIGH**

## Location
`lib/services/lucky_draw_manager.dart:105-110`

## Description
The duplicate winner check in `assignWinner` has a race condition. It reads existing winners, then checks if the slot has won, but another concurrent operation could declare the same slot as winner between the read and the write.

## Reproduction Conditions
- Two organizers simultaneously declare winners for the same month
- Automated lucky draw runs while organizer manually assigns a winner
- Network latency causes delayed writes allowing overlapping operations

## Expected Behavior
The winner declaration should be atomic:
1. Check if month already has a winner
2. Check if slot already won in this chitty
3. Write winner record
4. All steps should be atomic - no other operation can interleave

## Actual Behavior
The current code:

```dart
// lib/services/lucky_draw_manager.dart:95-125
Future<DrawResult> assignWinner({...}) async {
  try {
    // Check 1: If month already has a winner
    final existingWinner = await _db
        .child('chittis/$chittiId/winners/$month')
        .get();
    if (existingWinner.exists) {
      return DrawResult.failure('A winner has already been declared for $month');
    }

    // Check 2: If slot has already won
    final allWinners = await getChittiWinners(chittiId);  // ← Separate read!
    final hasWon = allWinners.any((w) => w.slotId == slotId);
    if (hasWon) {
      return DrawResult.failure('This slot has already won in this chitty');
    }

    // Process winner (makes multiple writes)
    return _processWinner(...);
  } catch (e) {
    return DrawResult.failure('Winner assignment failed: $e');
  }
}
```

### Race Condition Timeline

```
Time    Operation A                    Operation B              Database State
────    ───────────                    ───────────              ──────────────
T1      Check month winner (none)                                  winners/2025-03: empty
T2                                     Check month winner (none)  winners/2025-03: empty
T3      Check slot winner (slot1 never won)                       winners: still empty
T4                                     Check slot winner          winners: still empty
                                         (slot1 never won)
T5      Start _processWinner                                      winners: empty
T6                                     Start _processWinner       winners: empty
T7      Write winners/2025-03 = slot1                             winners/2025-03: slot1
T8                                     Write winners/2025-03 =    winners/2025-03: slot2
                                         slot2 (OVERWRITES!)      ← BUG! Both succeeded!
```

Result: Both operations succeed, but the second one overwrites the first. The first winner record is lost, but the global `lucky_draws` collection has both entries, causing data inconsistency.

## Impact Analysis

### Data Inconsistency

After the race condition:
- `chittis/{id}/winners/{month}` has one winner (the last write)
- `lucky_draws/{id}` has TWO winners for the same month
- `winners/{id}` (global) has TWO winners for the same month
- Both slots think they won, but only one is recorded in the chitty

### Financial Impact

If both winners receive prize payouts:
- Organizer pays out prize twice for the same month
- Chitty funds depleted incorrectly
- Accounting reconciliation fails

### Audit Trail Corruption

Reports show:
- Month 2025-03: 2 winners declared
- But chitty only has 1 winner slot per month
- Impossible to reconcile which is correct

## Suggested Fix

Use Firebase database transaction for atomic check-and-write:

```dart
// lib/services/lucky_draw_manager.dart
Future<DrawResult> assignWinner({
  required String chittiId,
  required String slotId,
  required String month,
  String? prizeDescription,
  double? prizeAmount,
}) async {
  try {
    final winnerRef = _db.child('chittis/$chittiId/winners/$month');
    final now = DateTime.now();

    // ATOMIC: Check and write in single transaction
    final result = await winnerRef.runTransaction((currentData) {
      if (currentData != null) {
        // Month already has a winner - abort transaction
        return Transaction.abort();
      }

      // Get slot details (need to fetch outside transaction)
      // This is a limitation - we need slot data for the winner record
      // Solution: Do minimal check in transaction, full validation before

      // Create winner data (will be populated fully before commit)
      return <String, dynamic>{
        'chittiId': chittiId,
        'slotId': slotId,
        'month': month,
        'declaredAt': now.toIso8601String(),
        // ... other fields populated by _processWinner
      };
    });

    if (result.committed) {
      // Transaction succeeded - now process the full winner record
      return _processWinner(...);
    } else {
      return DrawResult.failure('A winner has already been declared for $month');
    }
  } catch (e) {
    return DrawResult.failure('Winner assignment failed: $e');
  }
}
```

### Better Approach: Two-Phase with Lock

```dart
Future<DrawResult> assignWinner({...}) async {
  try {
    final winnerRef = _db.child('chittis/$chittiId/winners/$month');
    final slotWinnerRef = _db.child('chittis/$chittiId/members/$slotId');

    // Phase 1: Validate (with read of current state)
    final monthWinnerSnap = await winnerRef.get();
    if (monthWinnerSnap.exists) {
      return DrawResult.failure('A winner has already been declared for $month');
    }

    // Check if slot already won (read all winners)
    final allWinnersSnap = await _db.child('chittis/$chittiId/winners').get();
    if (allWinnersSnap.exists) {
      final winnersData = Map<String, dynamic>.from(allWinnersSnap.value as Map);
      for (var winnerEntry in winnersData.values) {
        final winnerMap = Map<String, dynamic>.from(winnerEntry as Map);
        if (winnerMap['slotId'] == slotId) {
          return DrawResult.failure('This slot has already won in this chitty');
        }
      }
    }

    // Phase 2: Atomic write with optimistic locking
    // Use a transaction that validates again before committing
    final result = await winnerRef.runTransaction((currentData) {
      if (currentData != null) {
        // Someone else wrote a winner between our read and now
        return Transaction.abort();
      }

      // Return placeholder - actual data written by _processWinner
      return <String, dynamic>{
        'pending': true,
        'slotId': slotId,
        'timestamp': ServerValue.timestamp,
      };
    });

    if (!result.committed) {
      return DrawResult.failure('A winner was declared while processing. Please try again.');
    }

    // Phase 3: Process winner (full data write)
    return _processWinner(...);

  } catch (e) {
    return DrawResult.failure('Winner assignment failed: $e');
  }
}
```

### Best Approach: Single Atomic Operation

Combine all winner processing into a single transaction:

```dart
Future<DrawResult> declareWinner({...}) async {
  final dbRef = _db;

  try {
    // Single atomic operation for everything
    await dbRef.runTransaction((currentData) {
      // 1. Check month doesn't have winner
      final monthWinner = currentData.child('chittis/$chittiId/winners/$month').value;
      if (monthWinner != null) {
        throw Exception('Winner already declared for $month');
      }

      // 2. Check slot hasn't won before
      final allWinners = currentData.child('chittis/$chittiId/winners').value as Map? ?? {};
      for (var winnerData in allWinners.values) {
        if ((winnerData as Map)['slotId'] == slotId) {
          throw Exception('Slot already won');
        }
      }

      // 3. Write all updates atomically
      // (This requires restructuring to return updates map)
      return currentData;  // Simplified - actual implementation more complex
    });

    return DrawResult.success(...);
  } catch (e) {
    return DrawResult.failure(e.toString());
  }
}
```

## Test Case

```dart
test('concurrent winner declarations should not both succeed', () async {
  final manager = LuckyDrawManager();

  // Setup: Create chitty with multiple slots
  final chittiId = await _createChitti(name: 'Test Chitty');
  final slotId1 = await _addSlotToChitti(chittiId, userId: 'user1');
  final slotId2 = await _addSlotToChitti(chittiId, userId: 'user2');

  // Execute: Two concurrent winner declarations for same month
  final future1 = manager.assignWinner(
    chittiId: chittiId,
    slotId: slotId1,
    month: '2025-03',
  );

  final future2 = manager.assignWinner(
    chittiId: chittiId,
    slotId: slotId2,
    month: '2025-03',  // Same month!
  );

  final results = await Future.wait([future1, future2]);

  // One should succeed, one should fail
  final successCount = results.where((r) => r.success).length;
  final failureCount = results.where((r) => !r.success).length;

  expect(successCount, equals(1));  // Exactly one winner
  expect(failureCount, equals(1));  // One failure

  // Verify failure reason
  final failure = results.firstWhere((r) => !r.success);
  expect(failure.error, contains('already'));

  // Verify only one winner in database
  final winnersSnap = await _db.child('chittis/$chittiId/winners/2025-03').get();
  expect(winnersSnap.exists, isTrue);

  // Verify only one global lucky_draw entry for this chitti+month
  final allDrawsSnap = await _db.child('lucky_draws').get();
  final allDraws = Map<String, dynamic>.from(allDrawsSnap.value as Map);
  final matchingDraws = allDraws.values.where((v) {
    final draw = Map<String, dynamic>.from(v as Map);
    return draw['chittiId'] == chittiId && draw['month'] == '2025-03';
  });
  expect(matchingDraws.length, equals(1));
});
```

## Verification Steps

1. Test concurrent winner declarations for same month
2. Test concurrent winner declarations for same slot
3. Verify only one winner per month in database
4. Verify global lucky_draws collection is consistent
5. Test with network delay simulation
6. Verify error messages are clear when race condition detected

## Related Issues

- **Issue #001**: Race condition in transaction recording (similar atomicity problem)
- **Issue #004**: Slot status not updated (affects duplicate detection)

## References

- [Firebase Database Transactions](https://firebase.google.com/docs/database/android/read-and-write#save_data_as_transactions)
- `lib/services/lucky_draw_manager.dart` - Winner selection logic
- `lib/core/models/winner.dart` - Winner model
