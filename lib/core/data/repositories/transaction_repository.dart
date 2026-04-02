/// Repository interface for Transaction data operations
///
/// This is the ONLY way to modify balances (Rule of One).
/// All financial changes MUST go through this repository.
library;

import 'package:chitt/core/models/models.dart';
import 'package:chitt/core/models/transaction.dart';

/// Repository interface for Transaction operations
abstract class TransactionRepository {
  /// Record a new transaction
  ///
  /// This is the ONLY way to modify balances (Rule of One).
  /// The repository handles atomic balance updates.
  Future<Transaction> recordTransaction(Transaction transaction);

  /// Get a transaction by ID
  Future<Transaction?> getTransaction(String id);

  /// Get all transactions for a slot
  Future<List<Transaction>> getSlotTransactions(String chittiId, String slotId);

  /// Get all transactions for a chitti
  Future<List<Transaction>> getChittiTransactions(String chittiId);

  /// Get pending transactions for a chitti (awaiting verification)
  Future<List<Transaction>> getPendingTransactions(String chittiId);

  /// Get verified transactions for a chitti
  Future<List<Transaction>> getVerifiedTransactions(String chittiId);

  /// Get transactions for a specific month
  Future<List<Transaction>> getMonthTransactions(
    String chittiId,
    String monthKey,
  );

  /// Update transaction status
  ///
  /// Used for verifying or rejecting pending payments
  Future<void> updateTransactionStatus(String id, TransactionStatus status);

  /// Verify a transaction
  Future<void> verifyTransaction(String id, {required String verifiedBy});

  /// Reject a transaction
  Future<void> rejectTransaction(
    String id, {
    required String rejectedBy,
    String? reason,
  });

  /// Reverse a transaction (creates counter-transaction)
  ///
  /// Returns the reversal transaction
  Future<Transaction> reverseTransaction(
    String id, {
    required String reversedBy,
    String? reason,
  });

  /// Stream transactions for a chitti
  Stream<List<Transaction>> watchChittiTransactions(String chittiId);

  /// Stream transactions for a slot
  Stream<List<Transaction>> watchSlotTransactions(
    String chittiId,
    String slotId,
  );

  /// Calculate verified balance for a slot
  Future<int> calculateVerifiedBalance(String chittiId, String slotId);

  /// Calculate pending balance for a slot (includes pending transactions)
  Future<int> calculatePendingBalance(String chittiId, String slotId);
}
