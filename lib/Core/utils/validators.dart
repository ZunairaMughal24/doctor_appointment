class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != password) return 'Passwords do not match.';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required.';
    return null;
  }

  /// Person/professional name: letters, spaces and . ' - only (no digits/garbage).
  static String? name(String? value, [String field = 'Name']) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$field is required.';
    if (v.length < 2) return '$field is too short.';
    if (!RegExp(r"^[A-Za-z][A-Za-z .'-]*$").hasMatch(v)) {
      return 'Enter a valid $field (letters only).';
    }
    return null;
  }

  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required.';
    // Allow +, spaces, dashes and parentheses but require 10–15 actual digits.
    if (!RegExp(r'^[+\d][\d\s()-]{8,}$').hasMatch(v)) {
      return 'Enter a valid phone number.';
    }
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  /// Free-text professional fields that must contain real words, not just
  /// symbols/numbers (e.g. speciality, experience, location, services).
  static String? text(String? value, String field, {int min = 2}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$field is required.';
    if (v.length < min) return '$field is too short.';
    if (!RegExp(r'[A-Za-z]').hasMatch(v)) return 'Enter a valid $field.';
    return null;
  }
}
