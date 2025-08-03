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

    Validator.validateRegisterData(data);

    final registerRequest = RegisterRequest.fromJson(data);
    final authResponse = await AuthService().register(registerRequest);

    return Response.json(
      statusCode: 201,
      body: {
        'data': {
          'email': authResponse.user['email'],
          'name': authResponse.user['name'],
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
