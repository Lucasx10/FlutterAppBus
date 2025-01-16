import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/pages/login/login_page.dart';
import 'package:login/pages/sign_up/sign_up_page.dart';
import '../shared/constants/custom_colors.dart';

class ForgetPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final customColors = CustomColors();

  ForgetPasswordPage({super.key});

  void _resetPassword(BuildContext context) async {
    String email = emailController.text.trim();

    // Verifica se o email não está vazio
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, insira um e-mail válido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Se o email for válido, envia o e-mail de redefinição de senha
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Instruções de redefinição de senha enviadas!'),
          backgroundColor: Colors.green,
        ),
      );

      // Volta para a página anterior (login)
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
    } catch (e) {
      // Se o e-mail não estiver no banco de dados, exibe uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Este e-mail não está cadastrado.'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: const EdgeInsets.only(top: 32.0),
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navega para a página anterior
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Text('Redefinir Senha'),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 30, right: 16, left: 16, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _resetPassword(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: customColors.getActivePrimaryButtonColor(),
                padding: EdgeInsets.symmetric(
                    vertical: 12, horizontal: 50), // Cor do botão
              ),
              child: Text(
                'Redefinir Senha',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Já tem uma conta? Faça login aqui'),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: const Text("Você ainda não tem uma conta?"),
            ),
          ],
        ),
      ),
    );
  }
}
