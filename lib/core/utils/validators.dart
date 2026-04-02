/// Validation utilities for form inputs
///
/// Provides reusable validation functions for common input types
/// to ensure consistency across the application.
library;

/// Common form validators
class Validators {
  Validators._(); // Private constructor - utility class

  /// Validate that a field is not empty or null
  ///
  /// [value] - The input value to validate
  /// [fieldName] - Human-readable name for error message (e.g., 'Name', 'Phone')
  ///
  /// Returns error message if invalid, null if valid
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate phone number (UAE/India format: 8-15 digits)
  ///
  /// [value] - The phone number to validate
  ///
  /// Returns error message if invalid, null if valid or empty (optional field)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null; // Optional field

    // Remove common separators
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(cleaned)) {
      return 'Invalid phone number';
    }
    return null;
  }

  /// Validate email address
  ///
  /// [value] - The email to validate
  ///
  /// Returns error message if invalid, null if valid or empty (optional field)
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // Optional field

    // Basic email regex - covers most common cases
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  /// Validate password strength
  ///
  /// [value] - The password to validate
  /// [minLength] - Minimum password length (default: 6)
  ///
  /// Returns error message if invalid, null if valid
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validate minimum string length
  ///
  /// [value] - The input to validate
  /// [minLength] - Minimum required length
  /// [fieldName] - Human-readable name for error message
  ///
  /// Returns error message if invalid, null if valid or empty
  static String? minLength(String? value, int minLength, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) return null; // Optional field

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validate maximum string length
  ///
  /// [value] - The input to validate
  /// [maxLength] - Maximum allowed length
  /// [fieldName] - Human-readable name for error message
  ///
  /// Returns error message if invalid, null if valid
  static String? maxLength(String? value, int maxLength, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) return null; // Optional field

    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  /// Validate numeric input
  ///
  /// [value] - The input to validate
  /// [fieldName] - Human-readable name for error message
  /// [allowNegative] - Whether negative numbers are allowed (default: false)
  ///
  /// Returns error message if invalid, null if valid
  static String? number(String? value, [String fieldName = 'This field', bool allowNegative = false]) {
    if (value == null || value.isEmpty) return null; // Optional field

    final numValue = num.tryParse(value);
    if (numValue == null) {
      return '$fieldName must be a number';
    }
    if (!allowNegative && numValue < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  /// Validate integer input
  ///
  /// [value] - The input to validate
  /// [fieldName] - Human-readable name for error message
  /// [min] - Minimum allowed value (inclusive)
  /// [max] - Maximum allowed value (inclusive)
  ///
  /// Returns error message if invalid, null if valid
  static String? integer(String? value, [String fieldName = 'This field', int? min, int? max]) {
    if (value == null || value.isEmpty) return null; // Optional field

    final intValue = int.tryParse(value);
    if (intValue == null) {
      return '$fieldName must be a whole number';
    }
    if (min != null && intValue < min) {
      return '$fieldName must be at least $min';
    }
    if (max != null && intValue > max) {
      return '$fieldName must not exceed $max';
    }
    return null;
  }

  /// Validate date is not in the past
  ///
  /// [value] - The date to validate
  /// [fieldName] - Human-readable name for error message
  ///
  /// Returns error message if invalid, null if valid
  static String? notInPast(DateTime? value, [String fieldName = 'This date']) {
    if (value == null) return null; // Optional field

    final now = DateTime.now();
    final valueDate = DateTime(value.year, value.month, value.day);
    final today = DateTime(now.year, now.month, now.day);

    if (valueDate.isBefore(today)) {
      return '$fieldName cannot be in the past';
    }
    return null;
  }

  /// Validate date is not in the future
  ///
  /// [value] - The date to validate
  /// [fieldName] - Human-readable name for error message
  ///
  /// Returns error message if invalid, null if valid
  static String? notInFuture(DateTime? value, [String fieldName = 'This date']) {
    if (value == null) return null; // Optional field

    final now = DateTime.now();
    final valueDate = DateTime(value.year, value.month, value.day);
    final today = DateTime(now.year, now.month, now.day);

    if (valueDate.isAfter(today)) {
      return '$fieldName cannot be in the future';
    }
    return null;
  }

  /// Combine multiple validators
  ///
  /// [validators] - List of validator functions to apply
  ///
  /// Returns a combined validator function that runs all validators
  /// and returns the first error found (or null if all pass)
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

/// Pre-built validator combinations for common use cases
class CommonValidators {
  CommonValidators._(); // Private constructor - utility class

  /// Required name validator (required, 2-50 chars)
  static String? name(String? value) {
    return Validators.combine([
      (v) => Validators.required(v, 'Name'),
      (v) => Validators.minLength(v, 2, 'Name'),
      (v) => Validators.maxLength(v, 50, 'Name'),
    ])(value);
  }

  /// Required username validator (required, 3-20 chars, alphanumeric)
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must not exceed 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(value)) {
      return 'Username must start with a letter and contain only letters, numbers, and underscores';
    }
    return null;
  }

  /// Required password validator (required, min 6 chars)
  static String? password(String? value) {
    return Validators.password(value, minLength: 6);
  }

  /// Required phone validator
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    return Validators.phone(value);
  }

  /// Required email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    return Validators.email(value);
  }

  /// Required positive number validator
  static String? positiveNumber(String? value, [String fieldName = 'This value']) {
    return Validators.number(value, fieldName, false);
  }

  /// Required amount validator (for currency amounts)
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    return Validators.number(value, 'Amount', false);
  }
}
