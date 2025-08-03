import 'package:equatable/equatable.dart';

/// Represents a user in the system.
class User extends Equatable {
  /// Creates a new User instance.
  const User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a User from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// The unique identifier for the user.
  final String id;

  /// The user's email address.
  final String email;

  /// The hashed password.
  final String passwordHash;

  /// The user's display name.
  final String name;

  /// When the user was created.
  final DateTime? createdAt;

  /// When the user was last updated.
  final DateTime? updatedAt;

  /// Creates a copy of this user with the given fields replaced.
  User copyWith({
    String? id,
    String? email,
    String? passwordHash,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts the User to a JSON map (including password hash).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Converts the user to JSON without the password hash.
  Map<String, dynamic> toPublicJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Properties used for equality comparison.
  @override
  List<Object?> get props =>
      [id, email, passwordHash, name, createdAt, updatedAt];
}
