import 'package:flutter/material.dart';

class UserWidget extends StatelessWidget {
  final String userName;

  const UserWidget({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Text("Bem-vindo, $userName!");
  }
}
