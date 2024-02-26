import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login/pages/learn_firebase.dart';
import 'package:login/pages/sign_up/sign_up_page.dart';

import 'pages/login/login_page.dart';
//import 'register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), //alterar aqui
    );
  }
}
