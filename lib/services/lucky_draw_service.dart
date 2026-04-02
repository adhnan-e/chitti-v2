import 'package:firebase_database/firebase_database.dart';

/// Lucky Draw Service - Handles winners, prizes, and discounts (slot-based)
/// Each slot is treated as a separate entry for lucky draw purposes
class LuckyDrawService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Singleton
  static final LuckyDrawService _instance = LuckyDrawService._internal();
  factory LuckyDrawService() => _instance;
  LuckyDrawService._internal();

  /// Add a winner for a month (slot-based)
  /// Each slot can win independently
  /// Discount applies starting from the NEXT month
  Future<void> addWinner({
    required String chittiId,
    required String chittiName,
    required String month, // Current month (YYYY-MM format)
    required String slotId,
    required String userId,
    required String userName,
    required String prize,
    int? slotNumber,
  }) async {
    try {
      // Check if month already has a winner
      final existingWinners = await getChittiWinners(chittiId);
      if (existingWinners.any((w) => w['month'] == month)) {
        throw Exception('A winner has already been assigned for $month');
      }

      // Check if this slot already won in this chitti
      if (existingWinners.any((w) => w['slotId'] == slotId)) {
        throw Exception('This slot has already won in this chitti');
      }

      // Calculate discount start month (next month)
      final discountStartMonth = _getNextMonth(month);

      final timestamp = ServerValue.timestamp;
      final winnerData = {
        'slotId': slotId,
        'userId': userId,
        'userName': userName,
        'slotNumber': slotNumber,
        'prize': prize,
        'declaredAt': timestamp,
        'discountApplied': false,
        'discountStartMonth': discountStartMonth,
      };

      // Store in chitti (keyed by month)
      await _db.child('chittis/$chittiId/winners/$month').set(winnerData);

      // Store in global history
      await _db.child('lucky_draws').push().set({
        'chittiId': chittiId,
        'chittiName': chittiName,
        'month': month,
        ...winnerData,
      });

      // Apply winner discount to slot's balance
      await applyWinnerDiscount(chittiId, slotId, month, discountStartMonth);
    } catch (e) {
      print('Error adding winner: $e');
      rethrow;
    }
  }

  String _getNextMonth(String month) {
    // month format: "YYYY-MM" or "Month Year"
    try {
      if (month.contains('-')) {
        // ISO format
        final parts = month.split('-');
        int year = int.parse(parts[0]);
        int monthNum = int.parse(parts[1]);

        monthNum++;
        if (monthNum > 12) {
          monthNum = 1;
          year++;
        }
        return '$year-${monthNum.toString().padLeft(2, '0')}';
      } else {
        // "January 2024" format
        final months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        final parts = month.split(' ');
        final monthIndex = months.indexOf(parts[0]);
        int year = int.tryParse(parts[1]) ?? DateTime.now().year;

        final nextMonthIndex = (monthIndex + 1) % 12;
        if (nextMonthIndex == 0) year++;

        return '${months[nextMonthIndex]} $year';
      }
    } catch (e) {
      return month;
    }
  }

  /// Apply winner discount to slot balance (slot-based)
  Future<void> applyWinnerDiscount(
    String chittiId,
    String slotId,
    String winnerMonth,
    String discountStartMonth,
  ) async {
    try {
      // Get slot and chitti details
      final slotSnap = await _db
          .child('chittis/$chittiId/members/$slotId')
          .get();
      final chittiSnap = await _db.child('chittis/$chittiId').get();

      if (!slotSnap.exists || !chittiSnap.exists) return;

      final slotData = Map<String, dynamic>.from(slotSnap.value as Map);
      final chittiData = Map<String, dynamic>.from(chittiSnap.value as Map);

      final balance = slotData['balance'] as Map? ?? {};
      final totalDue = (balance['totalDue'] ?? slotData['totalAmount'] ?? 0.0)
          .toDouble();
      final totalPaid = (balance['totalPaid'] ?? 0.0).toDouble();

      // Prize is typically the slot's investment amount
      final prizeAmount = (slotData['totalAmount'] ?? 0.0).toDouble();

      // Get the slot's gold option to determine which reward to apply
      final slotGoldOptionV2 = slotData['goldOptionV2'] as Map?;
      final goldOptionId = slotGoldOptionV2?['id'] as String?;

      // Get monthly discount amount from reward config
      double discountPerMonth = 0.0;
      final goldOptionRewards = chittiData['goldOptionRewards'] as Map?;
      final legacyRewardConfig = chittiData['rewardConfig'] as Map?;

      if (goldOptionRewards != null && goldOptionId != null) {
        // New per-option logic
        final rewardConfig = goldOptionRewards[goldOptionId] as Map?;
        if (rewardConfig != null && rewardConfig['enabled'] == true) {
          // This is the discount per month (e.g., 10 AED per month)
          discountPerMonth = (rewardConfig['calculatedAmount'] ?? 0).toDouble();
        }
      } else if (legacyRewardConfig != null && legacyRewardConfig['enabled'] == true) {
        // Legacy global logic for backward compatibility
        if (legacyRewardConfig['type'] == 'Percentage') {
          final percentage = (legacyRewardConfig['value'] ?? 0).toDouble();
          discountPerMonth = prizeAmount * (percentage / 100);
        } else if (legacyRewardConfig['type'] == 'Fixed Amount') {
          discountPerMonth = (legacyRewardConfig['value'] ?? 0).toDouble();
        }
      }

      // Calculate remaining months and total discount
      final currentMonth = chittiData['currentMonth'] as int? ?? 1;
      final duration = chittiData['duration'] as int? ?? 20;
      final remainingMonths = duration - currentMonth;

      // Total discount = discount per month × remaining months
      final totalDiscount = discountPerMonth * remainingMonths;

      // Calculate original monthly amount
      final originalMonthlyAmount = (balance['originalMonthlyAmount'] as num?)?.toDouble()
          ?? (duration > 0 ? totalDue / duration : 0.0);

      // IMPORTANT: Prize does NOT reduce their own dues - it's separate!
      // Only subtract the total discount from their totalDue
      final newTotalDue = totalDue - totalDiscount;

      // Calculate new monthly amount (reduced by discount per month)
      final newMonthlyAmount = originalMonthlyAmount - discountPerMonth;

      // Calculate new balance
      final newBalance = totalPaid - (newTotalDue > 0 ? newTotalDue : 0);

      // Update balance with winner discount
      await _db.child('chittis/$chittiId/members/$slotId/balance').update({
        'totalDue': newTotalDue > 0 ? newTotalDue : 0.0,
        'currentBalance': newBalance,
        'currentMonthlyAmount': newMonthlyAmount > 0 ? newMonthlyAmount : 0.0,
        'originalMonthlyAmount': originalMonthlyAmount,  // Keep original for comparison
        'remainingMonths': remainingMonths,
        'isWinner': true,
        'winnerMonth': winnerMonth,
        'discountStartMonth': discountStartMonth,
        'discountPerMonth': discountPerMonth,      // NEW - monthly discount amount
        'totalDiscount': totalDiscount,            // NEW - total discount for all remaining months
        'prizeAmount': prizeAmount,                // Keep for display/tracking
        'lastUpdated': ServerValue.timestamp,
      });

      // Mark winner as discount applied
      await _db.child('chittis/$chittiId/winners/$winnerMonth').update({
        'discountApplied': true,
        'totalDiscount': totalDiscount,           // Store total discount
        'discountPerMonth': discountPerMonth,      // Store monthly discount
      });
    } catch (e) {
      print('Error applying winner discount: $e');
      rethrow;
    }
  }

  /// Get all winners for a chitti
  Future<List<Map<String, dynamic>>> getChittiWinners(String chittiId) async {
    try {
      final winnersSnap = await _db.child('chittis/$chittiId/winners').get();
      if (!winnersSnap.exists || winnersSnap.value == null) return [];

      final winnersData = Map<String, dynamic>.from(winnersSnap.value as Map);
      final List<Map<String, dynamic>> winners = [];

      winnersData.forEach((month, value) {
        final winner = Map<String, dynamic>.from(value as Map);
        winner['month'] = month;
        winners.add(winner);
      });

      // Sort by declaredAt
      winners.sort(
        (a, b) => (a['declaredAt'] ?? 0).compareTo(b['declaredAt'] ?? 0),
      );
      return winners;
    } catch (e) {
      print('Error getting chitti winners: $e');
      return [];
    }
  }

  /// Get lucky draw history (global)
  Future<List<Map<String, dynamic>>> getLuckyDrawHistory() async {
    try {
      final snapshot = await _db
          .child('lucky_draws')
          .orderByChild('declaredAt')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final list = data.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value as Map);
          map['id'] = e.key;
          return map;
        }).toList();

        list.sort((a, b) {
          final aTime = a['declaredAt'] ?? 0;
          final bTime = b['declaredAt'] ?? 0;
          return bTime.compareTo(aTime);
        });
        return list;
      }
    } catch (e) {
      print('Error getting lucky draw history: $e');
    }
    return [];
  }

  /// Check if slot is a winner in a chitti (slot-based)
  Future<Map<String, dynamic>> getSlotWinnerDetails(
    String chittiId,
    String slotId,
  ) async {
    try {
      final winners = await getChittiWinners(chittiId);
      final slotWin = winners.where((w) => w['slotId'] == slotId).toList();

      if (slotWin.isNotEmpty) {
        final win = slotWin.first;
        return {
          'isWinner': true,
          'winnerMonth': win['month'],
          'discountStartMonth': win['discountStartMonth'],
          'prizeAmount': win['prize'],
        };
      }

      return {
        'isWinner': false,
        'winnerMonth': null,
        'discountStartMonth': null,
        'prizeAmount': 0.0,
      };
    } catch (e) {
      print('Error getting slot winner details: $e');
      return {'isWinner': false};
    }
  }

  /// Check if user is a winner in a chitti (legacy - checks any slot)
  /// @deprecated Use getSlotWinnerDetails instead
  Future<Map<String, dynamic>> getWinnerDetails(
    String chittiId,
    String slotIdOrUserId,
  ) async {
    return getSlotWinnerDetails(chittiId, slotIdOrUserId);
  }

  /// Get eligible slots for lucky draw (not yet won) - slot-based
  Future<List<Map<String, dynamic>>> getEligibleSlots(String chittiId) async {
    try {
      final chittiSnap = await _db.child('chittis/$chittiId').get();
      if (!chittiSnap.exists) return [];

      final chittiData = Map<String, dynamic>.from(chittiSnap.value as Map);
      final membersMap = chittiData['members'] as Map? ?? {};
      final winners = await getChittiWinners(chittiId);
      final winnerSlotIds = winners.map((w) => w['slotId']).toSet();

      final List<Map<String, dynamic>> eligible = [];

      for (var entry in membersMap.entries) {
        final slotId = entry.key;
        if (!winnerSlotIds.contains(slotId)) {
          final slotData = Map<String, dynamic>.from(entry.value as Map);
          eligible.add({
            'slotId': slotId,
            'slotNumber': slotData['slotNumber'],
            'userId': slotData['userId'],
            'goldOption': slotData['goldOption'],
            'totalAmount': slotData['totalAmount'],
          });
        }
      }

      // Sort by slot number
      eligible.sort(
        (a, b) => (a['slotNumber'] as int? ?? 0).compareTo(
          b['slotNumber'] as int? ?? 0,
        ),
      );

      return eligible;
    } catch (e) {
      print('Error getting eligible slots: $e');
      return [];
    }
  }

  /// Get eligible members for lucky draw (legacy - redirects to slot-based)
  /// @deprecated Use getEligibleSlots instead
  Future<List<Map<String, dynamic>>> getEligibleMembers(String chittiId) async {
    return getEligibleSlots(chittiId);
  }
}
