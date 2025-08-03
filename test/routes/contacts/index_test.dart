import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_project/models/contact.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/database_service.dart';
import 'package:test/test.dart';

import '../../../routes/contacts/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

class _MockUri extends Mock implements Uri {}

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

  group('Contacts Routes', () {
    const testUser = User(
      id: 'test-user-id',
      email: 'test@example.com',
      passwordHash: 'hashed-password',
      name: 'Test User',
    );

    final testContact = Contact(
      id: 'contact-1',
      userId: testUser.id,
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      phone: '+1234567890',
      company: 'Example Corp',
      address: '123 Main St',
      notes: 'Important client',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    group('GET /contacts', () {
      test('should return all contacts for authenticated user', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final uri = _MockUri();

        // Create test contact
        databaseService.createContact(testContact);

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.get);
        when(() => request.uri).thenReturn(uri);
        when(() => uri.queryParameters).thenReturn(<String, String>{});

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(200));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData, containsPair('contacts', isA<List<dynamic>>()));
        expect(responseData, containsPair('total', 1));

        final contacts = responseData['contacts'] as List<dynamic>;
        expect(contacts, hasLength(1));
        final firstContact = contacts.first as Map<String, dynamic>;
        expect(firstContact['id'], equals('contact-1'));
        expect(firstContact['first_name'], equals('John'));
        expect(firstContact['last_name'], equals('Doe'));
      });

      test('should return empty list when user has no contacts', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final uri = _MockUri();

        const differentUser = User(
          id: 'different-user-id',
          email: 'different@example.com',
          passwordHash: 'hashed-password',
          name: 'Different User',
        );

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(differentUser);
        when(() => request.method).thenReturn(HttpMethod.get);
        when(() => request.uri).thenReturn(uri);
        when(() => uri.queryParameters).thenReturn(<String, String>{});

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(200));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData, containsPair('contacts', isA<List<dynamic>>()));
        expect(responseData, containsPair('total', 0));

        final contacts = responseData['contacts'] as List<dynamic>;
        expect(contacts, isEmpty);
      });

      test('should handle pagination with limit and offset', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final uri = _MockUri();

        // Create multiple contacts
        for (var i = 2; i <= 5; i++) {
          final contact = testContact.copyWith(
            id: 'contact-$i',
            firstName: 'Contact$i',
          );
          databaseService.createContact(contact);
        }

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.get);
        when(() => request.uri).thenReturn(uri);
        when(() => uri.queryParameters).thenReturn({
          'limit': '2',
          'offset': '1',
        });

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(200));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        final contacts = responseData['contacts'] as List<dynamic>;
        expect(contacts, hasLength(2));
      });

      test('should handle search query', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final uri = _MockUri();

        // Create additional test contacts
        final searchableContact = testContact.copyWith(
          id: 'searchable-contact',
          firstName: 'Searchable',
          lastName: 'User',
        );
        databaseService.createContact(searchableContact);

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.get);
        when(() => request.uri).thenReturn(uri);
        when(() => uri.queryParameters).thenReturn({
          'q': 'searchable',
        });

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(200));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        final contacts = responseData['contacts'] as List<dynamic>;
        expect(contacts, hasLength(1));
        final firstContact = contacts.first as Map<String, dynamic>;
        expect(firstContact['first_name'], equals('Searchable'));
      });

      test('should return 400 for invalid limit parameter', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final uri = _MockUri();

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.get);
        when(() => request.uri).thenReturn(uri);
        when(() => uri.queryParameters).thenReturn({
          'limit': 'invalid',
        });

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(400));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['error'], equals('Invalid limit parameter'));
      });

      test('should return 400 for invalid offset parameter', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final uri = _MockUri();

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.get);
        when(() => request.uri).thenReturn(uri);
        when(() => uri.queryParameters).thenReturn({
          'offset': '-1',
        });

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(400));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['error'], equals('Invalid offset parameter'));
      });
    });

    group('POST /contacts', () {
      test('should create contact with valid data', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        final contactData = {
          'first_name': 'Jane',
          'last_name': 'Smith',
          'email': 'jane.smith@example.com',
          'phone': '+0987654321',
          'company': 'New Corp',
          'address': '456 Oak St',
          'notes': 'New client',
        };

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.post);
        when(request.body).thenAnswer((_) async => jsonEncode(contactData));

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(201));

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
        expect(contact['user_id'], equals(testUser.id));
      });

      test('should create contact with minimal required data', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        final contactData = {
          'first_name': 'Min',
          'last_name': 'User',
          'email': 'min.user@example.com',
        };

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.post);
        when(request.body).thenAnswer((_) async => jsonEncode(contactData));

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(201));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        final contact = responseData['contact'] as Map<String, dynamic>;
        expect(contact['first_name'], equals('Min'));
        expect(contact['phone'], isNull);
        expect(contact['company'], isNull);
        expect(contact['address'], isNull);
        expect(contact['notes'], isNull);
      });

      test('should return 400 for missing required fields', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        final incompleteData = {
          'first_name': 'Incomplete',
          // Missing last_name and email
        };

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.post);
        when(request.body).thenAnswer((_) async => jsonEncode(incompleteData));

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(400));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData, containsPair('error', isA<String>()));
      });

      test('should return 400 for invalid email format', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        final invalidData = {
          'first_name': 'Invalid',
          'last_name': 'Email',
          'email': 'invalid-email',
        };

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.post);
        when(request.body).thenAnswer((_) async => jsonEncode(invalidData));

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(400));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['error'], contains('Invalid email format'));
      });

      test('should return 400 for short names', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        final invalidData = {
          'first_name': 'J',
          'last_name': 'Doe',
          'email': 'j.doe@example.com',
        };

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.post);
        when(request.body).thenAnswer((_) async => jsonEncode(invalidData));

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(400));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['error'], contains('at least 2 characters'));
      });
    });

    group('Method not allowed', () {
      test('should return 405 for unsupported methods', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();

        when(() => context.request).thenReturn(request);
        when(() => context.read<User>()).thenReturn(testUser);
        when(() => request.method).thenReturn(HttpMethod.put);

        final response = await route.onRequest(context);

        expect(response.statusCode, equals(405));

        final responseBody = await response.body();
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

        expect(responseData['error'], equals('Method not allowed'));
      });
    });
  });
}
