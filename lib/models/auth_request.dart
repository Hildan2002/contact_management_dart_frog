import 'package:equatable/equatable.dart';

/// Request model for user login.
class LoginRequest extends Equatable {
  /// Creates a new LoginRequest.
  const LoginRequest({
    required this.email,
    required this.password,
  });

  /// Creates a LoginRequest from a JSON map.
  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;

  /// Converts the LoginRequest to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  List<Object?> get props => [email, password];
}

/// Request model for user registration.
class RegisterRequest extends Equatable {
  /// Creates a new RegisterRequest.
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  /// Creates a RegisterRequest from a JSON map.
  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
    );
  }

  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;

  /// The user's display name.
  final String name;

  /// Converts the RegisterRequest to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }

  /// Properties used for equality comparison.
  @override
  List<Object?> get props => [email, password, name];
}

/// Response model for authentication operations.
class AuthResponse extends Equatable {
  /// Creates a new AuthResponse.
  const AuthResponse({
    required this.token,
    required this.user,
    this.refreshToken,
  });

  /// The JWT authentication token.
  final String token;

  /// The authenticated user data.
  final Map<String, dynamic> user;

  /// The refresh token (optional).
  final String? refreshToken;

  /// Converts the AuthResponse to a JSON map.
  Map<String, dynamic> toJson() {
    final json = {
      'token': token,
      'user': user,
    };
    if (refreshToken != null) {
      json['refresh_token'] = refreshToken!;
    }
    return json;
  }

  @override
  List<Object?> get props => [token, user, refreshToken];
}

/// Request model for refreshing tokens.
class RefreshTokenRequest extends Equatable {
  /// Creates a new RefreshTokenRequest.
  const RefreshTokenRequest({
    required this.refreshToken,
  });

  /// Creates a RefreshTokenRequest from a JSON map.
  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) {
    return RefreshTokenRequest(
      refreshToken: json['refresh_token'] as String,
    );
  }

  /// The refresh token.
  final String refreshToken;

  /// Converts the RefreshTokenRequest to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
    };
  }

  @override
  List<Object?> get props => [refreshToken];
}

/// Request model for updating password.
class UpdatePasswordRequest extends Equatable {
  /// Creates a new UpdatePasswordRequest.
  const UpdatePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  /// Creates an UpdatePasswordRequest from a JSON map.
  factory UpdatePasswordRequest.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordRequest(
      currentPassword: json['current_password'] as String,
      newPassword: json['new_password'] as String,
    );
  }

  /// The user's current password.
  final String currentPassword;

  /// The user's new password.
  final String newPassword;

  /// Converts the UpdatePasswordRequest to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
  }

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Request model for forgot password.
class ForgotPasswordRequest extends Equatable {
  /// Creates a new ForgotPasswordRequest.
  const ForgotPasswordRequest({
    required this.email,
  });

  /// Creates a ForgotPasswordRequest from a JSON map.
  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequest(
      email: json['email'] as String,
    );
  }

  /// The user's email address.
  final String email;

  /// Converts the ForgotPasswordRequest to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  @override
  List<Object?> get props => [email];
}

/// Request model for resetting password.
class ResetPasswordRequest extends Equatable {
  /// Creates a new ResetPasswordRequest.
  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  /// Creates a ResetPasswordRequest from a JSON map.
  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      token: json['token'] as String,
      newPassword: json['new_password'] as String,
    );
  }

  /// The password reset token.
  final String token;

  /// The user's new password.
  final String newPassword;

  /// Converts the ResetPasswordRequest to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'new_password': newPassword,
    };
  }

  @override
  List<Object?> get props => [token, newPassword];
}
