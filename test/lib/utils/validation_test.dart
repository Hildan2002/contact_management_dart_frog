import 'package:my_project/utils/validation.dart';
import 'package:test/test.dart';

void main() {
  group('ValidationError', () {
    test('should create validation error with message', () {
      const message = 'Test validation error';
      final error = ValidationError(message);

      expect(error.message, equals(message));
      expect(error.toString(), equals('ValidationError: $message'));
    });
  });

  group('Validator', () {
    group('validateEmail', () {
      test('should pass for valid email formats', () {
        const validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@example.org',
          'first.last@subdomain.example.com',
          'user123@test123.com',
        ];

        for (final email in validEmails) {
          expect(() => Validator.validateEmail(email), returnsNormally);
        }
      });

      test('should throw ValidationError for invalid email formats', () {
        const invalidEmails = [
          'invalid-email',
          '@example.com',
          'user@',
          'user@.com',
          'user name@example.com',
          'user@@example.com',
          '',
          'user@com',
          'user.example.com',
        ];

        for (final email in invalidEmails) {
          expect(
            () => Validator.validateEmail(email),
            throwsA(isA<ValidationError>()),
          );
        }
      });

      test('should throw ValidationError with correct message', () {
        expect(
          () => Validator.validateEmail('invalid'),
          throwsA(
            predicate(
              (e) =>
                  e is ValidationError && e.message == 'Invalid email format',
            ),
          ),
        );
      });
    });

    group('validatePassword', () {
      test('should pass for passwords with 6 or more characters', () {
        const validPasswords = [
          '123456',
          'password',
          'verylongpassword',
          'P@ssw0rd!',
          '      ', // 6 spaces
        ];

        for (final password in validPasswords) {
          expect(() => Validator.validatePassword(password), returnsNormally);
        }
      });

      test('should throw ValidationError for passwords less than 6 characters',
          () {
        const invalidPasswords = [
          '',
          '1',
          '12',
          '123',
          '1234',
          '12345',
        ];

        for (final password in invalidPasswords) {
          expect(
            () => Validator.validatePassword(password),
            throwsA(isA<ValidationError>()),
          );
        }
      });

      test('should throw ValidationError with correct message', () {
        expect(
          () => Validator.validatePassword('short'),
          throwsA(
            predicate(
              (e) =>
                  e is ValidationError &&
                  e.message == 'Password must be at least 6 characters long',
            ),
          ),
        );
      });
    });

    group('validateRequired', () {
      test('should pass for non-null, non-empty values', () {
        const validValues = [
          'value',
          'test string',
          '   text   ', // will be trimmed but still has content
          'a',
        ];

        for (final value in validValues) {
          expect(
            () => Validator.validateRequired(value, 'Field'),
            returnsNormally,
          );
        }
      });

      test('should throw ValidationError for null values', () {
        expect(
          () => Validator.validateRequired(null, 'Field'),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should throw ValidationError for empty or whitespace-only values',
          () {
        const invalidValues = [
          '',
          '   ',
          '\t',
          '\n',
          '  \t  \n  ',
        ];

        for (final value in invalidValues) {
          expect(
            () => Validator.validateRequired(value, 'Field'),
            throwsA(isA<ValidationError>()),
          );
        }
      });

      test('should throw ValidationError with correct field name', () {
        expect(
          () => Validator.validateRequired(null, 'Email'),
          throwsA(
            predicate(
              (e) => e is ValidationError && e.message == 'Email is required',
            ),
          ),
        );
      });
    });

    group('validateName', () {
      test('should pass for valid names', () {
        const validNames = [
          'Jo',
          'John',
          'Mary Jane',
          'Jean-Luc',
          "O'Connor",
          'José María',
        ];

        for (final name in validNames) {
          expect(() => Validator.validateName(name), returnsNormally);
        }
      });

      test('should throw ValidationError for null or empty names', () {
        const invalidNames = ['', '   '];

        for (final name in invalidNames) {
          expect(
            () => Validator.validateName(name),
            throwsA(isA<ValidationError>()),
          );
        }

        // Test null separately by calling validateRequired directly
        expect(
          () => Validator.validateRequired(null, 'Name'),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should throw ValidationError for names less than 2 characters', () {
        const shortNames = ['a', ' b ', '\tc\n'];

        for (final name in shortNames) {
          expect(
            () => Validator.validateName(name),
            throwsA(
              predicate(
                (e) =>
                    e is ValidationError &&
                    e.message == 'Name must be at least 2 characters long',
              ),
            ),
          );
        }
      });
    });

    group('validateContactData', () {
      test('should pass for valid contact data', () {
        final validData = {
          'first_name': 'John',
          'last_name': 'Doe',
          'email': 'john.doe@example.com',
          'phone': '+1234567890',
          'company': 'Example Corp',
        };

        expect(() => Validator.validateContactData(validData), returnsNormally);
      });

      test('should pass for minimal valid contact data', () {
        final validData = {
          'first_name': 'Jo',
          'last_name': 'Do',
          'email': 'jo@example.com',
        };

        expect(() => Validator.validateContactData(validData), returnsNormally);
      });

      test('should throw ValidationError for missing required fields', () {
        final invalidDataSets = [
          <String, dynamic>{
            'last_name': 'Doe',
            'email': 'john@example.com',
          }, // missing first_name
          <String, dynamic>{
            'first_name': 'John',
            'email': 'john@example.com',
          }, // missing last_name
          <String, dynamic>{
            'first_name': 'John',
            'last_name': 'Doe',
          }, // missing email
        ];

        for (final data in invalidDataSets) {
          expect(
            () => Validator.validateContactData(data),
            throwsA(isA<ValidationError>()),
          );
        }
      });

      test('should throw ValidationError for invalid email', () {
        final invalidData = {
          'first_name': 'John',
          'last_name': 'Doe',
          'email': 'invalid-email',
        };

        expect(
          () => Validator.validateContactData(invalidData),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should throw ValidationError for short names', () {
        final invalidDataSets = [
          {
            'first_name': 'J',
            'last_name': 'Doe',
            'email': 'john@example.com',
          },
          {
            'first_name': 'John',
            'last_name': 'D',
            'email': 'john@example.com',
          },
        ];

        for (final data in invalidDataSets) {
          expect(
            () => Validator.validateContactData(data),
            throwsA(isA<ValidationError>()),
          );
        }
      });
    });

    group('validateLoginData', () {
      test('should pass for valid login data', () {
        final validData = {
          'email': 'user@example.com',
          'password': 'password123',
        };

        expect(() => Validator.validateLoginData(validData), returnsNormally);
      });

      test('should throw ValidationError for missing email', () {
        final invalidData = {
          'password': 'password123',
        };

        expect(
          () => Validator.validateLoginData(invalidData),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should throw ValidationError for missing password', () {
        final invalidData = {
          'email': 'user@example.com',
        };

        expect(
          () => Validator.validateLoginData(invalidData),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should throw ValidationError for invalid email', () {
        final invalidData = {
          'email': 'invalid-email',
          'password': 'password123',
        };

        expect(
          () => Validator.validateLoginData(invalidData),
          throwsA(isA<ValidationError>()),
        );
      });
    });

    group('validateRegisterData', () {
      test('should pass for valid registration data', () {
        final validData = {
          'email': 'user@example.com',
          'password': 'password123',
          'name': 'John Doe',
        };

        expect(
          () => Validator.validateRegisterData(validData),
          returnsNormally,
        );
      });

      test('should throw ValidationError for missing fields', () {
        final invalidDataSets = [
          <String, dynamic>{
            'password': 'password123',
            'name': 'John Doe',
          }, // missing email
          <String, dynamic>{
            'email': 'user@example.com',
            'name': 'John Doe',
          }, // missing password
          <String, dynamic>{
            'email': 'user@example.com',
            'password': 'password123',
          }, // missing name
        ];

        for (final data in invalidDataSets) {
          expect(
            () => Validator.validateRegisterData(data),
            throwsA(isA<ValidationError>()),
          );
        }
      });

      test('should throw ValidationError for invalid email', () {
        final invalidData = {
          'email': 'invalid-email',
          'password': 'password123',
          'name': 'John Doe',
        };

        expect(
          () => Validator.validateRegisterData(invalidData),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should throw ValidationError for short password', () {
        final invalidData = {
          'email': 'user@example.com',
          'password': '123',
          'name': 'John Doe',
        };

        expect(
          () => Validator.validateRegisterData(invalidData),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should throw ValidationError for invalid name', () {
        final invalidData = {
          'email': 'user@example.com',
          'password': 'password123',
          'name': 'J',
        };

        expect(
          () => Validator.validateRegisterData(invalidData),
          throwsA(isA<ValidationError>()),
        );
      });
    });

    group('validateUpdatePasswordData', () {
      test('should pass for valid update password data', () {
        final validData = {
          'current_password': 'oldpassword',
          'new_password': 'newpassword123',
        };

        expect(
          () => Validator.validateUpdatePasswordData(validData),
          returnsNormally,
        );
      });

      test('should throw ValidationError for missing fields', () {
        final invalidDataSets = [
          <String, dynamic>{
            'new_password': 'newpassword123',
          }, // missing current_password
          <String, dynamic>{
            'current_password': 'oldpassword',
          }, // missing new_password
        ];

        for (final data in invalidDataSets) {
          expect(
            () => Validator.validateUpdatePasswordData(data),
            throwsA(isA<ValidationError>()),
          );
        }
      });

      test('should throw ValidationError for short new password', () {
        final invalidData = {
          'current_password': 'oldpassword',
          'new_password': '123',
        };

        expect(
          () => Validator.validateUpdatePasswordData(invalidData),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should throw ValidationError when passwords are the same', () {
        final invalidData = {
          'current_password': 'samepassword',
          'new_password': 'samepassword',
        };

        expect(
          () => Validator.validateUpdatePasswordData(invalidData),
          throwsA(
            predicate(
              (e) =>
                  e is ValidationError &&
                  e.message ==
                      'New password must be different from current password',
            ),
          ),
        );
      });
    });

    group('validateForgotPasswordData', () {
      test('should pass for valid forgot password data', () {
        final validData = {
          'email': 'user@example.com',
        };

        expect(
          () => Validator.validateForgotPasswordData(validData),
          returnsNormally,
        );
      });

      test('should throw ValidationError for missing email', () {
        final invalidData = <String, dynamic>{};

        expect(
          () => Validator.validateForgotPasswordData(invalidData),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should throw ValidationError for invalid email', () {
        final invalidData = {
          'email': 'invalid-email',
        };

        expect(
          () => Validator.validateForgotPasswordData(invalidData),
          throwsA(isA<ValidationError>()),
        );
      });
    });

    group('validateResetPasswordData', () {
      test('should pass for valid reset password data', () {
        final validData = {
          'token': 'reset-token-123',
          'new_password': 'newpassword123',
        };

        expect(
          () => Validator.validateResetPasswordData(validData),
          returnsNormally,
        );
      });

      test('should throw ValidationError for missing fields', () {
        final invalidDataSets = [
          <String, dynamic>{
            'new_password': 'newpassword123',
          }, // missing token
          <String, dynamic>{
            'token': 'reset-token-123',
          }, // missing new_password
        ];

        for (final data in invalidDataSets) {
          expect(
            () => Validator.validateResetPasswordData(data),
            throwsA(isA<ValidationError>()),
          );
        }
      });

      test('should throw ValidationError for short new password', () {
        final invalidData = {
          'token': 'reset-token-123',
          'new_password': '123',
        };

        expect(
          () => Validator.validateResetPasswordData(invalidData),
          throwsA(isA<ValidationError>()),
        );
      });
    });
  });
}
