/// Barrel export for domain entities
///
/// Re-exports models from core/models as domain entities.
/// In a full implementation, these would be separate from data models,
/// but for this codebase we reuse the existing Freezed models.
library;

export '../../models/models.dart';
