import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_project/models/contact.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/database_service.dart';
import 'package:test/test.dart';

import '../../../routes/contacts/[id].dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  late DatabaseService databaseService;
  late AuthService authService;

  setUpAll(() async {
    databaseService = DatabaseService();
    await databaseService.initialize(path: ':memory:');
    authService = AuthService(databaseService);
    
    // Setup GetIt for testing
    GetIt.instance.registerSingleton<DatabaseService>(databaseService);
    GetIt.instance.registerSingleton<AuthService>(authService);
  });

  tearDownAll(() {
    databaseService.close();
    GetIt.instance.reset();
  });

  group('Contact [id] Routes', () {
    const testUser = User(
      id: 'test-user-id',
      email: 'test@example.com',
      passwordHash: 'hashed-password',
      name: 'Test User',
    );

    const contactId = 'test-contact-id';

    final testContact = Contact(
      id: contactId,
      userId: testUser.id,
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      phone: '+1234567890',
      company: 'Example Corp',
      address: '123 Main St',
      notes: 'Important client',
      createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
    );

    setUp(() {
      // Clean up any existing contacts
      try {
        databaseService.deleteContact(contactId, testUser.id);
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    group('GET /contacts/:id', () {
      test('should return contact by ID for authenticated user', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        // Create test contact
        databaseService.createContact(testContact);

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.get);

        final response = await route.onRequest(context, contactId);

        expect(response.statusCode, equals(200));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(
          responseData,
          containsPair('contact', isA<Map<String, dynamic>>()),
        );
        final contact = responseData['contact'] as Map<String, dynamic>;
        expect(contact['id'], equals(contactId));
        expect(contact['first_name'], equals('John'));
        expect(contact['last_name'], equals('Doe'));
        expect(contact['email'], equals('john.doe@example.com'));
        expect(contact['user_id'], equals(testUser.id));
      });

      test('should return 404 for non-existent contact', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.get);

        final response = await route.onRequest(context, 'non-existent-id');

        expect(response.statusCode, equals(404));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['error'], equals('Contact not found'));
      });

      test('should return 404 when contact belongs to different user',
          () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        // Create contact for the test user
        databaseService.createContact(testContact);

        // Try to access with different user
        const differentUser = User(
          id: 'different-user-id',
          email: 'different@example.com',
          passwordHash: 'hashed-password',
          name: 'Different User',
        );

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(differentUser);
        when(() => request.method).thenReturn(HttpMethod.get);

        final response = await route.onRequest(context, contactId);

        expect(response.statusCode, equals(404));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['error'], equals('Contact not found'));
      });
    });

    group('PUT /contacts/:id', () {
      test('should update contact with valid data', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        // Create test contact
        databaseService.createContact(testContact);

        final updateData = {
          'first_name': 'Jane',
          'last_name': 'Smith',
          'email': 'jane.smith@example.com',
          'phone': '+0987654321',
          'company': 'Updated Corp',
          'address': '456 Oak St',
          'notes': 'Updated notes',
        };

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.put);
        when(request.body).thenAnswer((_) async => jsonEncode(updateData));

        final response = await route.onRequest(context, contactId);

        expect(response.statusCode, equals(200));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(
          responseData,
          containsPair('contact', isA<Map<String, dynamic>>()),
        );
        final contact = responseData['contact'] as Map<String, dynamic>;
        expect(contact['first_name'], equals('Jane'));
        expect(contact['last_name'], equals('Smith'));
        expect(contact['email'], equals('jane.smith@example.com'));
        expect(contact['phone'], equals('+0987654321'));
        expect(contact['company'], equals('Updated Corp'));
        expect(contact['address'], equals('456 Oak St'));
        expect(contact['notes'], equals('Updated notes'));
        expect(contact['updated_at'], isNot(equals(contact['created_at'])));
      });

      test('should return 404 for non-existent contact', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        final updateData = {
          'first_name': 'Jane',
          'last_name': 'Smith',
          'email': 'jane.smith@example.com',
        };

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.put);
        when(request.body).thenAnswer((_) async => jsonEncode(updateData));

        final response = await route.onRequest(context, 'non-existent-id');

        expect(response.statusCode, equals(404));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['error'], equals('Contact not found'));
      });

      test('should return 400 for invalid email format', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        // Create test contact
        databaseService.createContact(testContact);

        final invalidData = {
          'first_name': 'Jane',
          'last_name': 'Smith',
          'email': 'invalid-email',
        };

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.put);
        when(request.body).thenAnswer((_) async => jsonEncode(invalidData));

        final response = await route.onRequest(context, contactId);

        expect(response.statusCode, equals(400));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['error'], contains('Invalid email format'));
      });

      test('should return 400 for missing required fields', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        // Create test contact
        databaseService.createContact(testContact);

        final incompleteData = {
          'first_name': 'Jane',
          // Missing last_name and email
        };

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.put);
        when(request.body).thenAnswer((_) async => jsonEncode(incompleteData));

        final response = await route.onRequest(context, contactId);

        expect(response.statusCode, equals(400));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData, containsPair('error', isA<String>()));
      });

      test('should return 400 for short names', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        // Create test contact
        databaseService.createContact(testContact);

        final invalidData = {
          'first_name': 'J',
          'last_name': 'Smith',
          'email': 'j.smith@example.com',
        };

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.put);
        when(request.body).thenAnswer((_) async => jsonEncode(invalidData));

        final response = await route.onRequest(context, contactId);

        expect(response.statusCode, equals(400));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['error'], contains('at least 2 characters'));
      });
    });

    group('DELETE /contacts/:id', () {
      test('should delete contact successfully', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        // Create test contact
        databaseService.createContact(testContact);

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.delete);

        final response = await route.onRequest(context, contactId);

        expect(response.statusCode, equals(200));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['message'], equals('Contact deleted successfully'));

        // Verify contact is actually deleted
        final deletedContact =
            databaseService.getContactById(contactId, testUser.id);
        expect(deletedContact, isNull);
      });

      test('should handle deletion of non-existent contact', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.delete);

        final response = await route.onRequest(context, 'non-existent-id');

        // Note: Based on the current implementation, deleteContact returns
        // true even for non-existent contacts. This might be a behavior to
        // consider changing.
        expect(response.statusCode, equals(200));
      });

      test('should not delete contact belonging to different user', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        // Create contact for test user
        databaseService.createContact(testContact);

        // Try to delete with different user
        const differentUser = User(
          id: 'different-user-id',
          email: 'different@example.com',
          passwordHash: 'hashed-password',
          name: 'Different User',
        );

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(differentUser);
        when(() => request.method).thenReturn(HttpMethod.delete);

        final response = await route.onRequest(context, contactId);

        // Contact should still exist for the original user
        final stillExists =
            databaseService.getContactById(contactId, testUser.id);
        expect(stillExists, isNotNull);

        // Response should indicate success (due to current implementation)
        expect(response.statusCode, equals(200));
      });
    });

    group('Method not allowed', () {
      test('should return 405 for unsupported methods', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.post);

        final response = await route.onRequest(context, contactId);

        expect(response.statusCode, equals(405));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['error'], equals('Method not allowed'));
      });
    });
  });
}
