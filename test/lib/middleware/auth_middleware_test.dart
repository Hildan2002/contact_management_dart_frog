import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_project/middleware/auth_middleware.dart';
import 'package:my_project/models/auth_request.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/database_service.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

class _MockHandler extends Mock {
  Future<Response> call(RequestContext context);
}

class _FakeRequestContext extends Fake implements RequestContext {}

void main() {
  late DatabaseService databaseService;
  late AuthService authService;

  setUpAll(() async {
    // Register fallback values for mocktail
    registerFallbackValue(_FakeRequestContext());

    databaseService = DatabaseService();
    await databaseService.initialize(path: ':memory:');
    authService = AuthService();
  });

  tearDownAll(() {
    databaseService.close();
  });

  group('AuthMiddleware', () {
    group('authMiddleware', () {
      test('should pass request to handler with valid token', () async {
        // Register a user and get a token
        const registerRequest = RegisterRequest(
          email: 'middleware@example.com',
          password: 'password123',
          name: 'Middleware User',
        );
        final authResponse = await authService.register(registerRequest);

        final context = _MockRequestContext();
        final request = _MockRequest();
        final handler = _MockHandler();

        when(() => context.request).thenReturn(request);
        when(() => request.headers).thenReturn({
          'authorization': 'Bearer ${authResponse.token}',
        });

        // Mock context.provide to return a new context
        final mockUpdatedContext = _MockRequestContext();
        when(() => context.provide<User>(any())).thenReturn(mockUpdatedContext);

        // Mock handler response
        final expectedResponse = Response.json(body: {'success': true});
        when(() => handler.call(mockUpdatedContext))
            .thenAnswer((_) async => expectedResponse);

        final middleware = authMiddleware();
        final wrappedHandler = middleware(handler.call);
        final response = await wrappedHandler(context);

        expect(response, equals(expectedResponse));
        verify(() => handler.call(mockUpdatedContext)).called(1);
        verify(() => context.provide<User>(any())).called(1);
      });

      test('should return 401 for missing authorization header', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final handler = _MockHandler();

        when(() => context.request).thenReturn(request);
        when(() => request.headers).thenReturn(<String, String>{});

        final middleware = authMiddleware();
        final wrappedHandler = middleware(handler.call);
        final response = await wrappedHandler(context);

        expect(response.statusCode, equals(401));

        final responseBody = await response.body();
        expect(responseBody, contains('Authorization token required'));

        verifyNever(() => handler.call(any()));
      });

      test('should return 401 for authorization header without Bearer prefix',
          () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final handler = _MockHandler();

        when(() => context.request).thenReturn(request);
        when(() => request.headers).thenReturn({
          'authorization': 'Basic some-basic-auth',
        });

        final middleware = authMiddleware();
        final wrappedHandler = middleware(handler.call);
        final response = await wrappedHandler(context);

        expect(response.statusCode, equals(401));

        final responseBody = await response.body();
        expect(responseBody, contains('Authorization token required'));

        verifyNever(() => handler.call(any()));
      });

      test('should return 401 for invalid token', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final handler = _MockHandler();

        when(() => context.request).thenReturn(request);
        when(() => request.headers).thenReturn({
          'authorization': 'Bearer invalid-token',
        });

        final middleware = authMiddleware();
        final wrappedHandler = middleware(handler.call);
        final response = await wrappedHandler(context);

        expect(response.statusCode, equals(401));

        final responseBody = await response.body();
        expect(responseBody, contains('Invalid or expired token'));

        verifyNever(() => handler.call(any()));
      });

      test('should return 401 for empty Bearer token', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final handler = _MockHandler();

        when(() => context.request).thenReturn(request);
        when(() => request.headers).thenReturn({
          'authorization': 'Bearer ',
        });

        final middleware = authMiddleware();
        final wrappedHandler = middleware(handler.call);
        final response = await wrappedHandler(context);

        expect(response.statusCode, equals(401));

        final responseBody = await response.body();
        expect(responseBody, contains('Invalid or expired token'));

        verifyNever(() => handler.call(any()));
      });

      test('should return 401 for Bearer token with only spaces', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final handler = _MockHandler();

        when(() => context.request).thenReturn(request);
        when(() => request.headers).thenReturn({
          'authorization': 'Bearer   ',
        });

        final middleware = authMiddleware();
        final wrappedHandler = middleware(handler.call);
        final response = await wrappedHandler(context);

        expect(response.statusCode, equals(401));

        final responseBody = await response.body();
        expect(responseBody, contains('Invalid or expired token'));

        verifyNever(() => handler.call(any()));
      });
    });

    group('optionalAuthMiddleware', () {
      test('should pass request to handler with user when valid token provided',
          () async {
        // Register a user and get a token
        const registerRequest = RegisterRequest(
          email: 'optional@example.com',
          password: 'password123',
          name: 'Optional User',
        );
        final authResponse = await authService.register(registerRequest);

        final context = _MockRequestContext();
        final request = _MockRequest();
        final handler = _MockHandler();

        when(() => context.request).thenReturn(request);
        when(() => request.headers).thenReturn({
          'authorization': 'Bearer ${authResponse.token}',
        });

        // Mock context.provide to return a new context
        final mockUpdatedContext = _MockRequestContext();
        when(() => context.provide<User?>(any()))
            .thenReturn(mockUpdatedContext);

        // Mock handler response
        final expectedResponse = Response.json(body: {'success': true});
        when(() => handler.call(mockUpdatedContext))
            .thenAnswer((_) async => expectedResponse);

        final middleware = optionalAuthMiddleware();
        final wrappedHandler = middleware(handler.call);
        final response = await wrappedHandler(context);

        expect(response, equals(expectedResponse));
        verify(() => handler.call(mockUpdatedContext)).called(1);
        verify(() => context.provide<User?>(any())).called(1);
      });

      test(
          'should pass request to handler with null user when no token '
          'provided', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final handler = _MockHandler();

        when(() => context.request).thenReturn(request);
        when(() => request.headers).thenReturn(<String, String>{});

        // Mock context.provide to return a new context
        final mockUpdatedContext = _MockRequestContext();
        when(() => context.provide<User?>(any()))
            .thenReturn(mockUpdatedContext);

        // Mock handler response
        final expectedResponse = Response.json(body: {'success': true});
        when(() => handler.call(mockUpdatedContext))
            .thenAnswer((_) async => expectedResponse);

        final middleware = optionalAuthMiddleware();
        final wrappedHandler = middleware(handler.call);
        final response = await wrappedHandler(context);

        expect(response, equals(expectedResponse));
        verify(() => handler.call(mockUpdatedContext)).called(1);
        verify(() => context.provide<User?>(any())).called(1);
      });

      test(
          'should pass request to handler with null user when invalid '
          'token provided', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final handler = _MockHandler();

        when(() => context.request).thenReturn(request);
        when(() => request.headers).thenReturn({
          'authorization': 'Bearer invalid-token',
        });

        // Mock context.provide to return a new context
        final mockUpdatedContext = _MockRequestContext();
        when(() => context.provide<User?>(any()))
            .thenReturn(mockUpdatedContext);

        // Mock handler response
        final expectedResponse = Response.json(body: {'success': true});
        when(() => handler.call(mockUpdatedContext))
            .thenAnswer((_) async => expectedResponse);

        final middleware = optionalAuthMiddleware();
        final wrappedHandler = middleware(handler.call);
        final response = await wrappedHandler(context);

        expect(response, equals(expectedResponse));
        verify(() => handler.call(mockUpdatedContext)).called(1);
        verify(() => context.provide<User?>(any())).called(1);
      });

      test(
          'should pass request to handler with null user when '
          'malformed auth header provided', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final handler = _MockHandler();

        when(() => context.request).thenReturn(request);
        when(() => request.headers).thenReturn({
          'authorization': 'Basic some-basic-auth',
        });

        // Mock context.provide to return a new context
        final mockUpdatedContext = _MockRequestContext();
        when(() => context.provide<User?>(any()))
            .thenReturn(mockUpdatedContext);

        // Mock handler response
        final expectedResponse = Response.json(body: {'success': true});
        when(() => handler.call(mockUpdatedContext))
            .thenAnswer((_) async => expectedResponse);

        final middleware = optionalAuthMiddleware();
        final wrappedHandler = middleware(handler.call);
        final response = await wrappedHandler(context);

        expect(response, equals(expectedResponse));
        verify(() => handler.call(mockUpdatedContext)).called(1);
        verify(() => context.provide<User?>(any())).called(1);
      });

      test('should handle empty Bearer token gracefully', () async {
        final context = _MockRequestContext();
        final request = _MockRequest();
        final handler = _MockHandler();

        when(() => context.request).thenReturn(request);
        when(() => request.headers).thenReturn({
          'authorization': 'Bearer ',
        });

        // Mock context.provide to return a new context
        final mockUpdatedContext = _MockRequestContext();
        when(() => context.provide<User?>(any()))
            .thenReturn(mockUpdatedContext);

        // Mock handler response
        final expectedResponse = Response.json(body: {'success': true});
        when(() => handler.call(mockUpdatedContext))
            .thenAnswer((_) async => expectedResponse);

        final middleware = optionalAuthMiddleware();
        final wrappedHandler = middleware(handler.call);
        final response = await wrappedHandler(context);

        expect(response, equals(expectedResponse));
        verify(() => handler.call(mockUpdatedContext)).called(1);
        verify(() => context.provide<User?>(any())).called(1);
      });
    });
  });
}
