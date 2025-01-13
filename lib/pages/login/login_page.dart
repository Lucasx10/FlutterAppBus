import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/components/decoration_auth.dart';
import 'package:login/main.dart';
import 'package:login/shared/constants/custom_colors.dart';
import '../sign_up/sign_up_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailInputController = TextEditingController();
  TextEditingController _passwordInputController = TextEditingController();
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CustomColors().getGradienteMainColor(),
              CustomColors().getGradienteSecColor(),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15, top: 30),
                child: Image.asset(
                  "assets/bus2.png",
                  height: 150,
                ),
              ),
              const Text(
                "Entrar",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                        validator: (value) {
                          if (value!.length < 5) {
                            return "Esse e-mail parece curto demais";
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
                        obscureText: _obscurePassword,
                        controller: _passwordInputController,
                        autofocus: true,
                        decoration: getAuthenticationDecoration("Senha")),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "Esqueceu a senha?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Row(
                children: [
                  Checkbox(
                    value: !_obscurePassword,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _obscurePassword = !newValue!;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  const Text(
                    "Mostrar senha",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  )
                ],
              ),
              ElevatedButton(
                onPressed: () => _loginUser(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors().getActivePrimaryButtonColor(),
                ),
                child: const Text("ENTRAR",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              const Text(
                "Ainda não possui conta?",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) => const RegisterPage()),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        CustomColors().getActiveSecondaryButtonColor(),
                  ),
                  child: const Text(
                    "CADASTRE-SE",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _loginUser(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Tenta autenticar o usuário
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailInputController.text.trim(),
          password: _passwordInputController.text.trim(),
        );

        // Redireciona para o AuthWrapper
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      } catch (e) {
        print('Erro ao fazer login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer login: $e')),
        );
      }
    }
  }
}
