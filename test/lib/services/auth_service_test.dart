import 'package:my_project/models/auth_request.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/database_service.dart';
import 'package:test/test.dart';

void main() {
  late AuthService authService;
  late DatabaseService databaseService;

  setUpAll(() async {
    databaseService = DatabaseService();
    await databaseService.initialize(path: ':memory:');
    authService = AuthService();
  });

  tearDownAll(() {
    databaseService.close();
  });

  group('AuthService', () {
    group('hashPassword', () {
      test('should hash password correctly', () {
        const password = 'testPassword123';
        final hashedPassword = authService.hashPassword(password);

        expect(hashedPassword, isNotEmpty);
        expect(hashedPassword, isNot(equals(password)));
      });
    });

    group('verifyPassword', () {
      test('should verify correct password', () {
        const password = 'testPassword123';
        final hashedPassword = authService.hashPassword(password);

        final isValid = authService.verifyPassword(password, hashedPassword);
        expect(isValid, isTrue);
      });

      test('should reject incorrect password', () {
        const password = 'testPassword123';
        const wrongPassword = 'wrongPassword';
        final hashedPassword = authService.hashPassword(password);

        final isValid =
            authService.verifyPassword(wrongPassword, hashedPassword);
        expect(isValid, isFalse);
      });
    });

    group('generateToken and verifyToken', () {
      test('should generate and verify valid token', () {
        const userId = 'test-user-id';
        final token = authService.generateToken(userId);

        expect(token, isNotEmpty);

        final verifiedUserId = authService.verifyToken(token);
        expect(verifiedUserId, equals(userId));
      });

      test('should return null for invalid token', () {
        const invalidToken = 'invalid.token.here';
        final verifiedUserId = authService.verifyToken(invalidToken);
        expect(verifiedUserId, isNull);
      });
    });

    group('register', () {
      test('should register new user successfully', () async {
        const request = RegisterRequest(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        final response = await authService.register(request);

        expect(response.token, isNotEmpty);
        expect(response.user['email'], equals('test@example.com'));
        expect(response.user['name'], equals('Test User'));
        expect(response.user, isNot(contains('password_hash')));
      });

      test('should throw error for duplicate email', () async {
        const request1 = RegisterRequest(
          email: 'duplicate@example.com',
          password: 'password123',
          name: 'Test User 1',
        );

        const request2 = RegisterRequest(
          email: 'duplicate@example.com',
          password: 'password456',
          name: 'Test User 2',
        );

        await authService.register(request1);

        expect(
          () => authService.register(request2),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('login', () {
      test('should login with correct credentials', () async {
        const registerRequest = RegisterRequest(
          email: 'login@example.com',
          password: 'password123',
          name: 'Login User',
        );

        await authService.register(registerRequest);

        const loginRequest = LoginRequest(
          email: 'login@example.com',
          password: 'password123',
        );

        final response = await authService.login(loginRequest);

        expect(response.token, isNotEmpty);
        expect(response.user['email'], equals('login@example.com'));
      });

      test('should throw error for wrong password', () async {
        const registerRequest = RegisterRequest(
          email: 'wrongpass@example.com',
          password: 'password123',
          name: 'Test User',
        );

        await authService.register(registerRequest);

        const loginRequest = LoginRequest(
          email: 'wrongpass@example.com',
          password: 'wrongpassword',
        );

        expect(
          () => authService.login(loginRequest),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw error for non-existent user', () async {
        const loginRequest = LoginRequest(
          email: 'nonexistent@example.com',
          password: 'password123',
        );

        expect(
          () => authService.login(loginRequest),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getCurrentUser', () {
      test('should return user for valid token', () async {
        const registerRequest = RegisterRequest(
          email: 'currentuser@example.com',
          password: 'password123',
          name: 'Current User',
        );

        final authResponse = await authService.register(registerRequest);
        final user = authService.getCurrentUser(authResponse.token);

        expect(user, isNotNull);
        expect(user!.email, equals('currentuser@example.com'));
      });

      test('should return null for invalid token', () {
        final user = authService.getCurrentUser('invalid.token');
        expect(user, isNull);
      });

      test('should return null for null token', () {
        final user = authService.getCurrentUser(null);
        expect(user, isNull);
      });
    });
  });
}
