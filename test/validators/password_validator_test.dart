import 'package:flutter_test/flutter_test.dart';
import 'package:login/shared/validators/password_validator.dart';

void main() {
  late PasswordValidator passwordValidator;

  setUp(() {
    passwordValidator = PasswordValidator();
  });

  group(
    'validação da senha',
    () {
      test(
        'deve retornar uma mensagem de erro caso a senha seja null',
        () {
          final result = passwordValidator.validate();

          expect(result, equals('A senha é obrigatória'));
        },
      );

      test(
        'deve retornar uma mensagem de erro caso a senha seja vazia',
        () {
          final result = passwordValidator.validate(password: '');

          expect(result, equals('A senha é obrigatória'));
        },
      );

      test(
        'deve retornar uma mensagem de erro caso a senha seja menor que 6 caracteres',
        () {
          final result = passwordValidator.validate(password: 'joao');

          expect(
            result,
            equals('A senha deve possuir pelo menos 6 caracteres'),
          );
        },
      );

      test(
        'deve retornar uma mensagem de erro caso a senha não seja alfanumérica',
        () {
          final result = passwordValidator.validate(password: 'leiliany');

          expect(result, equals('A senha deve ser alfanumérica'));
        },
      );

      test(
        'deve retornar null caso a senha seja válida',
        () {
          final result = passwordValidator.validate(password: 'william123');

          expect(result, isNull);
        },
      );
    },
  );
  group(
    'validação da confirmação da senha',
    () {
      test(
        'deve retornar uma mensagem de erro caso a confirmação de senha seja null',
        () {
          final result = passwordValidator.validateConfirmPassword(
            password: 'lucas123',
            confirmPassword: null,
          );

          expect(result, equals('A confirmação da senha é obrigatória'));
        },
      );

      test(
        'deve retornar uma mensagem de erro caso a confirmação de senha seja vazia',
        () {
          final result = passwordValidator.validateConfirmPassword(
            password: 'lucas123',
            confirmPassword: '',
          );

          expect(result, equals('A confirmação da senha é obrigatória'));
        },
      );

      test(
        'deve retornar uma mensagem de erro caso a senha e a confirmação sejam diferentes',
        () {
          final result = passwordValidator.validateConfirmPassword(
            password: 'lucas123',
            confirmPassword: 'different123',
          );

          expect(result, equals('As senhas não coincidem'));
        },
      );

      test(
        'deve retornar null caso a senha e a confirmação sejam iguais',
        () {
          final result = passwordValidator.validateConfirmPassword(
            password: 'lucas123',
            confirmPassword: 'lucas123',
          );

          expect(result, isNull);
        },
      );
    },
  );
}
