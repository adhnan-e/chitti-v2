/// Chitti Name Generator Utility
/// Generates chitti names based on configurable format patterns and templates
class ChittiNameGenerator {
  // Singleton pattern
  static final ChittiNameGenerator _instance = ChittiNameGenerator._internal();
  factory ChittiNameGenerator() => _instance;
  ChittiNameGenerator._internal();

  // Template variable constants
  static const String VAR_NUMBER = '{number}';
  static const String VAR_LETTER = '{letter}';
  static const String VAR_MONTH = '{month}';
  static const String VAR_YEAR = '{year}';
  static const String VAR_DURATION = '{duration}';
  static const String VAR_PREFIX = '{prefix}';

  /// Generate next chitti name based on settings and context
  Future<String> generateNextName({
    required Map<String, dynamic> appSettings,
    required int duration,
    required String startMonth,
  }) async {
    try {
      // Get settings
      final format = appSettings['chittiNameFormat'] as String? ?? 'numeric';
      final template = appSettings['chittiNameTemplate'] as String? ?? '{prefix} {number}';
      final prefix = appSettings['chittiNamePrefix'] as String? ?? 'Chitti';
      final lastNumber = appSettings['lastChittiNumber'] as int? ?? 0;

      // Next number
      final nextNumber = lastNumber + 1;

      // Extract month and year
      final monthAbbr = extractMonthAbbr(startMonth);
      final year = extractYear(startMonth);

      // Build variable map
      final variables = {
        VAR_NUMBER: '$nextNumber',
        VAR_LETTER: numberToLetter(nextNumber),
        VAR_MONTH: monthAbbr,
        VAR_YEAR: year,
        VAR_DURATION: '$duration',
        VAR_PREFIX: prefix,
      };

      // Parse template and return
      return parseTemplate(template: template, variables: variables);
    } catch (e) {
      print('Error generating chitti name: $e');
      // Fallback to default format
      final lastNumber = appSettings['lastChittiNumber'] as int? ?? 0;
      final prefix = appSettings['chittiNamePrefix'] as String? ?? 'Chitti';
      return '$prefix ${lastNumber + 1}';
    }
  }

  /// Convert number to Excel-style letter
  /// Examples: 1=A, 26=Z, 27=AA, 52=AZ, 702=ZZ, 703=AAA
  String numberToLetter(int number) {
    if (number <= 0) return 'A';

    String result = '';
    int num = number;

    while (num > 0) {
      int remainder = (num - 1) % 26;
      result = String.fromCharCode(65 + remainder) + result;
      num = (num - 1) ~/ 26;
    }

    return result;
  }

  /// Convert letter to number (reverse of numberToLetter)
  /// Examples: A=1, Z=26, AA=27, AZ=52, ZZ=702
  int letterToNumber(String letter) {
    if (letter.isEmpty) return 0;

    int result = 0;
    for (int i = 0; i < letter.length; i++) {
      int charValue = letter.codeUnitAt(i) - 64; // A=1, B=2, etc.
      result = result * 26 + charValue;
    }

    return result;
  }

  /// Parse template and replace variables
  String parseTemplate({
    required String template,
    required Map<String, String> variables,
  }) {
    String result = template;

    // Replace each variable
    variables.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    // Clean up: trim and remove multiple spaces
    result = result.trim().replaceAll(RegExp(r'\s+'), ' ');

    return result;
  }

  /// Validate template string
  bool validateTemplate(String template) {
    // Check 1: Not empty
    if (template.trim().isEmpty) {
      return false;
    }

    // Check 2: Length limit
    if (template.length > 50) {
      return false;
    }

    // Check 3: At least one valid variable
    final validVars = [
      VAR_NUMBER,
      VAR_LETTER,
      VAR_MONTH,
      VAR_YEAR,
      VAR_DURATION,
      VAR_PREFIX,
    ];
    final hasVariable = validVars.any((v) => template.contains(v));
    if (!hasVariable) {
      return false;
    }

    // Check 4: Balanced brackets
    final openCount = '{'.allMatches(template).length;
    final closeCount = '}'.allMatches(template).length;
    if (openCount != closeCount) {
      return false;
    }

    // Check 5: No invalid variables
    final bracketPattern = RegExp(r'\{([^}]+)\}');
    final matches = bracketPattern.allMatches(template);
    for (var match in matches) {
      final variable = match.group(0);
      if (!validVars.contains(variable)) {
        return false;
      }
    }

    return true;
  }

  /// Get list of available variables
  List<String> getAvailableVariables() {
    return [
      VAR_NUMBER,
      VAR_LETTER,
      VAR_MONTH,
      VAR_YEAR,
      VAR_DURATION,
      VAR_PREFIX,
    ];
  }

  /// Extract month abbreviation from "January 2025" format
  String extractMonthAbbr(String startMonth) {
    if (startMonth.isEmpty) return '';

    final parts = startMonth.split(' ');
    if (parts.isNotEmpty && parts[0].length >= 3) {
      return parts[0].substring(0, 3); // "Jan", "Feb", etc.
    }

    return '';
  }

  /// Extract year from "January 2025" format
  String extractYear(String startMonth) {
    if (startMonth.isEmpty) return '';

    final parts = startMonth.split(' ');
    return parts.length > 1 ? parts[1] : '';
  }

  /// Check if counter is approaching limit
  bool isCounterNearLimit(int counter, String format) {
    switch (format) {
      case 'numeric':
        return counter >= 900000; // Warn at 900k
      case 'alphabetic':
      case 'alphanumeric':
        return counter >= 17000; // Warn near ZZZ (18278)
      default:
        return false;
    }
  }

  /// Get default template for a format
  String getDefaultTemplate(String format) {
    switch (format) {
      case 'numeric':
        return '{prefix} {number}';
      case 'alphanumeric':
        return '{prefix} {letter}{number}';
      case 'alphabetic':
        return '{prefix} {letter}';
      case 'custom':
        return '{prefix}-{number}-{month}';
      default:
        return '{prefix} {number}';
    }
  }
}
