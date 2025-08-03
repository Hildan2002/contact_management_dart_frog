import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/services/database_service.dart';
import 'package:my_project/utils/validation.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final request = context.request;
  final user = context.read<User>();

  switch (request.method) {
    case HttpMethod.get:
      return _getContact(context, user, id);
    case HttpMethod.put:
      return _updateContact(context, user, id);
    case HttpMethod.delete:
      return _deleteContact(context, user, id);
    case HttpMethod.options:
    case HttpMethod.head:
    case HttpMethod.post:
    case HttpMethod.patch:
      return Response.json(
        statusCode: 405,
        body: {'error': 'Method not allowed'},
      );
  }
}

Future<Response> _getContact(
  RequestContext context,
  User user,
  String id,
) async {
  try {
    final db = DatabaseService();
    final contact = db.getContactById(id, user.id);

    if (contact == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Contact not found'},
      );
    }

    return Response.json(
      body: {'contact': contact.toJson()},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to retrieve contact'},
    );
  }
}

Future<Response> _updateContact(
  RequestContext context,
  User user,
  String id,
) async {
  try {
    final request = context.request;
    final body = await request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final db = DatabaseService();
    final existingContact = db.getContactById(id, user.id);

    if (existingContact == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Contact not found'},
      );
    }

    Validator.validateContactData(data);

    final updatedContact = existingContact.copyWith(
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String?,
      company: data['company'] as String?,
      address: data['address'] as String?,
      notes: data['notes'] as String?,
      updatedAt: DateTime.now(),
    );

    db.updateContact(updatedContact);

    return Response.json(
      body: {'contact': updatedContact.toJson()},
    );
  } on ValidationError catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': e.message},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to update contact'},
    );
  }
}

Future<Response> _deleteContact(
  RequestContext context,
  User user,
  String id,
) async {
  try {
    final db = DatabaseService();
    final deleted = db.deleteContact(id, user.id);

    if (!deleted) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Contact not found'},
      );
    }

    return Response.json(
      body: {'message': 'Contact deleted successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to delete contact'},
    );
  }
}
