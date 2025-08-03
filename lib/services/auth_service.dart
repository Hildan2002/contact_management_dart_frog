import 'dart:developer';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:my_project/models/auth_request.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/services/database_service.dart';
import 'package:my_project/utils/env_config.dart';
import 'package:uuid/uuid.dart';

/// Service class for handling authentication operations.
class AuthService {
  /// Creates an AuthService with the provided database service.
  AuthService(this._databaseService);

  final DatabaseService _databaseService;
  final _uuid = const Uuid();

  /// Hashes a password using bcrypt.
  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  /// Verifies a password against its hash.
  bool verifyPassword(String password, String hashedPassword) {
    return BCrypt.checkpw(password, hashedPassword);
  }

  /// Generates a JWT token for the given user ID.
  String generateToken(String userId, {Duration? expiresIn}) {
    final expiration = expiresIn ?? EnvConfig.jwtAccessTokenExpiresIn;
    final jwt = JWT({
      'userId': userId,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(expiration).millisecondsSinceEpoch ~/ 1000,
    });

    return jwt.sign(SecretKey(EnvConfig.jwtSecret));
  }

  /// Generates a refresh token.
  String generateRefreshToken() {
    return _uuid.v8();
  }

  /// Verifies a JWT token and returns the user ID if valid.
  String? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(EnvConfig.jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;

      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (now > exp) {
        return null;
      }

      return payload['userId'] as String;
    } catch (e) {
      return null;
    }
  }

  /// Registers a new user and returns authentication response.
  Future<AuthResponse> register(RegisterRequest request) async {
    final db = _databaseService;

    final existingUser = db.getUserByEmail(request.email);
    if (existingUser != null) {
      throw Exception('User with email ${request.email} already exists');
    }

    final userId = _uuid.v8();
    final now = DateTime.now();

    final user = User(
      id: userId,
      email: request.email,
      passwordHash: hashPassword(request.password),
      name: request.name,
      createdAt: now,
      updatedAt: now,
    );

    db.createUser(user);

    final token = generateToken(userId);
    final refreshToken = generateRefreshToken();

    db.storeRefreshToken(
      _uuid.v8(),
      userId,
      refreshToken,
      DateTime.now().add(EnvConfig.jwtRefreshTokenExpiresIn),
    );

    return AuthResponse(
      token: token,
      user: user.toPublicJson(),
      refreshToken: refreshToken,
    );
  }

  /// Authenticates a user login and returns authentication response.
  Future<AuthResponse> login(LoginRequest request) async {
    final db = _databaseService;

    final user = db.getUserByEmail(request.email);
    if (user == null) {
      throw Exception('Invalid email or password');
    }

    if (!verifyPassword(request.password, user.passwordHash)) {
      throw Exception('Invalid email or password');
    }

    final token = generateToken(user.id);
    final refreshToken = generateRefreshToken();

    db.storeRefreshToken(
      _uuid.v8(),
      user.id,
      refreshToken,
      DateTime.now().add(EnvConfig.jwtRefreshTokenExpiresIn),
    );

    return AuthResponse(
      token: token,
      user: user.toPublicJson(),
      refreshToken: refreshToken,
    );
  }

  /// Gets the current user from a JWT token.
  User? getCurrentUser(String? token) {
    if (token == null) return null;

    final userId = verifyToken(token);
    if (userId == null) return null;

    return _databaseService.getUserById(userId);
  }

  /// Refreshes an access token using a refresh token.
  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    final db = _databaseService;

    final refreshTokenData = db.getRefreshToken(request.refreshToken);
    if (refreshTokenData == null) {
      throw Exception('Invalid or expired refresh token');
    }

    final userId = refreshTokenData['user_id'] as String;
    final user = db.getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    db.deleteRefreshToken(request.refreshToken);

    final newToken = generateToken(userId);
    final newRefreshToken = generateRefreshToken();

    db.storeRefreshToken(
      _uuid.v8(),
      userId,
      newRefreshToken,
      DateTime.now().add(EnvConfig.jwtRefreshTokenExpiresIn),
    );

    return AuthResponse(
      token: newToken,
      user: user.toPublicJson(),
      refreshToken: newRefreshToken,
    );
  }

  /// Updates user password.
  Future<void> updatePassword(
    String userId,
    UpdatePasswordRequest request,
  ) async {
    final db = _databaseService;

    final user = db.getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    if (!verifyPassword(request.currentPassword, user.passwordHash)) {
      throw Exception('Current password is incorrect');
    }

    final newPasswordHash = hashPassword(request.newPassword);
    db
      ..updateUserPassword(userId, newPasswordHash)
      ..deleteAllRefreshTokensForUser(userId);
  }

  /// Initiates forgot password process.
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    final db = _databaseService;

    final user = db.getUserByEmail(request.email);
    if (user == null) {
      return;
    }

    final resetToken = _uuid.v8();
    db.storePasswordResetToken(
      _uuid.v8(),
      user.id,
      resetToken,
      DateTime.now().add(EnvConfig.passwordResetTokenExpiresIn),
    );

    log('Password reset token for ${request.email}: $resetToken');
  }

  /// Resets password using reset token.
  Future<void> resetPassword(ResetPasswordRequest request) async {
    final db = _databaseService;

    final resetTokenData = db.getPasswordResetToken(request.token);
    if (resetTokenData == null) {
      throw Exception('Invalid or expired reset token');
    }

    final userId = resetTokenData['user_id'] as String;
    final newPasswordHash = hashPassword(request.newPassword);

    db
      ..updateUserPassword(userId, newPasswordHash)
      ..markPasswordResetTokenAsUsed(request.token)
      ..deleteAllRefreshTokensForUser(userId);
  }
}
