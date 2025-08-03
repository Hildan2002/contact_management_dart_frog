import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/database_service.dart';
import 'package:test/test.dart';

import '../../../routes/auth/register.dart' as route;

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

  group('POST /auth/register', () {
    test('should register user with valid data', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      final userData = {
        'email': 'test@example.com',
        'password': 'password123',
        'name': 'Test User',
      };

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.body).thenAnswer((_) async => jsonEncode(userData));

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(201));

      final responseBody = await response.body();
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(responseData, containsPair('data', isA<Map<String, dynamic>>()));
      final data = responseData['data'] as Map<String, dynamic>;
      expect(data['email'], equals('test@example.com'));
      expect(data['name'], equals('Test User'));
    });

    test('should return 400 for invalid email', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      final userData = {
        'email': 'invalid-email',
        'password': 'password123',
        'name': 'Test User',
      };

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.body).thenAnswer((_) async => jsonEncode(userData));

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(400));

      final responseBody = await response.body();
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(responseData['error'], contains('Invalid email format'));
    });

    test('should return 400 for short password', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      final userData = {
        'email': 'test@example.com',
        'password': '123',
        'name': 'Test User',
      };

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.body).thenAnswer((_) async => jsonEncode(userData));

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(400));

      final responseBody = await response.body();
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(responseData['error'], contains('at least 6 characters'));
    });

    test('should return 400 for missing required fields', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      final userData = {
        'email': 'test@example.com',
        // Missing password and name
      };

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.body).thenAnswer((_) async => jsonEncode(userData));

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(400));
    });

    test('should return 405 for non-POST requests', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.get);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(405));

      final responseBody = await response.body();
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(responseData['error'], equals('Method not allowed'));
    });
  });
}
