import 'package:my_project/models/user.dart';
import 'package:test/test.dart';

void main() {
  group('User', () {
    const id = 'test-id';
    const email = 'test@example.com';
    const passwordHash = 'hashed-password';
    const name = 'Test User';
    final createdAt = DateTime.parse('2023-01-01T00:00:00.000Z');
    final updatedAt = DateTime.parse('2023-01-02T00:00:00.000Z');

    const userJson = {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'name': name,
      'created_at': '2023-01-01T00:00:00.000Z',
      'updated_at': '2023-01-02T00:00:00.000Z',
    };

    group('constructor', () {
      test('should create user with all properties', () {
        final user = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(user.id, equals(id));
        expect(user.email, equals(email));
        expect(user.passwordHash, equals(passwordHash));
        expect(user.name, equals(name));
        expect(user.createdAt, equals(createdAt));
        expect(user.updatedAt, equals(updatedAt));
      });

      test('should create user with null timestamps', () {
        const user = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
        );

        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
      });
    });

    group('fromJson', () {
      test('should create user from JSON with all fields', () {
        final user = User.fromJson(userJson);

        expect(user.id, equals(id));
        expect(user.email, equals(email));
        expect(user.passwordHash, equals(passwordHash));
        expect(user.name, equals(name));
        expect(user.createdAt, equals(createdAt));
        expect(user.updatedAt, equals(updatedAt));
      });

      test('should create user from JSON with null timestamps', () {
        final jsonWithoutTimestamps = {
          'id': id,
          'email': email,
          'password_hash': passwordHash,
          'name': name,
          'created_at': null,
          'updated_at': null,
        };

        final user = User.fromJson(jsonWithoutTimestamps);

        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
      });

      test('should create user from JSON without timestamp fields', () {
        final jsonWithoutTimestamps = {
          'id': id,
          'email': email,
          'password_hash': passwordHash,
          'name': name,
        };

        final user = User.fromJson(jsonWithoutTimestamps);

        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        const originalUser = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
        );

        const newEmail = 'new@example.com';
        const newName = 'New Name';

        final updatedUser = originalUser.copyWith(
          email: newEmail,
          name: newName,
          updatedAt: updatedAt,
        );

        expect(updatedUser.id, equals(id));
        expect(updatedUser.email, equals(newEmail));
        expect(updatedUser.passwordHash, equals(passwordHash));
        expect(updatedUser.name, equals(newName));
        expect(updatedUser.createdAt, isNull);
        expect(updatedUser.updatedAt, equals(updatedAt));
      });

      test('should create copy with no changes when no parameters provided',
          () {
        final originalUser = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final copiedUser = originalUser.copyWith();

        expect(copiedUser, equals(originalUser));
      });
    });

    group('toJson', () {
      test('should convert user to JSON with all fields', () {
        final user = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = user.toJson();

        expect(json, equals(userJson));
      });

      test('should convert user to JSON with null timestamps', () {
        const user = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
        );

        final json = user.toJson();

        expect(json['id'], equals(id));
        expect(json['email'], equals(email));
        expect(json['password_hash'], equals(passwordHash));
        expect(json['name'], equals(name));
        expect(json['created_at'], isNull);
        expect(json['updated_at'], isNull);
      });
    });

    group('toPublicJson', () {
      test('should convert user to public JSON excluding password hash', () {
        final user = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final publicJson = user.toPublicJson();

        expect(publicJson['id'], equals(id));
        expect(publicJson['email'], equals(email));
        expect(publicJson['name'], equals(name));
        expect(publicJson['created_at'], equals('2023-01-01T00:00:00.000Z'));
        expect(publicJson['updated_at'], equals('2023-01-02T00:00:00.000Z'));
        expect(publicJson, isNot(contains('password_hash')));
      });

      test('should convert user to public JSON with null timestamps', () {
        const user = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
        );

        final publicJson = user.toPublicJson();

        expect(publicJson['created_at'], isNull);
        expect(publicJson['updated_at'], isNull);
        expect(publicJson, isNot(contains('password_hash')));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        final user1 = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final user2 = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final user1 = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final user2 = User(
          id: 'different-id',
          email: email,
          passwordHash: passwordHash,
          name: name,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when timestamps differ', () {
        final user1 = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
          createdAt: createdAt,
        );

        final user2 = User(
          id: id,
          email: email,
          passwordHash: passwordHash,
          name: name,
          createdAt: updatedAt,
        );

        expect(user1, isNot(equals(user2)));
      });
    });
  });
}
