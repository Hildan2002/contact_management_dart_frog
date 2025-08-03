import 'package:my_project/models/contact.dart';
import 'package:test/test.dart';

void main() {
  group('Contact', () {
    const id = 'contact-id';
    const userId = 'user-id';
    const firstName = 'John';
    const lastName = 'Doe';
    const email = 'john.doe@example.com';
    const phone = '+1234567890';
    const company = 'Example Corp';
    const address = '123 Main St, City, State 12345';
    const notes = 'Important client';
    final createdAt = DateTime.parse('2023-01-01T00:00:00.000Z');
    final updatedAt = DateTime.parse('2023-01-02T00:00:00.000Z');

    const contactJson = {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'company': company,
      'address': address,
      'notes': notes,
      'created_at': '2023-01-01T00:00:00.000Z',
      'updated_at': '2023-01-02T00:00:00.000Z',
    };

    group('constructor', () {
      test('should create contact with all properties', () {
        final contact = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          company: company,
          address: address,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(contact.id, equals(id));
        expect(contact.userId, equals(userId));
        expect(contact.firstName, equals(firstName));
        expect(contact.lastName, equals(lastName));
        expect(contact.email, equals(email));
        expect(contact.phone, equals(phone));
        expect(contact.company, equals(company));
        expect(contact.address, equals(address));
        expect(contact.notes, equals(notes));
        expect(contact.createdAt, equals(createdAt));
        expect(contact.updatedAt, equals(updatedAt));
      });

      test('should create contact with required fields only', () {
        const contact = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );

        expect(contact.id, equals(id));
        expect(contact.userId, equals(userId));
        expect(contact.firstName, equals(firstName));
        expect(contact.lastName, equals(lastName));
        expect(contact.email, equals(email));
        expect(contact.phone, isNull);
        expect(contact.company, isNull);
        expect(contact.address, isNull);
        expect(contact.notes, isNull);
        expect(contact.createdAt, isNull);
        expect(contact.updatedAt, isNull);
      });
    });

    group('fullName getter', () {
      test('should return full name combining first and last name', () {
        const contact = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );

        expect(contact.fullName, equals('John Doe'));
      });

      test('should handle names with spaces', () {
        const contact = Contact(
          id: id,
          userId: userId,
          firstName: 'Mary Jane',
          lastName: 'Watson Parker',
          email: email,
        );

        expect(contact.fullName, equals('Mary Jane Watson Parker'));
      });
    });

    group('fromJson', () {
      test('should create contact from JSON with all fields', () {
        final contact = Contact.fromJson(contactJson);

        expect(contact.id, equals(id));
        expect(contact.userId, equals(userId));
        expect(contact.firstName, equals(firstName));
        expect(contact.lastName, equals(lastName));
        expect(contact.email, equals(email));
        expect(contact.phone, equals(phone));
        expect(contact.company, equals(company));
        expect(contact.address, equals(address));
        expect(contact.notes, equals(notes));
        expect(contact.createdAt, equals(createdAt));
        expect(contact.updatedAt, equals(updatedAt));
      });

      test('should create contact from JSON with null optional fields', () {
        final jsonWithNulls = {
          'id': id,
          'user_id': userId,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': null,
          'company': null,
          'address': null,
          'notes': null,
          'created_at': null,
          'updated_at': null,
        };

        final contact = Contact.fromJson(jsonWithNulls);

        expect(contact.phone, isNull);
        expect(contact.company, isNull);
        expect(contact.address, isNull);
        expect(contact.notes, isNull);
        expect(contact.createdAt, isNull);
        expect(contact.updatedAt, isNull);
      });

      test('should create contact from JSON without optional fields', () {
        final minimalJson = {
          'id': id,
          'user_id': userId,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
        };

        final contact = Contact.fromJson(minimalJson);

        expect(contact.id, equals(id));
        expect(contact.userId, equals(userId));
        expect(contact.firstName, equals(firstName));
        expect(contact.lastName, equals(lastName));
        expect(contact.email, equals(email));
        expect(contact.phone, isNull);
        expect(contact.company, isNull);
        expect(contact.address, isNull);
        expect(contact.notes, isNull);
        expect(contact.createdAt, isNull);
        expect(contact.updatedAt, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        const originalContact = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );

        const newFirstName = 'Jane';
        const newPhone = '+0987654321';

        final updatedContact = originalContact.copyWith(
          firstName: newFirstName,
          phone: newPhone,
          updatedAt: updatedAt,
        );

        expect(updatedContact.id, equals(id));
        expect(updatedContact.userId, equals(userId));
        expect(updatedContact.firstName, equals(newFirstName));
        expect(updatedContact.lastName, equals(lastName));
        expect(updatedContact.email, equals(email));
        expect(updatedContact.phone, equals(newPhone));
        expect(updatedContact.updatedAt, equals(updatedAt));
      });

      test('should create copy with no changes when no parameters provided',
          () {
        final originalContact = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          company: company,
          address: address,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final copiedContact = originalContact.copyWith();

        expect(copiedContact, equals(originalContact));
      });
    });

    group('toJson', () {
      test('should convert contact to JSON with all fields', () {
        final contact = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          company: company,
          address: address,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = contact.toJson();

        expect(json, equals(contactJson));
      });

      test('should convert contact to JSON with null optional fields', () {
        const contact = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );

        final json = contact.toJson();

        expect(json['id'], equals(id));
        expect(json['user_id'], equals(userId));
        expect(json['first_name'], equals(firstName));
        expect(json['last_name'], equals(lastName));
        expect(json['email'], equals(email));
        expect(json['phone'], isNull);
        expect(json['company'], isNull);
        expect(json['address'], isNull);
        expect(json['notes'], isNull);
        expect(json['created_at'], isNull);
        expect(json['updated_at'], isNull);
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        final contact1 = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          company: company,
          address: address,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final contact2 = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          company: company,
          address: address,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(contact1, equals(contact2));
        expect(contact1.hashCode, equals(contact2.hashCode));
      });

      test('should not be equal when properties differ', () {
        const contact1 = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );

        const contact2 = Contact(
          id: 'different-id',
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );

        expect(contact1, isNot(equals(contact2)));
      });

      test('should not be equal when optional fields differ', () {
        const contact1 = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
        );

        const contact2 = Contact(
          id: id,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: '+0000000000',
        );

        expect(contact1, isNot(equals(contact2)));
      });
    });
  });
}
