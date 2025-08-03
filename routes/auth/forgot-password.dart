import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:my_project/models/auth_request.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/utils/validation.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;

  if (request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method not allowed'},
    );
  }

  try {
    final body = await request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    Validator.validateForgotPasswordData(data);

    final forgotPasswordRequest = ForgotPasswordRequest.fromJson(data);
    await AuthService().forgotPassword(forgotPasswordRequest);

    return Response.json(
      body: {
        'data': {
          'message': 'If the email exists, a password reset link will be sent',
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
      statusCode: 500,
      body: {'error': 'Internal server error'},
    );
  }
}
