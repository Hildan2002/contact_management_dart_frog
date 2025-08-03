import 'package:dart_frog/dart_frog.dart';
import 'package:my_project/di/service_locator.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/services/auth_service.dart';

/// Middleware that authenticates requests and injects the current user.
Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final request = context.request;
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.json(
          statusCode: 401,
          body: {'error': 'Authorization token required'},
        );
      }

      final token = authHeader.substring(7);
      final authService = serviceLocator<AuthService>();
      final user = authService.getCurrentUser(token);

      if (user == null) {
        return Response.json(
          statusCode: 401,
          body: {'error': 'Invalid or expired token'},
        );
      }

      final updatedContext = context.provide<User>(() => user);
      return handler(updatedContext);
    };
  };
}

/// Middleware that optionally authenticates requests.
Middleware optionalAuthMiddleware() {
  return (handler) {
    return (context) async {
      final request = context.request;
      final authHeader = request.headers['authorization'];

      User? user;
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        final authService = serviceLocator<AuthService>();
        user = authService.getCurrentUser(token);
      }

      final updatedContext = user != null
          ? context.provide<User?>(() => user)
          : context.provide<User?>(() => null);

      return handler(updatedContext);
    };
  };
}
