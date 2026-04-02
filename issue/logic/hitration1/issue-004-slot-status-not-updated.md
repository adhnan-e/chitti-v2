# Issue: Slot Status Not Updated After Win

## Severity
**HIGH**

## Location
`lib/services/lucky_draw_manager.dart:200-230`

## Description
When a slot wins the lucky draw, the `SlotStatus` field is never updated from `active` to `won`. This means the system doesn't track that a slot has already won, potentially allowing the same slot to be selected again in future months.

## Reproduction Conditions
- A slot wins the lucky draw in month X
- Lucky draw is run again in month X+1
- The `getEligibleSlots` method filters by `SlotStatus.active`
- Since the winning slot's status was never updated, it remains eligible

## Expected Behavior
After a slot wins:
1. Slot status should change from `active` to `won`
2. The slot should be excluded from future lucky draws
3. The slot's EMI should be reduced by the discount amount
4. The slot should continue paying reduced EMIs until completion

## Actual Behavior
The current winner processing code updates many fields but NOT the slot status:

```dart
// lib/services/lucky_draw_manager.dart:200-230
// Atomic write: Winner + Discount transaction + Balance update
final updates = <String, dynamic>{
  // Winner in chitty
  'chittis/$chittiId/winners/$month': winnerRecord.toFirebase(),

  // Global winners collection
  'winners/$winnerId': {...},

  // Discount transaction
  'transactions/$txnId': discountTxn.toFirebase(),

  // Update slot balance (many fields updated)
  'chittis/$chittiId/members/${winner.id}/balance/totalDue': newTotalDue,
  'chittis/$chittiId/members/${winner.id}/balance/currentBalance': ...,
  'chittis/$chittiId/members/${winner.id}/balance/currentMonthlyAmount': newMonthlyEMI,
  'chittis/$chittiId/members/${winner.id}/balance/originalMonthlyAmount': originalMonthlyEMI,
  'chittis/$chittiId/members/${winner.id}/balance/isWinner': true,
  'chittis/$chittiId/members/${winner.id}/balance/winnerMonth': month,
  'chittis/$chittiId/members/${winner.id}/balance/discountStartMonth': discountStartMonth,
  'chittis/$chittiId/members/${winner.id}/balance/discountPerMonth': discountPerMonth,
  'chittis/$chittiId/members/${winner.id}/balance/totalDiscount': totalDiscount,
  'chittis/$chittiId/members/${winner.id}/balance/prizeAmount': actualPrizeAmount,
  'chittis/$chittiId/members/${winner.id}/balance/lastUpdated': ServerValue.timestamp,

  // Transaction index
  'chittis/$chittiId/transactionIndex/${winner.id}/$txnId': true,

  // Global lucky draw history
  'lucky_draws/$winnerId': {...},

  // ❌ NOTICE: No update to 'chittis/$chittiId/members/${winner.id}/status'!
};

await _db.update(updates);
```

The code sets `isWinner: true` in the balance sub-object but doesn't update the main `status` field from `active` to `won`.

## Impact Analysis

### Duplicate Winner Risk

The `getEligibleSlots` method filters by status:

```dart
// lib/services/lucky_draw_manager.dart
Future<List<Slot>> getEligibleSlots(String chittiId) async {
  // ...
  for (final entry in membersData.entries) {
    final slotId = entry.key as String;
    if (winnerSlotIds.contains(slotId)) continue;  // Checks winners list

    final slotData = Map<String, dynamic>.from(entry.value as Map);
    final slot = Slot.fromFirebase(slotId, slotData);

    // Only include active slots
    if (slot.status == SlotStatus.active) {  // ← This check is useless if status never changes!
      eligibleSlots.add(slot);
    }
  }
  // ...
}
```

The code has TWO mechanisms to prevent duplicate winners:
1. **Primary**: Check `winnerSlotIds` (slots that already won) - This works
2. **Secondary**: Check `slot.status == SlotStatus.active` - This is broken

While the primary check prevents duplicates in normal operation, the broken status tracking causes issues:

### Secondary Issues

1. **Inconsistent State**: The slot's `isWinner` balance flag is true, but status is still `active`
2. **Reporting Errors**: Reports filtering by `SlotStatus.won` won't include actual winners
3. **Business Logic**: Any code relying on `slot.status` for winner-specific logic will fail
4. **Data Integrity**: Audit trails show conflicting information

### Example Scenario

```
Month 3: Slot 5 wins lucky draw
- winners/2025-03 created with slotId = slot_5
- slot_5.balance.isWinner = true
- slot_5.status = 'active'  ← SHOULD BE 'won'

Month 4: getEligibleSlots() called
- Checks winners/2025-04 (empty) - passes
- Checks winners/2025-03 (has slot_5) - slot_5 excluded ✓
- Checks slot_5.status == 'active' - TRUE (should be false)

If winnerSlotIds check somehow fails (race condition, data corruption):
- slot_5 would be eligible again! ← BUG
```

## Suggested Fix

Add status update to the atomic write operation:

```dart
// lib/services/lucky_draw_manager.dart:200-230

final updates = <String, dynamic>{
  // ... existing updates ...

  // NEW: Update slot status to 'won'
  'chittis/$chittiId/members/${winner.id}/status': SlotStatus.won.name,

  // Also update the main slot fields (not just balance sub-object)
  'chittis/$chittiId/members/${winner.id}/isWinner': true,
  'chittis/$chittiId/members/${winner.id}/winnerMonth': month,
};
```

### Complete Fix

```dart
// In _processWinner method, after calculating discount:

// Atomic write: Winner + Discount + Status update
final updates = <String, dynamic>{
  // Winner records
  'chittis/$chittiId/winners/$month': winnerRecord.toFirebase(),
  'winners/$winnerId': {
    ...winnerRecord.toFirebase(),
    'chittiName': chittyName,
  },
  'lucky_draws/$winnerId': {
    ...winnerRecord.toFirebase(),
    'chittiName': chittiName,
  },

  // Discount transaction
  'transactions/$txnId': discountTxn.toFirebase(),
  'chittis/$chittiId/transactionIndex/${winner.id}/$txnId': true,

  // Slot balance updates
  'chittis/$chittiId/members/${winner.id}/balance/totalDue': newTotalDue,
  'chittis/$chittiId/members/${winner.id}/balance/currentBalance':
      winner.totalPaid - newTotalDue,
  'chittis/$chittiId/members/${winner.id}/balance/currentMonthlyAmount':
      newMonthlyEMI,
  'chittis/$chittiId/members/${winner.id}/balance/originalMonthlyAmount':
      originalMonthlyEMI,
  'chittis/$chittiId/members/${winner.id}/balance/isWinner': true,
  'chittis/$chittiId/members/${winner.id}/balance/winnerMonth': month,
  'chittis/$chittiId/members/${winner.id}/balance/discountStartMonth':
      discountStartMonth,
  'chittis/$chittiId/members/${winner.id}/balance/discountPerMonth':
      discountPerMonth,
  'chittis/$chittiId/members/${winner.id}/balance/totalDiscount': totalDiscount,
  'chittis/$chittiId/members/${winner.id}/balance/prizeAmount': actualPrizeAmount,
  'chittis/$chittiId/members/${winner.id}/balance/lastUpdated':
      ServerValue.timestamp,

  // NEW: Update slot status and main fields
  'chittis/$chittiId/members/${winner.id}/status': SlotStatus.won.name,
  'chittis/$chittiId/members/${winner.id}/isWinner': true,
  'chittis/$chittiId/members/${winner.id}/winnerMonth': month,
};

await _db.update(updates);
```

## Test Case

```dart
test('slot status should change to won after lucky draw', () async {
  final manager = LuckyDrawManager();

  // Setup: Create chitty and add slots
  final chittiId = await _createChitti(name: 'Test Chitty');
  final slotId = await _addSlotToChitti(chittiId, userId: 'user1');

  // Verify initial status
  var slotSnap = await _db.child('chittis/$chittiId/members/$slotId').get();
  var slotData = Map<String, dynamic>.from(slotSnap.value as Map);
  expect(slotData['status'], equals('active'));
  expect(slotData['isWinner'], isNull);

  // Select winner
  final result = await manager.selectWinner(
    chittiId: chittiId,
    month: '2025-03',
    algorithm: DrawAlgorithm.random,
  );

  expect(result.success, isTrue);

  // Verify status changed to 'won'
  slotSnap = await _db.child('chittis/$chittiId/members/$slotId').get();
  slotData = Map<String, dynamic>.from(slotSnap.value as Map);

  expect(slotData['status'], equals('won'));  // Should be 'won', not 'active'
  expect(slotData['isWinner'], isTrue);
  expect(slotData['winnerMonth'], equals('2025-03'));

  // Verify balance sub-object also updated
  final balance = Map<String, dynamic>.from(slotData['balance'] as Map);
  expect(balance['isWinner'], isTrue);
  expect(balance['winnerMonth'], equals('2025-03'));
  expect(balance['discountPerMonth'], isNotNull);
  expect(balance['discountPerMonth'], greaterThan(0));
});

test('slot with status won should not be eligible for future draws', () async {
  final manager = LuckyDrawManager();

  // Setup: Create chitty with winner
  final chittiId = await _createChitty(name: 'Test Chitty');
  final slotId1 = await _addSlotToChitti(chittiId, userId: 'user1');
  final slotId2 = await _addSlotToChitti(chittiId, userId: 'user2');

  // Make slot1 win
  await manager.selectWinner(
    chittiId: chittiId,
    month: '2025-03',
    algorithm: DrawAlgorithm.random,
  );

  // Get eligible slots for next month
  final eligibleSlots = await manager.getEligibleSlots(chittiId);

  // slot1 should NOT be eligible (already won)
  final slot1Ids = eligibleSlots.map((s) => s.id).toList();
  expect(slot1Ids, isNot(contains(slotId1)));

  // slot2 should be eligible
  expect(slot1Ids, contains(slotId2));
});
```

## Verification Steps

1. Run a lucky draw and verify slot status changes to `won`
2. Run lucky draw again and verify previous winner is not eligible
3. Check database directly for status field update
4. Verify reports correctly filter winners by status
5. Test edge case: Slot wins, then manually set back to `active` (should this be allowed?)

## Related Issues

- **Issue #003**: Missing null check in discount calculation (same winner processing flow)
- **Issue #006**: Duplicate winner check incomplete (related prevention mechanism)

## References

- `lib/core/domain/enums.dart` - `SlotStatus` enum definition
- `lib/core/models/slot.dart` - Slot model with status field
- `lib/services/lucky_draw_manager.dart` - Winner selection logic
