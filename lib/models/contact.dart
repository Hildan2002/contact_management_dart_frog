import 'package:equatable/equatable.dart';

/// Represents a contact in the system.
class Contact extends Equatable {
  /// Creates a new Contact instance.
  const Contact({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.company,
    this.address,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a Contact from a JSON map.
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// The unique identifier for the contact.
  final String id;

  /// The ID of the user who owns this contact.
  final String userId;

  /// The contact's first name.
  final String firstName;

  /// The contact's last name.
  final String lastName;

  /// The contact's email address.
  final String email;

  /// The contact's phone number (optional).
  final String? phone;

  /// The contact's company (optional).
  final String? company;

  /// The contact's address (optional).
  final String? address;

  /// Notes about the contact (optional).
  final String? notes;

  /// When the contact was created.
  final DateTime? createdAt;

  /// When the contact was last updated.
  final DateTime? updatedAt;

  /// Gets the full name by combining first and last name.
  String get fullName => '$firstName $lastName';

  /// Creates a copy of this contact with the given fields replaced.
  Contact copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? company,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts the Contact to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'company': company,
      'address': address,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Properties used for equality comparison.
  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        email,
        phone,
        company,
        address,
        notes,
        createdAt,
        updatedAt,
      ];
}
