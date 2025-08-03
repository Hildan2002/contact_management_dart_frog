import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_project/models/auth_request.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/database_service.dart';
import 'package:test/test.dart';

import '../../../routes/auth/login.dart' as route;

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

  group('POST /auth/login', () {
    test('should login user with valid credentials', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      // First, register a user using AuthService directly
      const registerRequest = RegisterRequest(
        email: 'login@example.com',
        password: 'password123',
        name: 'Login User',
      );
      await authService.register(registerRequest);

      // Now test login
      final loginData = {
        'email': 'login@example.com',
        'password': 'password123',
      };

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.body).thenAnswer((_) async => jsonEncode(loginData));

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(200));

      final responseBody = await response.body();
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(responseData, containsPair('data', isA<Map<String, dynamic>>()));
      final data = responseData['data'] as Map<String, dynamic>;
      expect(data, containsPair('token', isA<String>()));
      expect(data, containsPair('refresh_token', isA<String>()));
      expect(data['token'], isNotEmpty);
      expect(data['refresh_token'], isNotEmpty);
    });

    test('should return 401 for invalid email', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      final loginData = {
        'email': 'nonexistent@example.com',
        'password': 'password123',
      };

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.body).thenAnswer((_) async => jsonEncode(loginData));

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(401));

      final responseBody = await response.body();
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(responseData, containsPair('error', isA<String>()));
    });

    test('should return 401 for invalid password', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      // Register a user first
      const registerRequest = RegisterRequest(
        email: 'wrongpass@example.com',
        password: 'correctpassword',
        name: 'Test User',
      );
      await authService.register(registerRequest);

      final loginData = {
        'email': 'wrongpass@example.com',
        'password': 'wrongpassword',
      };

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.body).thenAnswer((_) async => jsonEncode(loginData));

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(401));

      final responseBody = await response.body();
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(responseData, containsPair('error', isA<String>()));
    });

    test('should return 400 for invalid email format', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      final loginData = {
        'email': 'invalid-email',
        'password': 'password123',
      };

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.body).thenAnswer((_) async => jsonEncode(loginData));

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(400));

      final responseBody = await response.body();
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(responseData['error'], contains('Invalid email format'));
    });

    test('should return 400 for missing email', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      final loginData = {
        'password': 'password123',
      };

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.body).thenAnswer((_) async => jsonEncode(loginData));

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(400));

      final responseBody = await response.body();
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(responseData['error'], contains('Email is required'));
    });

    test('should return 400 for missing password', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      final loginData = {
        'email': 'test@example.com',
      };

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.body).thenAnswer((_) async => jsonEncode(loginData));

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(400));

      final responseBody = await response.body();
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(responseData['error'], contains('Password is required'));
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

    test('should return 400 for malformed JSON', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();

      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.body).thenAnswer((_) async => 'invalid json');

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(401));
    });
  });
}
