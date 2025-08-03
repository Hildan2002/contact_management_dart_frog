import 'dart:io';

import 'package:dotenv/dotenv.dart';

/// Configuration utility class for loading and accessing environment variables.
class EnvConfig {
  static final DotEnv _env = DotEnv();
  static bool _isLoaded = false;

  /// Loads environment variables from .env file if it exists.
  static void load() {
    if (_isLoaded) return;

    final envFile = File('.env');
    if (envFile.existsSync()) {
      _env.load(['.env']);
    }
    _isLoaded = true;
  }

  /// Gets a string value from environment variables.
  static String getString(String key, {String? defaultValue}) {
    load();
    return _env[key] ?? defaultValue ?? '';
  }

  /// Gets a duration value from environment variables with time unit parsing.
  static Duration getDuration(String key, {Duration? defaultValue}) {
    load();
    final value = _env[key];
    if (value == null) return defaultValue ?? Duration.zero;

    if (value.endsWith('h')) {
      final hours = int.tryParse(value.substring(0, value.length - 1));
      return hours != null
          ? Duration(hours: hours)
          : (defaultValue ?? Duration.zero);
    }

    if (value.endsWith('m')) {
      final minutes = int.tryParse(value.substring(0, value.length - 1));
      return minutes != null
          ? Duration(minutes: minutes)
          : (defaultValue ?? Duration.zero);
    }

    if (value.endsWith('d')) {
      final days = int.tryParse(value.substring(0, value.length - 1));
      return days != null
          ? Duration(days: days)
          : (defaultValue ?? Duration.zero);
    }

    final seconds = int.tryParse(value);
    return seconds != null
        ? Duration(seconds: seconds)
        : (defaultValue ?? Duration.zero);
  }

  /// JWT secret key for token signing and verification.
  static String get jwtSecret =>
      getString('JWT_SECRET', defaultValue: 'fallback-secret-key');

  /// JWT access token expiration duration.
  static Duration get jwtAccessTokenExpiresIn => getDuration(
        'JWT_ACCESS_TOKEN_EXPIRES_IN',
        defaultValue: const Duration(minutes: 15),
      );

  /// JWT refresh token expiration duration.
  static Duration get jwtRefreshTokenExpiresIn => getDuration(
        'JWT_REFRESH_TOKEN_EXPIRES_IN',
        defaultValue: const Duration(days: 30),
      );

  /// Database file path.
  static String get databasePath =>
      getString('DATABASE_PATH', defaultValue: 'contacts.db');

  /// Password reset token expiration duration.
  static Duration get passwordResetTokenExpiresIn => getDuration(
        'PASSWORD_RESET_TOKEN_EXPIRES_IN',
        defaultValue: const Duration(hours: 1),
      );

  /// Application name.
  static String get appName =>
      getString('APP_NAME', defaultValue: 'Contact Management API');

  /// Application version.
  static String get appVersion =>
      getString('APP_VERSION', defaultValue: '1.0.0');

  /// Node environment (development, production, etc.).
  static String get nodeEnv =>
      getString('NODE_ENV', defaultValue: 'development');

  /// Whether the application is running in development mode.
  static bool get isDevelopment => nodeEnv == 'development';

  /// Whether the application is running in production mode.
  static bool get isProduction => nodeEnv == 'production';
}
