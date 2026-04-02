/// Repository exceptions for data access layer errors
library;

/// Base exception for repository operations
class RepositoryException implements Exception {
  /// Error code for programmatic handling
  final String code;

  /// Human-readable error message
  final String message;

  /// Optional original error/exception
  final Object? originalError;

  /// Optional stack trace
  final StackTrace? stackTrace;

  const RepositoryException({
    required this.code,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (originalError != null) {
      return 'RepositoryException($code): $message\nOriginal: $originalError';
    }
    return 'RepositoryException($code): $message';
  }
}

/// Exception when data is not found
class NotFoundException extends RepositoryException {
  const NotFoundException({
    required String resourceType,
    required String id,
    super.originalError,
  }) : super(
          code: 'not-found',
          message: '$resourceType with id "$id" not found',
        );
}

/// Exception when user is not authorized
class UnauthorizedException extends RepositoryException {
  const UnauthorizedException({
    super.message = 'User is not authorized to perform this action',
    super.originalError,
  }) : super(
          code: 'unauthorized',
        );
}

/// Exception for network-related errors
class NetworkException extends RepositoryException {
  const NetworkException({
    super.message = 'Network error occurred. Please check your connection.',
    super.originalError,
  }) : super(
          code: 'network-error',
        );
}

/// Exception for database operation failures
class DatabaseException extends RepositoryException {
  const DatabaseException({
    required super.message,
    super.originalError,
  }) : super(
          code: 'database-error',
        );
}

/// Exception for validation errors
class ValidationException extends RepositoryException {
  /// Map of field names to error messages
  final Map<String, String> fieldErrors;

  ValidationException({
    required this.fieldErrors,
  }) : super(
          code: 'validation-error',
          message: 'Validation failed: ${fieldErrors.values.join(", ")}',
        );

  @override
  String toString() {
    return 'ValidationException: $message\nField errors: $fieldErrors';
  }
}

/// Exception for concurrent modification conflicts
class ConflictException extends RepositoryException {
  const ConflictException({
    super.message = 'Resource has been modified by another operation',
    super.originalError,
  }) : super(
          code: 'conflict',
        );
}

/// Exception for rate limiting
class RateLimitException extends RepositoryException {
  final Duration? retryAfter;

  const RateLimitException({
    super.message = 'Too many requests. Please try again later.',
    this.retryAfter,
    super.originalError,
  }) : super(
          code: 'rate-limit',
        );
}
