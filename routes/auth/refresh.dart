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

    if (data['refresh_token'] == null ||
        data['refresh_token'].toString().isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Refresh token is required'},
      );
    }

    final refreshTokenRequest = RefreshTokenRequest.fromJson(data);
    final authResponse = await AuthService().refreshToken(refreshTokenRequest);

    return Response.json(
      body: {
        'data': {
          'token': authResponse.token,
          'refresh_token': authResponse.refreshToken,
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
      statusCode: 401,
      body: {'error': e.toString()},
    );
  }
}
