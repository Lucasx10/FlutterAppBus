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
  TextEditingController _confirmInputController = TextEditingController();

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
                        validator: (value) {
                          if (value!.length < 10) {
                            return "Digite um nome maior";
                          }
                          return null;
                        },
                        controller: _nameInputController,
                        autofocus: true,
                        decoration:
                            getAuthenticationDecoration("Nome Completo")),
                    const SizedBox(height: 8),
                    TextFormField(
                        validator: (value) {
                          if (value!.length < 5) {
                            return "Esse e-mail é curto demais";
                          } else if (!value.contains("@")) {
                            return "Esse e-mail está meio estranho, não?";
                          }
                          return null;
                        },
                        controller: _emailInputController,
                        autofocus: true,
                        decoration: getAuthenticationDecoration("Email")),
                    const SizedBox(height: 8),
                    TextFormField(
                        validator: (value) {
                          if (value!.length < 6) {
                            return "A senha deve ter pelo menos 6 caracteres";
                          }
                          return null;
                        },
                        controller: _passwordInputController,
                        obscureText: (this.showPassword == true) ? false : true,
                        decoration: getAuthenticationDecoration("Senha")),
                    const SizedBox(height: 8),
                    (this.showPassword == false)
                        ? TextFormField(
                            obscureText: true,
                            decoration:
                                getAuthenticationDecoration("Confirmar Senha"),
                          )
                        : Container(),
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
                  _doSignUp();
                  Navigator.pop(context);
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

  void _doSignUp() {
    String email = _emailInputController.text;
    String senha = _passwordInputController.text;
    String nome = _nameInputController.text;

    if (_formKey.currentState!.validate()) {
      _authservice.signUp(nome: nome, email: email, senha: senha);
    } else {
      print("invalido");
    }
  }
}
