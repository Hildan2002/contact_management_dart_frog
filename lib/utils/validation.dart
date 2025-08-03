/// Custom exception for validation errors.
class ValidationError implements Exception {
  /// Creates a validation error with the given message.
  ValidationError(this.message);

  /// The error message describing what validation failed.
  final String message;

  @override
  String toString() => 'ValidationError: $message';
}

/// Utility class for validating user input data.
class Validator {
  /// Validates that the given email has a proper format.
  static void validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      throw ValidationError('Invalid email format');
    }
  }

  /// Validates that the password meets minimum requirements.
  static void validatePassword(String password) {
    if (password.length < 6) {
      throw ValidationError('Password must be at least 6 characters long');
    }
  }

  /// Validates that a required field is not null or empty.
  static void validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      throw ValidationError('$fieldName is required');
    }
  }

  /// Validates that a name meets minimum length requirements.
  static void validateName(String name) {
    validateRequired(name, 'Name');
    if (name.trim().length < 2) {
      throw ValidationError('Name must be at least 2 characters long');
    }
  }

  /// Validates contact creation/update data.
  static void validateContactData(Map<String, dynamic> data) {
    validateRequired(data['first_name'] as String?, 'First name');
    validateRequired(data['last_name'] as String?, 'Last name');
    validateRequired(data['email'] as String?, 'Email');

    if (data['email'] != null) {
      validateEmail(data['email'] as String);
    }

    final firstName = data['first_name'] as String?;
    final lastName = data['last_name'] as String?;

    if (firstName != null && firstName.trim().length < 2) {
      throw ValidationError('First name must be at least 2 characters long');
    }

    if (lastName != null && lastName.trim().length < 2) {
      throw ValidationError('Last name must be at least 2 characters long');
    }
  }

  /// Validates login request data.
  static void validateLoginData(Map<String, dynamic> data) {
    validateRequired(data['email'] as String?, 'Email');
    validateRequired(data['password'] as String?, 'Password');

    if (data['email'] != null) {
      validateEmail(data['email'] as String);
    }
  }

  /// Validates user registration data.
  static void validateRegisterData(Map<String, dynamic> data) {
    validateRequired(data['email'] as String?, 'Email');
    validateRequired(data['password'] as String?, 'Password');
    validateRequired(data['name'] as String?, 'Name');

    if (data['email'] != null) {
      validateEmail(data['email'] as String);
    }

    if (data['password'] != null) {
      validatePassword(data['password'] as String);
    }

    if (data['name'] != null) {
      validateName(data['name'] as String);
    }
  }

  /// Validates update password request data.
  static void validateUpdatePasswordData(Map<String, dynamic> data) {
    validateRequired(data['current_password'] as String?, 'Current password');
    validateRequired(data['new_password'] as String?, 'New password');

    if (data['new_password'] != null) {
      validatePassword(data['new_password'] as String);
    }

    if (data['current_password'] == data['new_password']) {
      throw ValidationError(
        'New password must be different from current password',
      );
    }
  }

  /// Validates forgot password request data.
  static void validateForgotPasswordData(Map<String, dynamic> data) {
    validateRequired(data['email'] as String?, 'Email');

    if (data['email'] != null) {
      validateEmail(data['email'] as String);
    }
  }

  /// Validates reset password request data.
  static void validateResetPasswordData(Map<String, dynamic> data) {
    validateRequired(data['token'] as String?, 'Reset token');
    validateRequired(data['new_password'] as String?, 'New password');

    if (data['new_password'] != null) {
      validatePassword(data['new_password'] as String);
    }
  }
}
