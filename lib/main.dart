import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login/firebase_options.dart';
import 'package:login/pages/home/home.dart';
import 'pages/login/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App Bus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RoteadorTela(), // Já aponta para a nova lógica
    );
  }
}

class RoteadorTela extends StatelessWidget {
  const RoteadorTela({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getCurrentUser(), // Espera pelo estado inicial do usuário
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Indicador de carregamento
        } else if (snapshot.hasData) {
          return HomePage(
            user: snapshot.data!,
            title: 'Home',
          );
        } else {
          return LoginPage();
        }
      },
    );
  }

  // Método para pegar o usuário atual
  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.authStateChanges().first;
  }
}
