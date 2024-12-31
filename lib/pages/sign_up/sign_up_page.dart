import 'package:flutter/material.dart';
import 'package:login/components/decoration_auth.dart';
import 'package:login/services/auth_service.dart';
import 'package:login/shared/constants/custom_colors.dart';

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

  bool? showPassword = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 50,
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
              Text(
                "Cadastro",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
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
                      validator: (value) {
                        final bool emailValid = RegExp(
                                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                            .hasMatch(value ?? '');

                        if (value == null || value.isEmpty) {
                          return "O e-mail não pode estar vazio.";
                        } else if (!emailValid) {
                          return "Por favor, insira um e-mail válido.";
                        }
                        return null;
                      },
                      controller: _emailInputController,
                      autofocus: true,
                      decoration: getAuthenticationDecoration("Email"),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return "A senha deve ter pelo menos 6 caracteres";
                          }
                          return null;
                        },
                        controller: _passwordInputController,
                        obscureText: (this.showPassword == true) ? false : true,
                        decoration: getAuthenticationDecoration("Senha")),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordInputController,
                      obscureText: (this.showPassword == true) ? false : true,
                      decoration:
                          getAuthenticationDecoration("Confirmar Senha"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, confirme sua senha.";
                        } else if (value != _passwordInputController.text) {
                          return "As senhas não coincidem.";
                        }
                        return null;
                      },
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
                onPressed: () {
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
                child: Text(
                  "CADASTRAR",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      CustomColors().getActiveSecondaryButtonColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _doSignUp() async {
    String email = _emailInputController.text;
    String senha = _passwordInputController.text;
    String nome = _nameInputController.text;

    if (_formKey.currentState!.validate()) {
      String? result =
          await _authservice.signUp(nome: nome, email: email, senha: senha);
      if (result == null) {
        // Cadastro bem-sucedido, navegar para outra tela ou mostrar sucesso
        Navigator.pop(context);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor, corrija os erros antes de continuar."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
