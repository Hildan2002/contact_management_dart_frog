import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:my_project/di/service_locator.dart';
import 'package:my_project/models/auth_request.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/utils/validation.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;

  if (request.method != HttpMethod.put) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method not allowed'},
    );
  }

  try {
    final user = context.read<User?>();
    if (user == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Authentication required'},
      );
    }

    final body = await request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    Validator.validateUpdatePasswordData(data);

    final updatePasswordRequest = UpdatePasswordRequest.fromJson(data);
    final authService = serviceLocator<AuthService>();
    await authService.updatePassword(user.id, updatePasswordRequest);

    return Response.json(
      body: {
        'data': {
          'message': 'Password updated successfully',
        },
      },
    );
  } on ValidationError catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': e.message},
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': e.toString()},
    );
  }
}
