import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'message': 'Welcome to Contact Management API',
      'version': '1.0.0',
      'endpoints': {
        'auth': {
          'POST /auth/register': 'Register a new user',
          'POST /auth/login': 'Login user',
          'POST /auth/forgot-password': 'Request password reset link',
          'POST /auth/reset-password': 'Reset password using token',
          'PUT /auth/update-password': 'Update password for authenticated user',
          'POST /auth/refresh': 'Refresh authentication token',
        },
        'contacts': {
          'GET /contacts': 'Get all contacts for authenticated user',
          'POST /contacts': 'Create a new contact',
          'GET /contacts/:id': 'Get a specific contact',
          'PUT /contacts/:id': 'Update a specific contact',
          'DELETE /contacts/:id': 'Delete a specific contact',
          'GET /contacts/search?q=query': 'Search contacts',
        },
      },
    },
  );
}
