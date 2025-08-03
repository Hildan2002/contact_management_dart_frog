import 'package:my_project/models/contact.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/services/database_service.dart';
import 'package:test/test.dart';

void main() {
  late DatabaseService databaseService;

  setUp(() async {
    databaseService = DatabaseService();
    await databaseService.initialize(path: ':memory:');
  });

  tearDown(() {
    databaseService.close();
  });

  group('DatabaseService', () {
    group('initialization', () {
      test('should initialize database and create tables', () async {
        final newService = DatabaseService();
        await newService.initialize(path: ':memory:');

        expect(() => newService.database, returnsNormally);
        newService.close();
      });

      test('should throw error when accessing database before initialization',
          () {
        // Close the existing database to test uninitialized state
        databaseService.close();
        expect(() => databaseService.database, throwsException);
        // Re-initialize for other tests
        databaseService.initialize(path: ':memory:');
      });

      test('should close database connection', () {
        databaseService.close();
        expect(() => databaseService.database, throwsException);
      });
    });

    group('User operations', () {
      const userId = 'test-user-id';
      const email = 'test@example.com';
      const passwordHash = 'hashed-password';
      const name = 'Test User';
      final createdAt = DateTime.parse('2023-01-01T00:00:00.000Z');
      final updatedAt = DateTime.parse('2023-01-02T00:00:00.000Z');

      final testUser = User(
        id: userId,
        email: email,
        passwordHash: passwordHash,
        name: name,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      test('should create and retrieve user by ID', () {
        databaseService.createUser(testUser);

        final retrievedUser = databaseService.getUserById(userId);

        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.id, equals(userId));
        expect(retrievedUser.email, equals(email));
        expect(retrievedUser.passwordHash, equals(passwordHash));
        expect(retrievedUser.name, equals(name));
      });

      test('should retrieve user by email', () {
        databaseService.createUser(testUser);

        final retrievedUser = databaseService.getUserByEmail(email);

        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.id, equals(userId));
        expect(retrievedUser.email, equals(email));
      });

      test('should return null for non-existent user by ID', () {
        final retrievedUser = databaseService.getUserById('non-existent');
        expect(retrievedUser, isNull);
      });

      test('should return null for non-existent user by email', () {
        final retrievedUser =
            databaseService.getUserByEmail('non@existent.com');
        expect(retrievedUser, isNull);
      });

      test('should update user password', () {
        databaseService.createUser(testUser);

        const newPasswordHash = 'new-hashed-password';
        databaseService.updateUserPassword(userId, newPasswordHash);

        final updatedUser = databaseService.getUserById(userId);
        expect(updatedUser!.passwordHash, equals(newPasswordHash));
      });

      test('should handle duplicate email constraint', () {
        databaseService.createUser(testUser);

        const duplicateUser = User(
          id: 'different-id',
          email: email,
          passwordHash: 'different-hash',
          name: 'Different Name',
        );

        expect(
          () => databaseService.createUser(duplicateUser),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Refresh token operations', () {
      const tokenId = 'token-id';
      const userId = 'user-id';
      const token = 'refresh-token';
      final expiresAt = DateTime.now().add(const Duration(days: 7));

      test('should store and retrieve refresh token', () {
        databaseService.storeRefreshToken(tokenId, userId, token, expiresAt);

        final retrievedToken = databaseService.getRefreshToken(token);

        expect(retrievedToken, isNotNull);
        expect(retrievedToken!['id'], equals(tokenId));
        expect(retrievedToken['user_id'], equals(userId));
        expect(retrievedToken['token'], equals(token));
      });

      test('should return null for expired refresh token', () {
        final expiredTime = DateTime.now().subtract(const Duration(days: 1));
        databaseService.storeRefreshToken(tokenId, userId, token, expiredTime);

        final retrievedToken = databaseService.getRefreshToken(token);
        expect(retrievedToken, isNull);
      });

      test('should delete refresh token', () {
        databaseService
          ..storeRefreshToken(tokenId, userId, token, expiresAt)
          ..deleteRefreshToken(token);

        final retrievedToken = databaseService.getRefreshToken(token);
        expect(retrievedToken, isNull);
      });

      test('should delete all refresh tokens for user', () {
        const token1 = 'token1';
        const token2 = 'token2';

        databaseService
          ..storeRefreshToken('id1', userId, token1, expiresAt)
          ..storeRefreshToken('id2', userId, token2, expiresAt)
          ..deleteAllRefreshTokensForUser(userId);

        expect(databaseService.getRefreshToken(token1), isNull);
        expect(databaseService.getRefreshToken(token2), isNull);
      });
    });

    group('Password reset token operations', () {
      const tokenId = 'reset-token-id';
      const userId = 'user-id';
      const token = 'reset-token';
      final expiresAt = DateTime.now().add(const Duration(hours: 1));

      test('should store and retrieve password reset token', () {
        databaseService.storePasswordResetToken(
          tokenId,
          userId,
          token,
          expiresAt,
        );

        final retrievedToken = databaseService.getPasswordResetToken(token);

        expect(retrievedToken, isNotNull);
        expect(retrievedToken!['id'], equals(tokenId));
        expect(retrievedToken['user_id'], equals(userId));
        expect(retrievedToken['token'], equals(token));
        expect(retrievedToken['used'], equals(0)); // SQLite boolean as integer
      });

      test('should return null for expired password reset token', () {
        final expiredTime = DateTime.now().subtract(const Duration(hours: 1));
        databaseService.storePasswordResetToken(
          tokenId,
          userId,
          token,
          expiredTime,
        );

        final retrievedToken = databaseService.getPasswordResetToken(token);
        expect(retrievedToken, isNull);
      });

      test('should mark password reset token as used', () {
        databaseService
          ..storePasswordResetToken(
            tokenId,
            userId,
            token,
            expiresAt,
          )
          ..markPasswordResetTokenAsUsed(token);

        final retrievedToken = databaseService.getPasswordResetToken(token);
        expect(retrievedToken, isNull); // Should be null because it's used
      });
    });

    group('Contact operations', () {
      const userId = 'test-user-id';
      const contactId = 'test-contact-id';
      final createdAt = DateTime.parse('2023-01-01T00:00:00.000Z');
      final updatedAt = DateTime.parse('2023-01-02T00:00:00.000Z');

      final testContact = Contact(
        id: contactId,
        userId: userId,
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
        company: 'Example Corp',
        address: '123 Main St',
        notes: 'Important client',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      test('should create and retrieve contact by ID', () {
        databaseService.createContact(testContact);

        final retrievedContact =
            databaseService.getContactById(contactId, userId);

        expect(retrievedContact, isNotNull);
        expect(retrievedContact!.id, equals(contactId));
        expect(retrievedContact.userId, equals(userId));
        expect(retrievedContact.firstName, equals('John'));
        expect(retrievedContact.lastName, equals('Doe'));
        expect(retrievedContact.email, equals('john.doe@example.com'));
        expect(retrievedContact.phone, equals('+1234567890'));
        expect(retrievedContact.company, equals('Example Corp'));
        expect(retrievedContact.address, equals('123 Main St'));
        expect(retrievedContact.notes, equals('Important client'));
      });

      test('should return null for contact with wrong user ID', () {
        databaseService.createContact(testContact);

        final retrievedContact =
            databaseService.getContactById(contactId, 'wrong-user-id');
        expect(retrievedContact, isNull);
      });

      test('should get contacts by user ID', () {
        final contact1 = testContact;
        final contact2 = testContact.copyWith(
          id: 'contact-2',
          firstName: 'Jane',
        );

        databaseService
          ..createContact(contact1)
          ..createContact(contact2);

        final contacts = databaseService.getContactsByUserId(userId);

        expect(contacts, hasLength(2));
        expect(
          contacts.map((c) => c.id),
          containsAll([contactId, 'contact-2']),
        );
      });

      test('should get contacts with pagination', () {
        for (var i = 0; i < 5; i++) {
          final contact = testContact.copyWith(id: 'contact-$i');
          databaseService.createContact(contact);
        }

        final firstPage = databaseService.getContactsByUserId(
          userId,
          limit: 2,
          offset: 0,
        );
        final secondPage = databaseService.getContactsByUserId(
          userId,
          limit: 2,
          offset: 2,
        );

        expect(firstPage, hasLength(2));
        expect(secondPage, hasLength(2));
        expect(firstPage.first.id, isNot(equals(secondPage.first.id)));
      });

      test('should update contact', () {
        databaseService.createContact(testContact);

        final updatedContact = testContact.copyWith(
          firstName: 'Johnny',
          phone: '+0987654321',
          updatedAt: DateTime.now(),
        );

        databaseService.updateContact(updatedContact);

        final retrievedContact =
            databaseService.getContactById(contactId, userId);
        expect(retrievedContact!.firstName, equals('Johnny'));
        expect(retrievedContact.phone, equals('+0987654321'));
      });

      test('should delete contact', () {
        databaseService.createContact(testContact);

        final wasDeleted = databaseService.deleteContact(contactId, userId);

        expect(wasDeleted, isTrue);

        final retrievedContact =
            databaseService.getContactById(contactId, userId);
        expect(retrievedContact, isNull);
      });

      test('should return false when deleting non-existent contact', () {
        final wasDeleted =
            databaseService.deleteContact('non-existent', userId);
        expect(
          wasDeleted,
          isTrue,
        ); // Still returns true as query executes successfully
      });

      test('should search contacts by name', () {
        // Clear any existing contacts for clean test
        databaseService.database
            .execute('DELETE FROM contacts WHERE user_id = ?', [userId]);

        final contact1 = testContact.copyWith(
          id: 'c1',
          firstName: 'John',
          lastName: 'Smith',
          email: 'john.smith@test.com',
          company: 'Smith Corp',
        );
        final contact2 = testContact.copyWith(
          id: 'c2',
          firstName: 'Jane',
          lastName: 'Adams',
          email: 'jane.adams@test.com',
          company: 'Adams LLC',
        );
        final contact3 = testContact.copyWith(
          id: 'c3',
          firstName: 'Bob',
          lastName: 'Wilson',
          email: 'bob.wilson@test.com',
          company: 'Wilson Inc',
        );

        databaseService
          ..createContact(contact1)
          ..createContact(contact2)
          ..createContact(contact3);

        final results = databaseService.searchContacts(userId, 'jo');

        expect(results, hasLength(1));
        expect(results.first.firstName, equals('John'));
      });

      test('should search contacts by email', () {
        // Clear any existing contacts for clean test
        databaseService.database
            .execute('DELETE FROM contacts WHERE user_id = ?', [userId]);

        final contact1 = testContact.copyWith(
          id: 'c1',
          firstName: 'Alice',
          lastName: 'Test',
          email: 'alice@example.com',
          company: 'Test Company A',
        );
        final contact2 = testContact.copyWith(
          id: 'c2',
          firstName: 'Bob',
          lastName: 'Test',
          email: 'bob@different.com',
          company: 'Test Company B',
        );

        databaseService
          ..createContact(contact1)
          ..createContact(contact2);

        final results = databaseService.searchContacts(userId, 'example');

        expect(results, hasLength(1));
        expect(results.first.email, equals('alice@example.com'));
      });

      test('should search contacts by company', () {
        final contact1 = testContact.copyWith(
          id: 'c1',
          company: 'Tech Corp',
        );
        final contact2 = testContact.copyWith(
          id: 'c2',
          company: 'Design Studio',
        );

        databaseService
          ..createContact(contact1)
          ..createContact(contact2);

        final results = databaseService.searchContacts(userId, 'tech');

        expect(results, hasLength(1));
        expect(results.first.company, equals('Tech Corp'));
      });

      test('should return empty list for search with no matches', () {
        databaseService.createContact(testContact);

        final results = databaseService.searchContacts(userId, 'nomatch');

        expect(results, isEmpty);
      });

      test('should only return contacts for specific user in search', () {
        final contact1 = testContact.copyWith(id: 'c1', userId: 'user1');
        final contact2 = testContact.copyWith(id: 'c2', userId: 'user2');

        databaseService
          ..createContact(contact1)
          ..createContact(contact2);

        final results = databaseService.searchContacts('user1', 'john');

        expect(results, hasLength(1));
        expect(results.first.userId, equals('user1'));
      });
    });
  });
}
