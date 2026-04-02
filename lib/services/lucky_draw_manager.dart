/// LuckyDrawManager - Handles winner selection and discount application
///
/// Supports multiple selection algorithms and ensures atomic discount
/// application to prevent race conditions and double winners.
library;

import 'dart:math';
import 'package:firebase_database/firebase_database.dart' hide Transaction;
import '../core/models/models.dart';

/// Result of a lucky draw operation
class DrawResult {
  final bool success;
  final Winner? winner;
  final Transaction? discountTransaction;
  final String? error;

  const DrawResult({
    required this.success,
    this.winner,
    this.discountTransaction,
    this.error,
  });

  factory DrawResult.success(Winner winner, Transaction discountTxn) =>
      DrawResult(
        success: true,
        winner: winner,
        discountTransaction: discountTxn,
      );

  factory DrawResult.failure(String error) =>
      DrawResult(success: false, error: error);
}

/// LuckyDrawManager handles winner selection and discount cascade.
///
/// Features:
/// - Multiple selection algorithms (random, deterministic, weighted)
/// - Atomic winner + discount application
/// - Prevention of double winners and same-month conflicts
/// - Discount cascade to all remaining months
class LuckyDrawManager {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Select a winner for a specific month.
  ///
  /// [algorithm] - Selection method: 'random', 'deterministic', 'weighted'
  /// [seed] - Optional seed for deterministic draws (reproducibility)
  Future<DrawResult> selectWinner({
    required String chittiId,
    required String month,
    DrawAlgorithm algorithm = DrawAlgorithm.random,
    int? seed,
  }) async {
    try {
      // Check if month already has a winner
      final existingWinner = await _db
          .child('chittis/$chittiId/winners/$month')
          .get();
      if (existingWinner.exists) {
        return DrawResult.failure(
          'A winner has already been declared for $month',
        );
      }

      // Get eligible slots (not yet won)
      final eligibleSlots = await getEligibleSlots(chittiId);
      if (eligibleSlots.isEmpty) {
        return DrawResult.failure('No eligible slots available for lucky draw');
      }

      // Select winner based on algorithm
      Slot winner;
      switch (algorithm) {
        case DrawAlgorithm.deterministic:
          winner = _selectDeterministic(eligibleSlots, month, seed);
        case DrawAlgorithm.weighted:
          winner = await _selectWeighted(eligibleSlots, chittiId);
        case DrawAlgorithm.random:
          winner = _selectRandom(eligibleSlots);
      }

      // Delegate to common winner processing
      return _processWinner(
        chittiId: chittiId,
        slotId: winner.id,
        month: month,
        prizeDescription: null,
        prizeAmount: null,
      );
    } catch (e) {
      return DrawResult.failure('Lucky draw failed: $e');
    }
  }

  /// Manually assign a winner for a specific slot.
  ///
  /// Used when the organizer manually selects a winner
  /// instead of using an algorithm.
  Future<DrawResult> assignWinner({
    required String chittiId,
    required String slotId,
    required String month,
    String? prizeDescription,
    double? prizeAmount,
  }) async {
    try {
      // Check if month already has a winner
      final existingWinner = await _db
          .child('chittis/$chittiId/winners/$month')
          .get();
      if (existingWinner.exists) {
        return DrawResult.failure(
          'A winner has already been declared for $month',
        );
      }

      // Check if slot has already won
      final allWinners = await getChittiWinners(chittiId);
      final hasWon = allWinners.any((w) => w.slotId == slotId);
      if (hasWon) {
        return DrawResult.failure('This slot has already won in this chitty');
      }

      // Delegate to common winner processing
      return _processWinner(
        chittiId: chittiId,
        slotId: slotId,
        month: month,
        prizeDescription: prizeDescription,
        prizeAmount: prizeAmount,
      );
    } catch (e) {
      return DrawResult.failure('Winner assignment failed: $e');
    }
  }

  /// Common winner processing logic
  Future<DrawResult> _processWinner({
    required String chittiId,
    required String slotId,
    required String month,
    String? prizeDescription,
    double? prizeAmount,
  }) async {
    try {
      // Get chitti details
      final chittiSnap = await _db.child('chittis/$chittiId').get();
      if (!chittiSnap.exists) {
        return DrawResult.failure('Chitti not found');
      }
      final chittiData = Map<String, dynamic>.from(chittiSnap.value as Map);
      final chittiName = chittiData['name'] as String? ?? '';
      final duration = chittiData['duration'] as int? ?? 12;
      final currentMonth = chittiData['currentMonth'] as int? ?? 1;

      // Get slot details
      final slotSnap = await _db
          .child('chittis/$chittiId/members/$slotId')
          .get();
      if (!slotSnap.exists) {
        return DrawResult.failure('Slot not found');
      }
      final slotData = Map<String, dynamic>.from(slotSnap.value as Map);
      final winner = Slot.fromFirebase(slotId, slotData);

      // Calculate discount
      final discountStartMonth = _getNextMonth(month);
      final remainingMonths = duration - currentMonth;

      // Get reward config for this slot's gold option
      double discountPerMonth = 0.0;
      final goldOptionRewards = chittiData['goldOptionRewards'] as Map?;
      final legacyRewardConfig = chittiData['rewardConfig'] as Map?;

      final goldOptionId = winner.goldOptionId;

      if (goldOptionRewards != null && goldOptionId.isNotEmpty) {
        final rewardConfig = goldOptionRewards[goldOptionId] as Map?;
        if (rewardConfig != null && rewardConfig['enabled'] == true) {
          discountPerMonth =
              (rewardConfig['calculatedAmount'] as num?)?.toDouble() ?? 0.0;
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

      final totalDiscount = discountPerMonth * remainingMonths;
      final actualPrizeAmount = prizeAmount ?? winner.totalDue;

      // Get user name
      String userName = winner.userName ?? '';
      if (userName.isEmpty) {
        final userSnap = await _db.child('users/${winner.userId}').get();
        if (userSnap.exists) {
          final userData = Map<String, dynamic>.from(userSnap.value as Map);
          userName = userData['name'] as String? ?? 'Unknown';
        }
      }

      final now = DateTime.now();
      final winnerId = '${month}_${winner.slotNumber}';

      // Create winner record
      final winnerRecord = Winner(
        id: winnerId,
        chittiId: chittiId,
        slotId: winner.id,
        userId: winner.userId,
        userName: userName,
        slotNumber: winner.slotNumber,
        winnerMonth: month,
        discountStartMonth: discountStartMonth,
        prizeAmount: actualPrizeAmount,
        discountPerMonth: discountPerMonth,
        totalDiscount: totalDiscount,
        selectionMethod: DrawAlgorithm.random, // Manual selection
        discountApplied: true,
        declaredAt: now,
        goldOptionLabel: winner.goldOptionLabel,
      );

      // Create discount transaction
      final txnRef = _db.child('transactions').push();
      final txnId = txnRef.key!;

      // Convert balance to cents for Transaction
      final balanceBeforeCents = (winner.currentBalance * 100).toInt();
      final totalDiscountCents = (totalDiscount * 100).toInt();
      final balanceAfterCents = balanceBeforeCents + totalDiscountCents;

      final discountTxn = Transaction(
        id: txnId,
        slotId: winner.id,
        chittiId: chittiId,
        type: TransactionType.discount,
        amountInCents: totalDiscountCents,
        balanceBeforeInCents: balanceBeforeCents,
        balanceAfterInCents: balanceAfterCents,
        monthKey: month,
        status: TransactionStatus.verified,
        notes:
            'Winner discount: $discountPerMonth/month × $remainingMonths months = $totalDiscount',
        userId: winner.userId,
        slotNumber: winner.slotNumber,
        createdAt: now,
        verifiedAt: now,
      );

      // Calculate new slot values
      final newTotalDue = winner.totalDue - totalDiscount;
      final originalMonthlyEMI = winner.monthlyEMI;
      final newMonthlyEMI = originalMonthlyEMI - discountPerMonth;

      // Atomic write: Winner + Discount transaction + Balance update
      final updates = <String, dynamic>{
        // Winner in chitty
        'chittis/$chittiId/winners/$month': winnerRecord.toFirebase(),

        // Global winners collection
        'winners/$winnerId': {
          ...winnerRecord.toFirebase(),
          'chittiName': chittiName,
        },

        // Discount transaction
        'transactions/$txnId': discountTxn.toFirebase(),

        // Update slot balance
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
        'chittis/$chittiId/members/${winner.id}/balance/totalDiscount':
            totalDiscount,
        'chittis/$chittiId/members/${winner.id}/balance/prizeAmount':
            actualPrizeAmount,
        'chittis/$chittiId/members/${winner.id}/balance/lastUpdated':
            ServerValue.timestamp,

        // Transaction index
        'chittis/$chittiId/transactionIndex/${winner.id}/$txnId': true,

        // Global lucky draw history
        'lucky_draws/$winnerId': {
          ...winnerRecord.toFirebase(),
          'chittiName': chittiName,
        },
      };

      await _db.update(updates);

      return DrawResult.success(winnerRecord, discountTxn);
    } catch (e) {
      return DrawResult.failure('Winner processing failed: $e');
    }
  }

  /// Get all eligible slots (have not won yet)
  Future<List<Slot>> getEligibleSlots(String chittiId) async {
    try {
      final membersSnap = await _db.child('chittis/$chittiId/members').get();
      if (!membersSnap.exists) return [];

      final winnersSnap = await _db.child('chittis/$chittiId/winners').get();
      final winnerSlotIds = <String>{};

      if (winnersSnap.exists) {
        final winnersData = winnersSnap.value as Map;
        for (final entry in winnersData.entries) {
          final winnerData = entry.value as Map;
          final slotId = winnerData['slotId'] as String?;
          if (slotId != null) {
            winnerSlotIds.add(slotId);
          }
        }
      }

      final membersData = membersSnap.value as Map;
      final eligibleSlots = <Slot>[];

      for (final entry in membersData.entries) {
        final slotId = entry.key as String;
        if (winnerSlotIds.contains(slotId)) continue;

        final slotData = Map<String, dynamic>.from(entry.value as Map);
        final slot = Slot.fromFirebase(slotId, slotData);

        // Only include active slots
        if (slot.status == SlotStatus.active) {
          eligibleSlots.add(slot);
        }
      }

      return eligibleSlots;
    } catch (e) {
      _debugPrint('Error getting eligible slots: $e');
      return [];
    }
  }

  /// Get all winners for a chitty
  Future<List<Winner>> getChittiWinners(String chittiId) async {
    try {
      final snap = await _db.child('chittis/$chittiId/winners').get();
      if (!snap.exists) return [];

      final data = snap.value as Map;
      return data.entries.map((e) {
        final winnerData = Map<String, dynamic>.from(e.value as Map);
        return Winner.fromFirebase(e.key as String, winnerData);
      }).toList()..sort((a, b) => a.winnerMonth.compareTo(b.winnerMonth));
    } catch (e) {
      _debugPrint('Error getting chitty winners: $e');
      return [];
    }
  }

  /// Get winner details for a specific slot
  Future<Winner?> getSlotWinnerDetails(String chittiId, String slotId) async {
    try {
      final winnersSnap = await _db.child('chittis/$chittiId/winners').get();
      if (!winnersSnap.exists) return null;

      final winnersData = winnersSnap.value as Map;
      for (final entry in winnersData.entries) {
        final winnerData = Map<String, dynamic>.from(entry.value as Map);
        if (winnerData['slotId'] == slotId) {
          return Winner.fromFirebase(entry.key as String, winnerData);
        }
      }
      return null;
    } catch (e) {
      _debugPrint('Error getting slot winner details: $e');
      return null;
    }
  }

  /// Random selection
  Slot _selectRandom(List<Slot> slots) {
    return slots[Random().nextInt(slots.length)];
  }

  /// Deterministic selection using hash
  Slot _selectDeterministic(List<Slot> slots, String month, int? seed) {
    // Sort by slot number for consistency
    slots.sort((a, b) => a.slotNumber.compareTo(b.slotNumber));

    // Create deterministic hash from month + seed
    final hashInput = '$month${seed ?? 0}';
    final hash = hashInput.hashCode.abs();
    final index = hash % slots.length;

    return slots[index];
  }

  /// Weighted selection based on payment compliance
  Future<Slot> _selectWeighted(List<Slot> slots, String chittiId) async {
    if (slots.length == 1) return slots.first;

    // Calculate weights based on payment compliance
    final weights = <Slot, double>{};
    for (final slot in slots) {
      // Higher payment percentage = higher weight
      final compliance = slot.paymentProgress / 100;
      weights[slot] = compliance.clamp(0.1, 1.0); // Min 10% chance
    }

    final totalWeight = weights.values.fold(0.0, (a, b) => a + b);
    var random = Random().nextDouble() * totalWeight;

    for (final entry in weights.entries) {
      random -= entry.value;
      if (random <= 0) return entry.key;
    }

    return slots.last;
  }

  /// Calculate next month from YYYY-MM format
  String _getNextMonth(String month) {
    try {
      final parts = month.split('-');
      var year = int.parse(parts[0]);
      var monthNum = int.parse(parts[1]);

      monthNum++;
      if (monthNum > 12) {
        monthNum = 1;
        year++;
      }

      return '$year-${monthNum.toString().padLeft(2, '0')}';
    } catch (_) {
      return month;
    }
  }

  void _debugPrint(String message) {
    assert(() {
      // ignore: avoid_print
      print(message);
      return true;
    }());
  }
}
