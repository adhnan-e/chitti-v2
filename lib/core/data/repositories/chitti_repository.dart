/// Repository interface for Chitti data operations
///
/// Defines the contract for chitti data access, independent of
/// the underlying data source (Firebase, Supabase, PostgreSQL, etc.)
library;

import 'package:chitt/core/models/models.dart';

/// Repository interface for Chitti operations
abstract class ChittiRepository {
  /// Create a new chitti
  ///
  /// Returns the ID of the created chitti
  Future<String> createChitti(Chitti chitti);

  /// Get a chitti by ID
  ///
  /// Returns null if not found
  Future<Chitti?> getChitti(String id);

  /// Get all chittis
  ///
  /// Optional filters for status, date range, etc.
  Future<List<Chitti>> getAllChittis({
    ChittiStatus? status,
    DateTime? from,
    DateTime? to,
  });

  /// Get chittis for a specific user
  Future<List<Chitti>> getUserChittis(String userId);

  /// Update a chitti
  ///
  /// Performs partial update with provided fields
  Future<void> updateChitti(String id, Map<String, dynamic> data);

  /// Delete a chitti
  Future<void> deleteChitti(String id);

  /// Stream updates to a chitti
  Stream<Chitti?> watchChitti(String id);

  /// Start a chitti (change status to active)
  Future<void> startChitti(String id);

  /// Advance chitti to next month
  Future<void> advanceMonth(String id);

  // ========== Slot Operations ==========

  /// Add a slot to a chitti
  Future<Slot> addSlotToChitti(String chittiId, Slot slot);

  /// Get all slots for a chitti
  Future<List<Slot>> getChittiSlots(String chittiId);

  /// Get a specific slot
  Future<Slot?> getSlot(String chittiId, String slotId);

  /// Update a slot
  Future<void> updateSlot(String chittiId, String slotId, Map<String, dynamic> data);

  /// Delete a slot
  Future<void> deleteSlot(String chittiId, String slotId);

  /// Get slots for a user in a chitti
  Future<List<Slot>> getUserSlots(String chittiId, String userId);

  /// Get next available slot number for a chitti
  Future<int> getNextSlotNumber(String chittiId);
}
