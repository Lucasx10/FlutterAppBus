import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart'; // Importar para inicializar o Firebase
import 'package:login/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Inicializa o binding do Flutter

  late SignUpService signUpService;
  late LoginService loginService;

  setUpAll(() async {
    await Firebase
        .initializeApp(); // Inicializa o Firebase antes de rodar os testes
  });

  setUp(() {
    signUpService = SignUpService();
    loginService = LoginService();
  });

  group(
    'Cadastro de usuário',
    () {
      test(
        'deve retornar uma mensagem de erro caso o e-mail já esteja em uso',
        () async {
          final email = 'email_existente@gmail.com';
          final senha = 'senha123';
          final nome = 'Usuário Teste';

          final result = await signUpService.signUp(
            email: email,
            senha: senha,
            nome: nome,
          );

          expect(result, equals('Já existe uma conta com esse e-mail.'));
        },
      );

      test(
        'deve retornar uma mensagem de erro em caso de falha inesperada',
        () async {
          final email = 'falha@teste.com';
          final senha = 'senha123';
          final nome = 'Usuário Teste';

          final result = await signUpService.signUp(
            email: email,
            senha: senha,
            nome: nome,
          );

          expect(result, contains('Erro inesperado'));
        },
      );

      test(
        'deve retornar null caso o cadastro seja bem-sucedido',
        () async {
          final email = 'usuario@teste.com';
          final senha = 'senha123';
          final nome = 'Usuário Teste';

          final result = await signUpService.signUp(
            email: email,
            senha: senha,
            nome: nome,
          );

          expect(result, isNull);
        },
      );
    },
  );

  group(
    'Login de usuário',
    () {
      test(
        'deve retornar null caso o login seja bem-sucedido',
        () async {
          final email = 'usuario@teste.com';
          final senha = 'senha123';

          final result = await loginService.login(
            email: email,
            senha: senha,
          );

          expect(result, isNull);
        },
      );

      test(
        'deve retornar uma mensagem de erro para credenciais inválidas',
        () async {
          final email = 'usuario_invalido@teste.com';
          final senha = 'senha_errada';

          final result = await loginService.login(
            email: email,
            senha: senha,
          );

          expect(result, isNotNull);
          expect(result, contains('The password is invalid'));
        },
      );

      test(
        'deve retornar uma mensagem de erro para usuário inexistente',
        () async {
          final email = 'nao_existe@teste.com';
          final senha = 'senha123';

          final result = await loginService.login(
            email: email,
            senha: senha,
          );

          expect(result, contains('There is no user record'));
        },
      );
    },
  );
}
