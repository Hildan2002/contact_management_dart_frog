import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('GET /', () {
    test('responds with API documentation and endpoints', () async {
      final context = _MockRequestContext();
      final response = route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));

      final responseBody = await response.body();
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(
        responseData['message'],
        equals('Welcome to Contact Management API'),
      );
      expect(responseData['version'], equals('1.0.0'));
      expect(
        responseData,
        containsPair('endpoints', isA<Map<String, dynamic>>()),
      );
      expect(
        responseData['endpoints'],
        containsPair('auth', isA<Map<String, dynamic>>()),
      );
      expect(
        responseData['endpoints'],
        containsPair('contacts', isA<Map<String, dynamic>>()),
      );
    });
  });
}
