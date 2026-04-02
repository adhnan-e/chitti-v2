/// Gold Handover Service - Manages gold delivery and settlement
///
/// Handles the full lifecycle of gold handover:
/// 1. Initiate handover with current gold cost
/// 2. Calculate settlement difference
/// 3. Process settlement (one-time, revamp EMI, manual, refund)
/// 4. Track status flags through completion
library;

import 'package:firebase_database/firebase_database.dart' hide Transaction;
import '../core/models/models.dart';
import '../utils/currency_utils.dart';

/// GoldHandoverService - Settlement & gold delivery engine
class GoldHandoverService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Singleton
  static final GoldHandoverService _instance = GoldHandoverService._internal();
  factory GoldHandoverService() => _instance;
  GoldHandoverService._internal();

  // ============ Settlement Calculation ============

  /// Calculate settlement details without persisting
  /// Returns a map with: lockedTotalValue, currentTotalGoldCost,
  /// totalPaidByMember, settlementDifference, memberOwes, organizerOwes
  Map<String, dynamic> calculateSettlement({
    required double lockedTotalValue,
    required double currentTotalGoldCost,
    required double totalPaidByMember,
  }) {
    final difference = currentTotalGoldCost - totalPaidByMember;
    return {
      'lockedTotalValue': lockedTotalValue,
      'currentTotalGoldCost': currentTotalGoldCost,
      'totalPaidByMember': totalPaidByMember,
      'settlementDifference': difference,
      'memberOwes': difference > 0,
      'organizerOwes': difference < 0,
      'isExactMatch': difference == 0,
      'absoluteAmount': difference.abs(),
    };
  }

  // ============ Core Handover Operations ============

  /// Initiate gold handover for a slot
  ///
  /// Records the handover, creates a goldHandover transaction,
  /// and updates the slot's settlement status.
  Future<GoldHandover> initiateGoldHandover({
    required String chittiId,
    required String slotId,
    required String userId,
    required String userName,
    required String goldType,
    required String goldPurity,
    required double goldWeight,
    required double lockedTotalValue,
    required double currentTotalGoldCost,
    required double totalPaidByMember,
    int? slotNumber,
    String? notes,
  }) async {
    final settlementDiff = currentTotalGoldCost - totalPaidByMember;

    // Determine initial settlement status
    SlotSettlementStatus initialStatus;
    if (settlementDiff == 0) {
      initialStatus = SlotSettlementStatus.settledUp;
    } else if (settlementDiff > 0) {
      initialStatus = SlotSettlementStatus.settlementPending;
    } else {
      initialStatus = SlotSettlementStatus.refundPending;
    }

    // Create handover record
    final handoverRef = _db.child('gold_handovers').push();
    final handoverId = handoverRef.key!;
    final now = DateTime.now();

    final handover = GoldHandover(
      id: handoverId,
      chittiId: chittiId,
      slotId: slotId,
      userId: userId,
      userName: userName,
      goldOption: HandoverGoldSnapshot(
        type: goldType,
        purity: goldPurity,
        weight: goldWeight,
      ),
      lockedTotalValue: lockedTotalValue,
      currentTotalGoldCost: currentTotalGoldCost,
      totalPaidByMember: totalPaidByMember,
      settlementDifference: settlementDiff,
      settlementStatus: initialStatus,
      handoverDate: now,
      settlementDate: settlementDiff == 0 ? now : null,
      slotNumber: slotNumber,
      notes: notes,
    );

    // Write handover record
    await handoverRef.set(handover.toFirebase());

    // Create a goldHandover transaction for the audit trail
    final txnRef = _db.child('transactions').push();
    final txnId = txnRef.key!;

    final amountInCents = CurrencyUtils.toCents(currentTotalGoldCost);

    // Read current balance
    final slotSnap = await _db
        .child('chittis/$chittiId/members/$slotId/balance')
        .get();
    int currentBalanceCents = 0;
    if (slotSnap.exists && slotSnap.value != null) {
      final balance = Map<String, dynamic>.from(slotSnap.value as Map);
      currentBalanceCents = CurrencyUtils.toCents(
        (balance['totalPaid'] as num?)?.toDouble() ?? 0,
      );
    }

    final txn = Transaction(
      id: txnId,
      slotId: slotId,
      chittiId: chittiId,
      type: TransactionType.goldHandover,
      amountInCents: amountInCents,
      balanceBeforeInCents: currentBalanceCents,
      balanceAfterInCents: currentBalanceCents,
      monthKey: _currentMonthKey(),
      status: TransactionStatus.verified,
      notes:
          'Gold handover: $goldType $goldPurity ${goldWeight}g at $currentTotalGoldCost',
      createdAt: now,
      userId: userId,
      userName: userName,
      slotNumber: slotNumber,
    );

    await txnRef.set(txn.toFirebase());

    // Update transaction index for this slot
    await _db
        .child('chittis/$chittiId/transactionIndex/$slotId/$txnId')
        .set(true);

    // Update handover with transaction ID
    await handoverRef.child('transactionIds').set([txnId]);

    // Update slot settlement flags
    await _updateSlotSettlement(
      chittiId: chittiId,
      slotId: slotId,
      status: initialStatus,
      handoverId: handoverId,
      currentTotalGoldCost: currentTotalGoldCost,
      settlementDifference: settlementDiff,
    );

    return handover;
  }

  /// Settle up with one-time payment (member pays remaining balance)
  Future<Transaction> settleUpOneTime({
    required String chittiId,
    required String slotId,
    required String handoverId,
    required double amount,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? referenceNumber,
    String? notes,
    String? userId,
    String? userName,
    int? slotNumber,
  }) async {
    final amountInCents = CurrencyUtils.toCents(amount);

    // Record settlement payment through TransactionService
    final txnRef = _db.child('transactions').push();
    final txnId = txnRef.key!;

    final slotSnap = await _db
        .child('chittis/$chittiId/members/$slotId/balance')
        .get();
    int currentBalanceCents = 0;
    if (slotSnap.exists && slotSnap.value != null) {
      final balance = Map<String, dynamic>.from(slotSnap.value as Map);
      currentBalanceCents = CurrencyUtils.toCents(
        (balance['totalPaid'] as num?)?.toDouble() ?? 0,
      );
    }

    final newBalanceCents = currentBalanceCents + amountInCents;

    final txn = Transaction(
      id: txnId,
      slotId: slotId,
      chittiId: chittiId,
      type: TransactionType.settlementPayment,
      amountInCents: amountInCents,
      balanceBeforeInCents: currentBalanceCents,
      balanceAfterInCents: newBalanceCents,
      monthKey: _currentMonthKey(),
      status: TransactionStatus.verified,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes ?? 'One-time settlement payment',
      createdAt: DateTime.now(),
      userId: userId,
      userName: userName,
      slotNumber: slotNumber,
    );

    await txnRef.set(txn.toFirebase());

    // Update slot balance
    await _db.child('chittis/$chittiId/members/$slotId/balance').update({
      'totalPaid': CurrencyUtils.fromCents(newBalanceCents),
    });

    // Update transaction index
    await _db
        .child('chittis/$chittiId/transactionIndex/$slotId/$txnId')
        .set(true);

    // Update handover record
    await _db.child('gold_handovers/$handoverId').update({
      'settlementType': SettlementType.oneTimePayment.name,
      'settlementStatus': SlotSettlementStatus.settledUp.name,
      'settlementDate': DateTime.now().toIso8601String(),
      'transactionIds': (await _getHandoverTxnIds(handoverId))..add(txnId),
    });

    // Update slot status
    await _updateSlotSettlement(
      chittiId: chittiId,
      slotId: slotId,
      status: SlotSettlementStatus.settledUp,
    );

    return txn;
  }

  /// Revamp remaining balance as new EMI installments
  ///
  /// Splits the remaining balance into [installmentCount] new EMI entries.
  /// Must be within remaining chitti duration.
  Future<void> revampAsEMI({
    required String chittiId,
    required String slotId,
    required String handoverId,
    required double remainingAmount,
    required int installmentCount,
    String? userId,
    String? userName,
    int? slotNumber,
  }) async {
    if (installmentCount <= 0) {
      throw ArgumentError('Installment count must be greater than 0');
    }

    final emiAmount = remainingAmount / installmentCount;

    // Update handover record with revamp details
    await _db.child('gold_handovers/$handoverId').update({
      'settlementType': SettlementType.revampEMI.name,
      'settlementStatus': SlotSettlementStatus.settlementPending.name,
      'revampEMICount': installmentCount,
      'revampEMIAmount': emiAmount,
    });

    // Update slot with settlement info
    await _updateSlotSettlement(
      chittiId: chittiId,
      slotId: slotId,
      status: SlotSettlementStatus.settlementPending,
    );

    // Store revamp EMI details on the slot for the payment screen to pick up
    await _db.child('chittis/$chittiId/members/$slotId').update({
      'revampEMICount': installmentCount,
      'revampEMIAmount': emiAmount,
      'revampRemainingAmount': remainingAmount,
    });
  }

  /// Record a manual settlement transaction
  Future<Transaction> recordManualSettlement({
    required String chittiId,
    required String slotId,
    required String handoverId,
    required double amount,
    required bool
    isReceive, // true = receiving from member, false = giving to member
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? referenceNumber,
    String? notes,
    String? userId,
    String? userName,
    int? slotNumber,
  }) async {
    final amountInCents = CurrencyUtils.toCents(amount);

    final slotSnap = await _db
        .child('chittis/$chittiId/members/$slotId/balance')
        .get();
    int currentBalanceCents = 0;
    if (slotSnap.exists && slotSnap.value != null) {
      final balance = Map<String, dynamic>.from(slotSnap.value as Map);
      currentBalanceCents = CurrencyUtils.toCents(
        (balance['totalPaid'] as num?)?.toDouble() ?? 0,
      );
    }

    final txnType = isReceive
        ? TransactionType.settlementPayment
        : TransactionType.settlementRefund;

    final newBalanceCents = isReceive
        ? currentBalanceCents + amountInCents
        : currentBalanceCents - amountInCents;

    final txnRef = _db.child('transactions').push();
    final txnId = txnRef.key!;

    final txn = Transaction(
      id: txnId,
      slotId: slotId,
      chittiId: chittiId,
      type: txnType,
      amountInCents: amountInCents,
      balanceBeforeInCents: currentBalanceCents,
      balanceAfterInCents: newBalanceCents,
      monthKey: _currentMonthKey(),
      status: TransactionStatus.verified,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes ?? (isReceive ? 'Settlement received' : 'Settlement refund'),
      createdAt: DateTime.now(),
      userId: userId,
      userName: userName,
      slotNumber: slotNumber,
    );

    await txnRef.set(txn.toFirebase());

    // Update slot balance
    await _db.child('chittis/$chittiId/members/$slotId/balance').update({
      'totalPaid': CurrencyUtils.fromCents(newBalanceCents),
    });

    // Update transaction index
    await _db
        .child('chittis/$chittiId/transactionIndex/$slotId/$txnId')
        .set(true);

    // Update handover record
    await _db.child('gold_handovers/$handoverId').update({
      'settlementType': SettlementType.manualTransaction.name,
      'transactionIds': (await _getHandoverTxnIds(handoverId))..add(txnId),
    });

    // Check if settlement is complete after this transaction
    await _checkAndUpdateSettlemntCompletion(
      chittiId: chittiId,
      slotId: slotId,
      handoverId: handoverId,
    );

    return txn;
  }

  /// Process refund to member (organizer owes money)
  Future<Transaction> processRefund({
    required String chittiId,
    required String slotId,
    required String handoverId,
    required double amount,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? referenceNumber,
    String? notes,
    String? userId,
    String? userName,
    int? slotNumber,
  }) async {
    final amountInCents = CurrencyUtils.toCents(amount);

    final slotSnap = await _db
        .child('chittis/$chittiId/members/$slotId/balance')
        .get();
    int currentBalanceCents = 0;
    if (slotSnap.exists && slotSnap.value != null) {
      final balance = Map<String, dynamic>.from(slotSnap.value as Map);
      currentBalanceCents = CurrencyUtils.toCents(
        (balance['totalPaid'] as num?)?.toDouble() ?? 0,
      );
    }

    final newBalanceCents = currentBalanceCents - amountInCents;

    final txnRef = _db.child('transactions').push();
    final txnId = txnRef.key!;

    final txn = Transaction(
      id: txnId,
      slotId: slotId,
      chittiId: chittiId,
      type: TransactionType.settlementRefund,
      amountInCents: amountInCents,
      balanceBeforeInCents: currentBalanceCents,
      balanceAfterInCents: newBalanceCents,
      monthKey: _currentMonthKey(),
      status: TransactionStatus.verified,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes ?? 'Refund to member (gold rate difference)',
      createdAt: DateTime.now(),
      userId: userId,
      userName: userName,
      slotNumber: slotNumber,
    );

    await txnRef.set(txn.toFirebase());

    // Update slot balance
    await _db.child('chittis/$chittiId/members/$slotId/balance').update({
      'totalPaid': CurrencyUtils.fromCents(newBalanceCents),
    });

    // Update transaction index
    await _db
        .child('chittis/$chittiId/transactionIndex/$slotId/$txnId')
        .set(true);

    // Mark handover as refund completed
    await _db.child('gold_handovers/$handoverId').update({
      'settlementType': SettlementType.refund.name,
      'settlementStatus': SlotSettlementStatus.refundCompleted.name,
      'settlementDate': DateTime.now().toIso8601String(),
      'transactionIds': (await _getHandoverTxnIds(handoverId))..add(txnId),
    });

    // Update slot status
    await _updateSlotSettlement(
      chittiId: chittiId,
      slotId: slotId,
      status: SlotSettlementStatus.refundCompleted,
    );

    return txn;
  }

  /// Reverse a gold handover (undo mistake)
  Future<void> reverseHandover({
    required String chittiId,
    required String slotId,
    required String handoverId,
  }) async {
    // Reset slot settlement flags
    await _updateSlotSettlement(
      chittiId: chittiId,
      slotId: slotId,
      status: SlotSettlementStatus.none,
      handoverId: null,
      currentTotalGoldCost: null,
      settlementDifference: null,
    );

    // Remove handover record
    await _db.child('gold_handovers/$handoverId').remove();

    // Clean up revamp EMI data if any
    await _db
        .child('chittis/$chittiId/members/$slotId/revampEMICount')
        .remove();
    await _db
        .child('chittis/$chittiId/members/$slotId/revampEMIAmount')
        .remove();
    await _db
        .child('chittis/$chittiId/members/$slotId/revampRemainingAmount')
        .remove();
  }

  // ============ Query Operations ============

  /// Get handover details by ID
  Future<GoldHandover?> getHandover(String handoverId) async {
    final snap = await _db.child('gold_handovers/$handoverId').get();
    if (!snap.exists) return null;
    return GoldHandover.fromFirebase(
      handoverId,
      Map<String, dynamic>.from(snap.value as Map),
    );
  }

  /// Get handover for a specific slot
  Future<GoldHandover?> getSlotHandover(String chittiId, String slotId) async {
    final snap = await _db
        .child('gold_handovers')
        .orderByChild('slotId')
        .equalTo(slotId)
        .get();

    if (!snap.exists) return null;

    final data = Map<String, dynamic>.from(snap.value as Map);
    for (final entry in data.entries) {
      final handoverData = Map<String, dynamic>.from(entry.value as Map);
      if (handoverData['chittiId'] == chittiId) {
        return GoldHandover.fromFirebase(entry.key, handoverData);
      }
    }

    return null;
  }

  /// Get all handovers for a chitti
  Future<List<GoldHandover>> getChittiHandovers(String chittiId) async {
    final snap = await _db
        .child('gold_handovers')
        .orderByChild('chittiId')
        .equalTo(chittiId)
        .get();

    if (!snap.exists) return [];

    final handovers = <GoldHandover>[];
    final data = Map<String, dynamic>.from(snap.value as Map);
    for (final entry in data.entries) {
      handovers.add(
        GoldHandover.fromFirebase(
          entry.key,
          Map<String, dynamic>.from(entry.value as Map),
        ),
      );
    }

    handovers.sort((a, b) => b.handoverDate.compareTo(a.handoverDate));
    return handovers;
  }

  // ============ Private Helpers ============

  /// Update slot's settlement fields in Firebase
  Future<void> _updateSlotSettlement({
    required String chittiId,
    required String slotId,
    required SlotSettlementStatus status,
    String? handoverId,
    double? currentTotalGoldCost,
    double? settlementDifference,
  }) async {
    final updates = <String, dynamic>{'settlementStatus': status.name};

    // Only set these if explicitly provided
    if (handoverId != null) {
      updates['goldHandoverId'] = handoverId;
    }
    if (currentTotalGoldCost != null) {
      updates['currentTotalGoldCost'] = currentTotalGoldCost;
    }
    if (settlementDifference != null) {
      updates['settlementDifference'] = settlementDifference;
    }

    // For reset (reversal), clear the fields
    if (status == SlotSettlementStatus.none) {
      updates['goldHandoverId'] = null;
      updates['currentTotalGoldCost'] = null;
      updates['settlementDifference'] = null;
    }

    await _db.child('chittis/$chittiId/members/$slotId').update(updates);
  }

  /// Get existing transaction IDs for a handover
  Future<List<String>> _getHandoverTxnIds(String handoverId) async {
    final snap = await _db
        .child('gold_handovers/$handoverId/transactionIds')
        .get();

    if (!snap.exists) return [];

    if (snap.value is List) {
      return (snap.value as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Check if settlement is complete after a manual transaction
  Future<void> _checkAndUpdateSettlemntCompletion({
    required String chittiId,
    required String slotId,
    required String handoverId,
  }) async {
    final handover = await getHandover(handoverId);
    if (handover == null) return;

    // Get current total paid
    final slotSnap = await _db
        .child('chittis/$chittiId/members/$slotId/balance')
        .get();

    if (!slotSnap.exists) return;

    final balanceData = Map<String, dynamic>.from(slotSnap.value as Map);
    final totalPaid = (balanceData['totalPaid'] as num?)?.toDouble() ?? 0;

    // If total paid >= current gold cost, settlement is complete
    if (totalPaid >= handover.currentTotalGoldCost) {
      await _db.child('gold_handovers/$handoverId').update({
        'settlementStatus': SlotSettlementStatus.settledUp.name,
        'settlementDate': DateTime.now().toIso8601String(),
      });

      await _updateSlotSettlement(
        chittiId: chittiId,
        slotId: slotId,
        status: SlotSettlementStatus.settledUp,
      );
    }
  }

  /// Get current month key in YYYY-MM format
  String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
}
