import 'dart:developer';

import 'package:dart_frog/dart_frog.dart';
import 'package:my_project/services/database_service.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(corsHeaders())
      .use(databaseMiddleware());
}

Middleware requestLogger() {
  return (handler) {
    return (context) async {
      final request = context.request;
      final method = request.method.value;
      final uri = request.uri;

      log('[${DateTime.now().toIso8601String()}] $method $uri');

      try {
        final response = await handler(context);
        log(
          '[${DateTime.now().toIso8601String()}] $method $uri - '
          '${response.statusCode}',
        );
        return response;
      } catch (error) {
        log(
          '[${DateTime.now().toIso8601String()}] $method $uri - ERROR: $error',
        );
        rethrow;
      }
    };
  };
}

Middleware corsHeaders() {
  return (handler) {
    return (context) async {
      final response = await handler(context);

      return response.copyWith(
        headers: {
          ...response.headers,
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods':
              'GET, POST, PUT, DELETE, PATCH, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        },
      );
    };
  };
}

Middleware databaseMiddleware() {
  return (handler) {
    return (context) async {
      try {
        await DatabaseService().initialize();
        return await handler(context);
      } catch (error) {
        return Response.json(
          statusCode: 500,
          body: {'error': 'Database initialization failed'},
        );
      }
    };
  };
}
