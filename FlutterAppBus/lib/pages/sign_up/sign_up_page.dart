import 'package:flutter/material.dart';
import 'package:login/components/decoration_auth.dart';
import 'package:login/services/auth_service.dart';
import 'package:login/shared/constants/custom_colors.dart';
import 'package:login/shared/validators/email_validator.dart';
import 'package:login/shared/validators/password_validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _nameInputController = TextEditingController();
  TextEditingController _emailInputController = TextEditingController();
  TextEditingController _passwordInputController = TextEditingController();
  TextEditingController _confirmPasswordInputController =
      TextEditingController();

  SignUpService _authservice = SignUpService();
  final EmailValidator _emailValidator = EmailValidator();
  final passwordValidator = PasswordValidator();

  bool? showPassword = false;
  bool isLoading = false; // Variável de controle de carregamento
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 60, // Espaçamento do topo
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CustomColors().getGradienteSecColor(),
              CustomColors().getGradienteMainColor(),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Linha com a setinha e título centralizado
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Volta para a tela anterior
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: Text(
                        "Cadastro",
                        textAlign: TextAlign.center, // Centraliza o texto
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 30), // Espaçamento entre o título e o formulário
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                        controller: _nameInputController,
                        autofocus: true,
                        decoration:
                            getAuthenticationDecoration("Nome Completo")),
                    const SizedBox(height: 8),
                    TextFormField(
                      validator: (value) =>
                          _emailValidator.validate(email: value),
                      controller: _emailInputController,
                      autofocus: true,
                      decoration: getAuthenticationDecoration("Email"),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                        validator: (value) =>
                            passwordValidator.validate(password: value),
                        controller: _passwordInputController,
                        obscureText: (this.showPassword == true) ? false : true,
                        decoration: getAuthenticationDecoration("Senha")),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordInputController,
                      obscureText: (this.showPassword == true) ? false : true,
                      decoration:
                          getAuthenticationDecoration("Confirmar Senha"),
                      validator: (value) =>
                          passwordValidator.validateConfirmPassword(
                        password: _passwordInputController.text,
                        confirmPassword: value,
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: this.showPassword,
                          onChanged: (bool? newValue) {
                            setState(() {
                              this.showPassword = newValue;
                            });
                          },
                        ),
                        Text(
                          "Mostrar senha?",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        // Desabilita o botão durante o carregamento
                        if (_formKey.currentState!.validate()) {
                          _doSignUp();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Por favor, corrija os erros antes de continuar."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      CustomColors().getActiveSecondaryButtonColor(),
                ),
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        "CADASTRAR",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _doSignUp() async {
    setState(() {
      isLoading = true; // Inicia o carregamento
    });

    String email = _emailInputController.text;
    String senha = _passwordInputController.text;
    String nome = _nameInputController.text;

    if (_formKey.currentState!.validate()) {
      String? result =
          await _authservice.signUp(nome: nome, email: email, senha: senha);
      setState(() {
        isLoading = false; // Finaliza o carregamento
      });

      if (result == null) {
        // Cadastro bem-sucedido, voltar para a tela de login
        Navigator.pop(
            context); // Isso volta para a tela de login sem autenticar o usuário automaticamente
      } else {
        // Exibir a mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() {
        isLoading = false; // Finaliza o carregamento em caso de erro
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor, corrija os erros antes de continuar."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
