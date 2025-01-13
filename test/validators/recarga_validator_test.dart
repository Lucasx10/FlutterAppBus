import 'package:flutter_test/flutter_test.dart';
import 'package:login/shared/validators/recarga_validator.dart';

void main() {
  late RechargeValidator rechargeValidator;

  setUp(() {
    rechargeValidator = RechargeValidator();
  });

  group('Validação da recarga', () {
    test('deve retornar uma mensagem de erro caso o valor seja vazio', () {
      final result = rechargeValidator.validate('');

      expect(result, equals('O valor é obrigatório'));
    });

    test('deve retornar uma mensagem de erro caso o valor seja não numérico',
        () {
      final result = rechargeValidator.validate('abc');

      expect(result, equals('Insira um valor válido'));
    });

    test(
        'deve retornar uma mensagem de erro caso o valor seja menor ou igual a 0',
        () {
      final result = rechargeValidator.validate('0');

      expect(result, equals('O valor deve ser maior que 0'));

      final resultNegative = rechargeValidator.validate('-5');
      expect(resultNegative, equals('O valor não pode ser negativo'));
    });

    test('deve retornar null caso o valor seja válido', () {
      final result = rechargeValidator.validate('50');

      expect(result, isNull);
    });
  });
}
