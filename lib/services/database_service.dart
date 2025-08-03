import 'package:my_project/models/contact.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/utils/env_config.dart';
import 'package:sqlite3/sqlite3.dart';

/// Service class for handling SQLite database operations.
class DatabaseService {
  /// Factory constructor that returns the singleton instance.
  factory DatabaseService() => _instance ??= DatabaseService._();

  /// Private constructor for singleton pattern.
  DatabaseService._();

  static DatabaseService? _instance;

  Database? _database;

  /// Gets the database connection, throwing an error if not initialized.
  Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  /// Initializes the database connection and creates tables.
  Future<void> initialize({String? path}) async {
    final dbPath = path ?? EnvConfig.databasePath;
    _database = sqlite3.open(dbPath);
    await _createTables();
  }

  Future<void> _createTables() async {
    database
      ..execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          email TEXT UNIQUE NOT NULL,
          password_hash TEXT NOT NULL,
          name TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''')
      ..execute('''
        CREATE TABLE IF NOT EXISTS refresh_tokens (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          token TEXT UNIQUE NOT NULL,
          expires_at TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''')
      ..execute('''
        CREATE TABLE IF NOT EXISTS password_reset_tokens (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          token TEXT UNIQUE NOT NULL,
          expires_at TEXT NOT NULL,
          used BOOLEAN DEFAULT FALSE,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''')
      ..execute('''
        CREATE TABLE IF NOT EXISTS contacts (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          first_name TEXT NOT NULL,
          last_name TEXT NOT NULL,
          email TEXT NOT NULL,
          phone TEXT,
          company TEXT,
          address TEXT,
          notes TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_contacts_user_id ON contacts (user_id)
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_users_email ON users (email)
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens (user_id)
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens (token)
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user_id ON password_reset_tokens (user_id)
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_token ON password_reset_tokens (token)
      ''');
  }

  /// Closes the database connection.
  void close() {
    _database?.dispose();
    _database = null;
  }

  /// Retrieves a user by their ID.
  User? getUserById(String id) {
    final result = database.select(
      'SELECT * FROM users WHERE id = ?',
      [id],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return User.fromJson({
      'id': row['id'],
      'email': row['email'],
      'password_hash': row['password_hash'],
      'name': row['name'],
      'created_at': row['created_at'],
      'updated_at': row['updated_at'],
    });
  }

  /// Retrieves a user by their email address.
  User? getUserByEmail(String email) {
    final result = database.select(
      'SELECT * FROM users WHERE email = ?',
      [email],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return User.fromJson({
      'id': row['id'],
      'email': row['email'],
      'password_hash': row['password_hash'],
      'name': row['name'],
      'created_at': row['created_at'],
      'updated_at': row['updated_at'],
    });
  }

  /// Creates a new user in the database.
  void createUser(User user) {
    database.execute(
      '''
INSERT INTO users (id, email, password_hash, name, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?)''',
      [
        user.id,
        user.email,
        user.passwordHash,
        user.name,
        user.createdAt?.toIso8601String(),
        user.updatedAt?.toIso8601String(),
      ],
    );
  }

  /// Updates user password.
  void updateUserPassword(String userId, String newPasswordHash) {
    database.execute(
      'UPDATE users SET password_hash = ?, updated_at = ? WHERE id = ?',
      [newPasswordHash, DateTime.now().toIso8601String(), userId],
    );
  }

  /// Stores a refresh token in the database.
  void storeRefreshToken(
    String id,
    String userId,
    String token,
    DateTime expiresAt,
  ) {
    database.execute(
      '''
INSERT INTO refresh_tokens (id, user_id, token, expires_at, created_at)
         VALUES (?, ?, ?, ?, ?)''',
      [
        id,
        userId,
        token,
        expiresAt.toIso8601String(),
        DateTime.now().toIso8601String(),
      ],
    );
  }

  /// Retrieves a refresh token from the database.
  Map<String, dynamic>? getRefreshToken(String token) {
    final result = database.select(
      'SELECT * FROM refresh_tokens WHERE token = ? AND expires_at > ?',
      [token, DateTime.now().toIso8601String()],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return {
      'id': row['id'],
      'user_id': row['user_id'],
      'token': row['token'],
      'expires_at': row['expires_at'],
      'created_at': row['created_at'],
    };
  }

  /// Deletes a refresh token from the database.
  void deleteRefreshToken(String token) {
    database.execute(
      'DELETE FROM refresh_tokens WHERE token = ?',
      [token],
    );
  }

  /// Deletes all refresh tokens for a user.
  void deleteAllRefreshTokensForUser(String userId) {
    database.execute(
      'DELETE FROM refresh_tokens WHERE user_id = ?',
      [userId],
    );
  }

  /// Stores a password reset token in the database.
  void storePasswordResetToken(
    String id,
    String userId,
    String token,
    DateTime expiresAt,
  ) {
    database.execute(
      '''
INSERT INTO password_reset_tokens (id, user_id, token, expires_at, created_at)
         VALUES (?, ?, ?, ?, ?)''',
      [
        id,
        userId,
        token,
        expiresAt.toIso8601String(),
        DateTime.now().toIso8601String(),
      ],
    );
  }

  /// Retrieves a password reset token from the database.
  Map<String, dynamic>? getPasswordResetToken(String token) {
    final result = database.select(
      '''
SELECT * FROM password_reset_tokens 
         WHERE token = ? AND expires_at > ? AND used = FALSE''',
      [token, DateTime.now().toIso8601String()],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return {
      'id': row['id'],
      'user_id': row['user_id'],
      'token': row['token'],
      'expires_at': row['expires_at'],
      'used': row['used'],
      'created_at': row['created_at'],
    };
  }

  /// Marks a password reset token as used.
  void markPasswordResetTokenAsUsed(String token) {
    database.execute(
      'UPDATE password_reset_tokens SET used = TRUE WHERE token = ?',
      [token],
    );
  }

  /// Retrieves contacts for a specific user with optional pagination.
  List<Contact> getContactsByUserId(String userId, {int? limit, int? offset}) {
    var query =
        'SELECT * FROM contacts WHERE user_id = ? ORDER BY created_at DESC';
    final params = <Object>[userId];

    if (limit != null) {
      query += ' LIMIT ?';
      params.add(limit);

      if (offset != null) {
        query += ' OFFSET ?';
        params.add(offset);
      }
    }

    final result = database.select(query, params);

    return result
        .map(
          (row) => Contact.fromJson({
            'id': row['id'],
            'user_id': row['user_id'],
            'first_name': row['first_name'],
            'last_name': row['last_name'],
            'email': row['email'],
            'phone': row['phone'],
            'company': row['company'],
            'address': row['address'],
            'notes': row['notes'],
            'created_at': row['created_at'],
            'updated_at': row['updated_at'],
          }),
        )
        .toList();
  }

  /// Retrieves a specific contact by ID for a user.
  Contact? getContactById(String id, String userId) {
    final result = database.select(
      'SELECT * FROM contacts WHERE id = ? AND user_id = ?',
      [id, userId],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return Contact.fromJson({
      'id': row['id'],
      'user_id': row['user_id'],
      'first_name': row['first_name'],
      'last_name': row['last_name'],
      'email': row['email'],
      'phone': row['phone'],
      'company': row['company'],
      'address': row['address'],
      'notes': row['notes'],
      'created_at': row['created_at'],
      'updated_at': row['updated_at'],
    });
  }

  /// Creates a new contact in the database.
  void createContact(Contact contact) {
    database.execute(
      '''
INSERT INTO contacts (id, user_id, first_name, last_name, email, phone, company, address, notes, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        contact.id,
        contact.userId,
        contact.firstName,
        contact.lastName,
        contact.email,
        contact.phone,
        contact.company,
        contact.address,
        contact.notes,
        contact.createdAt?.toIso8601String(),
        contact.updatedAt?.toIso8601String(),
      ],
    );
  }

  /// Updates an existing contact in the database.
  void updateContact(Contact contact) {
    database.execute(
      '''
UPDATE contacts 
         SET first_name = ?, last_name = ?, email = ?, phone = ?, 
             company = ?, address = ?, notes = ?, updated_at = ?
         WHERE id = ? AND user_id = ?''',
      [
        contact.firstName,
        contact.lastName,
        contact.email,
        contact.phone,
        contact.company,
        contact.address,
        contact.notes,
        contact.updatedAt?.toIso8601String(),
        contact.id,
        contact.userId,
      ],
    );
  }

  /// Deletes a contact for a specific user.
  bool deleteContact(String id, String userId) {
    database.execute(
      'DELETE FROM contacts WHERE id = ? AND user_id = ?',
      [id, userId],
    );

    // Check if the contact was actually deleted by trying to find it
    final result = database.select(
      'SELECT id FROM contacts WHERE id = ? AND user_id = ?',
      [id, userId],
    );

    return result.isEmpty;
  }

  /// Searches contacts by name or email for a specific user.
  List<Contact> searchContacts(String userId, String query) {
    final searchQuery = '%${query.toLowerCase()}%';
    final result = database.select(
      '''
SELECT * FROM contacts 
         WHERE user_id = ? AND (
           LOWER(first_name) LIKE ? OR 
           LOWER(last_name) LIKE ? OR 
           LOWER(email) LIKE ? OR 
           LOWER(company) LIKE ?
         )
         ORDER BY first_name, last_name''',
      [userId, searchQuery, searchQuery, searchQuery, searchQuery],
    );

    return result
        .map(
          (row) => Contact.fromJson({
            'id': row['id'],
            'user_id': row['user_id'],
            'first_name': row['first_name'],
            'last_name': row['last_name'],
            'email': row['email'],
            'phone': row['phone'],
            'company': row['company'],
            'address': row['address'],
            'notes': row['notes'],
            'created_at': row['created_at'],
            'updated_at': row['updated_at'],
          }),
        )
        .toList();
  }
}
