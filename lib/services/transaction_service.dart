/// Transaction Service - THE SINGLE SOURCE OF TRUTH
///
/// "Rule of One": Every financial change flows through this service.
/// Uses atomic Firebase transactions to ensure data consistency.
/// Transactions are IMMUTABLE - never edited, only reversed.
library;

import 'package:firebase_database/firebase_database.dart' hide Transaction;
import '../core/models/transaction.dart';
import '../utils/currency_utils.dart';

/// TransactionService - The core accounting engine
///
/// All balance changes MUST go through this service to maintain
/// the "Rule of One" principle and ensure zero accounting errors.
class TransactionService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Singleton pattern
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  // ============ Core Transaction Operations ============

  /// Record a payment - ATOMIC operation
  ///
  /// Creates a transaction and updates slot balance atomically.
  /// Returns the created transaction.
  Future<Transaction> recordPayment({
    required String slotId,
    required String chittyId,
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

    // Generate receipt number
    final receiptNumber = _generateReceiptNumber(chittyId);

    // Create the transaction record first
    final now = DateTime.now();

    // Read current balance
    final slotSnap = await _db
        .child('chittis/$chittyId/members/$slotId/balance')
        .get();

    int currentBalanceCents = 0;
    if (slotSnap.exists && slotSnap.value != null) {
      final balance = Map<String, dynamic>.from(slotSnap.value as Map);
      currentBalanceCents = CurrencyUtils.toCents(
        (balance['totalPaid'] as num?)?.toDouble() ?? 0,
      );
    }

    final newBalanceCents = currentBalanceCents + amountInCents;

    final createdTxn = Transaction(
      id: txnId,
      slotId: slotId,
      chittiId: chittyId,
      type: TransactionType.payment,
      amountInCents: amountInCents,
      balanceBeforeInCents: currentBalanceCents,
      balanceAfterInCents: newBalanceCents,
      monthKey: monthKey,
      status: status, // Use the passed status (defaults to pending)
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
      receiptNumber: receiptNumber,
      createdAt: now,
      userId: userId,
      userName: userName,
      slotNumber: slotNumber,
    );

    // Write transaction document
    await txnRef.set(createdTxn.toFirebase());

    // Update slot balance
    await _db.child('chittis/$chittyId/members/$slotId/balance').update({
      'totalPaid': CurrencyUtils.fromCents(newBalanceCents),
      'lastPaymentDate': now.toIso8601String().split('T')[0],
    });

    // Update transaction index
    await _db
        .child('chittis/$chittyId/transactionIndex/$slotId/$txnId')
        .set(true);

    return createdTxn;
  }

  /// Verify a pending payment
  ///
  /// Called by organizer to confirm payment receipt.
  Future<void> verifyPayment({
    required String transactionId,
    required String verifiedBy,
  }) async {
    final now = DateTime.now();

    await _db.child('transactions/$transactionId').update({
      'status': TransactionStatus.verified.name,
      'verifiedAt': now.toIso8601String(),
      'verifiedBy': verifiedBy,
    });
  }

  /// Reject a pending payment
  ///
  /// Called when payment bounced or was invalid.
  /// This reverses the balance change.
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
      final newTotalPaid = totalPaid - txn.amount;

      await _db
          .child('chittis/${txn.chittiId}/members/${txn.slotId}/balance')
          .update({'totalPaid': newTotalPaid});
    }
  }

  /// Reverse a transaction
  ///
  /// Creates a counter-transaction that negates the original.
  /// Original transaction is never modified.
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
    return await recordPayment(
      slotId: original.slotId,
      chittyId: original.chittiId,
      amountInCents: -original.amountInCents, // Negative to reverse
      monthKey: original.monthKey,
      paymentMethod: original.paymentMethod,
      notes: reason ?? 'Reversal of ${original.id}',
      userId: original.userId,
      userName: original.userName,
      slotNumber: original.slotNumber,
    );
  }

  // ============ Query Operations ============

  /// Get all transactions for a slot
  Future<List<Transaction>> getSlotTransactions(
    String chittyId,
    String slotId,
  ) async {
    try {
      // Get transaction IDs from index
      final indexSnap = await _db
          .child('chittis/$chittyId/transactionIndex/$slotId')
          .get();

      if (!indexSnap.exists) return [];

      final txnIds = (indexSnap.value as Map).keys.toList();
      final transactions = <Transaction>[];

      for (final txnId in txnIds) {
        final txnSnap = await _db.child('transactions/$txnId').get();
        if (txnSnap.exists) {
          final data = Map<String, dynamic>.from(txnSnap.value as Map);
          transactions.add(Transaction.fromFirebase(txnId as String, data));
        }
      }

      // Sort by creation date
      transactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return transactions;
    } catch (e) {
      print('Error getting slot transactions: $e');
      return [];
    }
  }

  /// Get a single transaction by ID
  Future<Transaction?> getTransaction(String transactionId) async {
    final snap = await _db.child('transactions/$transactionId').get();
    if (!snap.exists) return null;

    final data = Map<String, dynamic>.from(snap.value as Map);
    return Transaction.fromFirebase(transactionId, data);
  }

  /// Get pending transactions for a chitty
  Future<List<Transaction>> getPendingTransactions(String chittyId) async {
    final snap = await _db
        .child('transactions')
        .orderByChild('chittiId')
        .equalTo(chittyId)
        .get();

    if (!snap.exists) return [];

    final transactions = <Transaction>[];
    final data = Map<String, dynamic>.from(snap.value as Map);

    for (final entry in data.entries) {
      final txnData = Map<String, dynamic>.from(entry.value as Map);
      final txn = Transaction.fromFirebase(entry.key, txnData);
      if (txn.isPending) {
        transactions.add(txn);
      }
    }

    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return transactions;
  }

  /// Get all transactions for a chitti
  Future<List<Transaction>> getChittiTransactions(String chittiId) async {
    final snapshot = await _db
        .child('transactions')
        .orderByChild('chittiId')
        .equalTo(chittiId)
        .get();

    if (!snapshot.exists) return [];

    final transactions = <Transaction>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map);

    for (final entry in data.entries) {
      final txnData = Map<String, dynamic>.from(entry.value as Map);
      transactions.add(Transaction.fromFirebase(entry.key, txnData));
    }

    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return transactions;
  }

  /// Get transactions for a specific month
  Future<List<Transaction>> getMonthTransactions(
    String chittyId,
    String monthKey,
  ) async {
    final snap = await _db
        .child('transactions')
        .orderByChild('monthKey')
        .equalTo(monthKey)
        .get();

    if (!snap.exists) return [];

    final transactions = <Transaction>[];
    final data = Map<String, dynamic>.from(snap.value as Map);

    for (final entry in data.entries) {
      final txnData = Map<String, dynamic>.from(entry.value as Map);
      final txn = Transaction.fromFirebase(entry.key, txnData);
      if (txn.chittiId == chittyId) {
        transactions.add(txn);
      }
    }

    return transactions;
  }

  // ============ Helper Functions ============

  /// Generate a unique receipt number
  String _generateReceiptNumber(String chittyId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final shortId = chittyId.length >= 4
        ? chittyId.substring(0, 4).toUpperCase()
        : chittyId.toUpperCase();
    return 'RCP-$shortId-$timestamp';
  }

  /// Calculate verified balance for a slot
  Future<int> calculateVerifiedBalance(String chittyId, String slotId) async {
    final transactions = await getSlotTransactions(chittyId, slotId);
    return transactions
        .where((t) => t.isVerified)
        .fold<int>(0, (sum, t) => sum + t.effectiveAmountInCents);
  }

  /// Calculate total balance (including pending)
  Future<int> calculateTotalBalance(String chittyId, String slotId) async {
    final transactions = await getSlotTransactions(chittyId, slotId);
    return transactions
        .where((t) => !t.isRejected)
        .fold<int>(0, (sum, t) => sum + t.effectiveAmountInCents);
  }
}
