import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:my_project/di/service_locator.dart';
import 'package:my_project/models/contact.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/services/database_service.dart';
import 'package:my_project/utils/validation.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final user = context.read<User>();

  switch (request.method) {
    case HttpMethod.get:
      return _getContacts(context, user);
    case HttpMethod.post:
      return _createContact(context, user);
    case HttpMethod.options:
    case HttpMethod.head:
    case HttpMethod.put:
    case HttpMethod.patch:
    case HttpMethod.delete:
      return Response.json(
        statusCode: 405,
        body: {'error': 'Method not allowed'},
      );
  }
}

Future<Response> _getContacts(RequestContext context, User user) async {
  try {
    final request = context.request;
    final queryParams = request.uri.queryParameters;

    final limitParam = queryParams['limit'];
    final offsetParam = queryParams['offset'];
    final searchQuery = queryParams['q'];

    int? limit;
    int? offset;

    if (limitParam != null) {
      limit = int.tryParse(limitParam);
      if (limit == null || limit < 1) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'Invalid limit parameter'},
        );
      }
    }

    if (offsetParam != null) {
      offset = int.tryParse(offsetParam);
      if (offset == null || offset < 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'Invalid offset parameter'},
        );
      }
    }

    final db = serviceLocator<DatabaseService>();
    List<Contact> contacts;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      contacts = db.searchContacts(user.id, searchQuery);
    } else {
      contacts = db.getContactsByUserId(user.id, limit: limit, offset: offset);
    }

    return Response.json(
      body: {
        'contacts': contacts.map((c) => c.toJson()).toList(),
        'total': contacts.length,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to retrieve contacts'},
    );
  }
}

Future<Response> _createContact(RequestContext context, User user) async {
  try {
    final request = context.request;
    final body = await request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    Validator.validateContactData(data);

    final contactId = const Uuid().v4();
    final now = DateTime.now();

    final contact = Contact(
      id: contactId,
      userId: user.id,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String?,
      company: data['company'] as String?,
      address: data['address'] as String?,
      notes: data['notes'] as String?,
      createdAt: now,
      updatedAt: now,
    );

    serviceLocator<DatabaseService>().createContact(contact);

    return Response.json(
      statusCode: 201,
      body: {'contact': contact.toJson()},
    );
  } on ValidationError catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': e.message},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to create contact'},
    );
  }
}
