# Issue: Missing Null Check in Discount Calculation

## Severity
**HIGH**

## Location
`lib/services/lucky_draw_manager.dart:175-185`

## Description
The lucky draw winner processing logic has insufficient null checking when retrieving reward configuration. If the `goldOptionRewards` map is null, missing the specific gold option ID, or the reward config is malformed, the discount calculation silently defaults to 0, resulting in winners receiving no discount.

## Reproduction Conditions
- A chitty is created without properly configured `goldOptionRewards`
- The `goldOptionRewards` map exists but doesn't contain the winner's gold option ID
- Data corruption or migration issues cause malformed reward config
- A winner is selected for a slot with a gold option that has no reward config

## Expected Behavior
When a winner is selected:
1. The system should retrieve the reward configuration for the winner's gold option
2. If the reward config is missing or null, the system should either:
   - Use a sensible default discount (e.g., from legacy `rewardConfig`)
   - Fail with a clear error message
   - Apply a minimum discount percentage defined in app settings
3. The winner should always receive some discount (never 0 unless explicitly configured)

## Actual Behavior
The current code:

```dart
// lib/services/lucky_draw_manager.dart:175-185
double discountPerMonth = 0.0;
final goldOptionRewards = chittyData['goldOptionRewards'] as Map?;
final legacyRewardConfig = chittyData['rewardConfig'] as Map?;

final goldOptionId = winner.goldOptionId;

if (goldOptionRewards != null && goldOptionId.isNotEmpty) {
  final rewardConfig = goldOptionRewards[goldOptionId] as Map?;
  if (rewardConfig != null && rewardConfig['enabled'] == true) {
    discountPerMonth =
        (rewardConfig['calculatedAmount'] as num?)?.toDouble() ?? 0.0;
    // ↑ If calculatedAmount is null, discountPerMonth stays 0.0
  }
} else if (legacyRewardConfig != null &&
    legacyRewardConfig['enabled'] == true) {
  // Legacy fallback
  if (legacyRewardConfig['type'] == 'Percentage') {
    final percentage =
        (legacyRewardConfig['value'] as num?)?.toDouble() ?? 0.0;
    discountPerMonth = winner.totalDue * (percentage / 100) / duration;
  } else {
    discountPerMonth =
        (legacyRewardConfig['value'] as num?)?.toDouble() ?? 0.0;
  }
}
// If all checks fail, discountPerMonth remains 0.0 - winner gets NO discount!
```

Problems:
1. No validation that a valid discount was calculated
2. No warning/error when config is missing
3. Silent fallback to 0.0 discount
4. Legacy fallback only triggers if `goldOptionRewards` is null, not if the specific gold option is missing

## Impact Analysis

### Financial Impact Example

**Chitty Details:**
- Duration: 12 months
- Slot total due: AED 1200
- Expected discount: 10% = AED 120 total (AED 10/month for remaining months)

**Bug Scenario:**
- `goldOptionRewards` map doesn't have entry for winner's gold option
- `discountPerMonth` = 0.0
- Winner receives AED 0 discount instead of AED 120
- Member loses AED 120 they were entitled to
- Organizer incorrectly retains AED 120

### Data Scenarios That Trigger This Bug

| Scenario | Result |
|----------|--------|
| `goldOptionRewards` is null | Falls back to legacy config (OK) |
| `goldOptionRewards` is empty map | No fallback, discount = 0 (BUG) |
| Gold option ID not in map | No fallback, discount = 0 (BUG) |
| `calculatedAmount` is null | Discount = 0 (BUG) |
| `enabled` is false | Discount = 0 (intentional) |

## Suggested Fix

Add comprehensive validation and fallback logic:

```dart
// lib/services/lucky_draw_manager.dart
double discountPerMonth = 0.0;
String? discountError;

final goldOptionRewards = chittyData['goldOptionRewards'] as Map?;
final legacyRewardConfig = chittyData['rewardConfig'] as Map?;
final goldOptionId = winner.goldOptionId;

// Try primary: gold option-specific reward config
if (goldOptionRewards != null && goldOptionId.isNotEmpty) {
  final rewardConfig = goldOptionRewards[goldOptionId] as Map?;
  if (rewardConfig != null) {
    final isEnabled = rewardConfig['enabled'] as bool? ?? false;
    if (isEnabled) {
      discountPerMonth =
          (rewardConfig['calculatedAmount'] as num?)?.toDouble() ?? 0.0;

      // VALIDATION: Ensure discount was calculated
      if (discountPerMonth <= 0) {
        discountError = 'Reward config exists but calculatedAmount is invalid';
      }
    }
  }
}

// Fallback 1: Try legacy chitty-wide reward config
if (discountPerMonth <= 0 && legacyRewardConfig != null) {
  final legacyEnabled = legacyRewardConfig['enabled'] as bool? ?? false;
  if (legacyEnabled) {
    final legacyType = legacyRewardConfig['type'] as String? ?? '';
    final legacyValue = (legacyRewardConfig['value'] as num?)?.toDouble() ?? 0.0;

    if (legacyType == 'Percentage' && legacyValue > 0) {
      discountPerMonth = winner.totalDue * (legacyValue / 100) / duration;
    } else if (legacyValue > 0) {
      discountPerMonth = legacyValue;
    }
  }
}

// Fallback 2: Default percentage from app settings (if available)
if (discountPerMonth <= 0) {
  // Try to get default discount from app_settings
  final appSettingsSnap = await _db.child('app_settings').get();
  if (appSettingsSnap.exists) {
    final settings = Map<String, dynamic>.from(appSettingsSnap.value as Map);
    final defaultDiscountPercent =
        (settings['defaultWinnerDiscountPercent'] as num?)?.toDouble() ?? 0.0;

    if (defaultDiscountPercent > 0) {
      discountPerMonth = winner.totalDue * (defaultDiscountPercent / 100) / duration;
      discountError ??= 'Using default discount (config missing)';
    }
  }
}

// FINAL VALIDATION: Fail if no discount could be calculated
if (discountPerMonth <= 0) {
  throw Exception(
    'Winner discount calculation failed: No valid reward config found. '
    'Gold option ID: $goldOptionId. '
    'Winner total due: ${winner.totalDue}. '
    '${discountError ?? "Unknown error"}',
  );
}
```

## Alternative: Warning with Minimum Default

If failing the operation is too strict, use a minimum default with logging:

```dart
if (discountPerMonth <= 0) {
  // Apply minimum 1% discount as safety net
  const minimumDiscountPercent = 1.0;
  discountPerMonth = winner.totalDue * (minimumDiscountPercent / 100) / duration;

  // Log warning for organizer to review
  print('WARNING: Winner discount fell back to minimum $minimumDiscountPercent%. '
        'Check reward configuration for chitti ${winner.chittiId}, '
        'gold option $goldOptionId');

  // Optionally: Store warning in winner record for audit
  discountError = 'Fallback to minimum discount applied';
}
```

## Test Case

```dart
test('winner discount should fail or use fallback when reward config is missing',
    () async {
  final manager = LuckyDrawManager();

  // Setup: Create chitty with empty goldOptionRewards
  final chittiId = await _createChitti(
    name: 'Test Chitty',
    goldOptionRewards: {},  // Empty - no reward configs
    rewardConfig: null,     // No legacy config either
  );

  // Setup: Add a slot/member
  final slotId = await _addSlotToChitti(chittiId, userId: 'user1');

  // Attempt: Select winner
  final result = await manager.selectWinner(
    chittiId: chittiId,
    month: '2025-03',
    algorithm: DrawAlgorithm.random,
  );

  // Option 1: Should throw error (strict validation)
  expect(result.success, isFalse);
  expect(result.error, contains('No valid reward config found'));

  // Option 2: Should use minimum default (lenient validation)
  // expect(result.success, isTrue);
  // expect(result.winner.discountPerMonth, greaterThan(0));
});

test('winner discount should use legacy config when gold option config missing',
    () async {
  final manager = LuckyDrawManager();

  // Setup: Chitty with goldOptionRewards but missing specific option
  final chittiId = await _createChitti(
    name: 'Test Chitty',
    goldOptionRewards: {
      'gold_option_1': {'enabled': true, 'calculatedAmount': 10.0},
      // Missing 'gold_option_2'
    },
    rewardConfig: {
      'enabled': true,
      'type': 'Percentage',
      'value': 5.0,  // 5% discount
    },
  );

  // Setup: Add slot with gold_option_2 (not in reward map)
  final slotId = await _addSlotToChitti(
    chittiId,
    goldOptionId: 'gold_option_2',
    totalDue: 1200.0,
  );

  // Select winner
  final result = await manager.selectWinner(
    chittiId: chittiId,
    month: '2025-03',
  );

  // Should use legacy 5% discount
  expect(result.success, isTrue);
  expect(result.winner.discountPerMonth, closeTo(5.0, 0.01));  // 5% of 1200 / 12
});
```

## Verification Steps

1. Test with completely missing `goldOptionRewards`
2. Test with empty `goldOptionRewards` map
3. Test with `goldOptionRewards` missing the specific gold option ID
4. Test with `calculatedAmount` set to null or 0
5. Verify legacy fallback works correctly
6. Verify error messages are clear and actionable

## Related Issues

- **Issue #004**: Slot status not updated after win (related winner processing flow)
- **Issue #008**: Global currency state could affect discount calculations

## References

- `lib/services/lucky_draw_manager.dart` - Winner processing logic
- `lib/core/models/chitty.dart` - RewardConfig model
- `lib/services/chitti_service.dart` - Chitty creation with rewards
