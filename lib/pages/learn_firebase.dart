import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login/shared/constants/custom_colors.dart';

class LearnFirebase extends StatefulWidget {
  const LearnFirebase({super.key});

  @override
  State<LearnFirebase> createState() => _LearnFirebaseState();
}

class _LearnFirebaseState extends State<LearnFirebase> {
  List<String> listStrings = <String>["Nenhum registro carregado."];
  Uri url = Uri.https("teste-ad99c-default-rtdb.firebaseio.com", "/words.json");
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30),
        child: Center(
          child: RefreshIndicator(
            onRefresh: () => _getInformationFromBack(),
            child: ListView(
              children: [
                TextFormField(
                  controller: _controller,
                  decoration:
                      InputDecoration(labelText: "Insira uma palavra aqui"),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () => _addStringToBack(),
                  child: Text(
                    "Grava no firebase",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          CustomColors().getActivePrimaryButtonColor()),
                ),
                for (String s in listStrings)
                  Text(
                    s,
                    textAlign: TextAlign.center,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getInformationFromBack() {
    return http.get(url).then((response) {
      Map<String, dynamic> map = json.decode(response.body);
      listStrings = [];
      map.forEach(((key, value) {
        setState(() {
          listStrings.add(map[key]["word"]);
        });
      }));
    });
  }

  void _addStringToBack() {
    http
        .post(
      url,
      body: json.encode({"word": _controller.text}),
    )
        .then((value) {
      _getInformationFromBack().then((value) {
        _controller.text = "";
        final snackBar = SnackBar(
          content: Text('Palavra gravada com Sucesso!'),
          action: SnackBarAction(
            label: "Dispensar",
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    });
  }
}
