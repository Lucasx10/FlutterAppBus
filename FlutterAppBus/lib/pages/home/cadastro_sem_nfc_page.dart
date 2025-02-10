import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../shared/constants/custom_colors.dart';

class ManualCardRegistrationPage extends StatelessWidget {
  final FirebaseService firebaseService;
  final TextEditingController cardCodeController = TextEditingController();
  final customColors = CustomColors();

  ManualCardRegistrationPage({super.key, required this.firebaseService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: const EdgeInsets.only(top: 16.0),
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context); // Navega para a página anterior
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            "Cadastrar Cartão Manualmente",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true, // Título alinhado à direita
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: cardCodeController,
                  decoration: InputDecoration(
                    labelText: "Digite o código do Cartão",
                    prefixIcon: Icon(
                      Icons.credit_card,
                      color: Colors.grey,
                      size: 30,
                    ), // Ícone no início do campo
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String cardCode = cardCodeController.text.trim();
                  bool isCardLinked =
                      await firebaseService.isCardLinked(cardCode);
                  if (isCardLinked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Este cartão já está vinculado a outro usuário."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    await firebaseService.linkCard(cardCode);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Cartão vinculado com sucesso!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Espera 2 segundos antes de voltar
                    await Future.delayed(Duration(seconds: 2));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: customColors.getActivePrimaryButtonColor(),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text("Cadastrar Cartão",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
