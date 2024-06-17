import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user, required this.title});

  final String title;
  final User user;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tela inicial")),
      body: Center(
        child: Text('Bem-vindo !'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text((widget.user.displayName != null)
                  ? widget.user.displayName!
                  : ""),
              accountEmail: Text(widget.user.email!),
            ),
            ListTile(
              leading: Icon(Icons.logout_outlined),
              title: const Text('Deslogar'),
              onTap: () {
                LoginService().signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
